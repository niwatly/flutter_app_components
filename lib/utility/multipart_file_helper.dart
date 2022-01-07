import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

import 'extension.dart';

class MultipartFileHelper {
  static Function(dynamic e, StackTrace st)? onErrorCallback;

  static Future<MultipartFileInfo> createMultipartFileWithoutExif({
    required String multipartFieldKey,
    required String multipartFilename,
    String? filePath,
    File? file,
    Uint8List? bytes,
    ImageProvider? imageProvider,
    int maxSize = 480,
    Duration imageConvertTimeout = const Duration(seconds: 20),
  }) async {
    Uint8List input;
    String? fileTypeByFilePath;
    bool byteDataFromImageProvider = false;

    if (bytes != null) {
      // 与えられたバイトデータをそのまま使う
      input = bytes;
      fileTypeByFilePath = null;
    } else if (file != null) {
      // ファイルが与えられたので、バイトデータに変換して使う
      // デコーダが見つからなかった時用に、ファイル名からファイル形式を抜き出しておく
      input = await file.readAsBytes();
      fileTypeByFilePath = file.path;
    } else if (filePath != null) {
      // ファイルパスが与えられたので、ファイルにしてからバイトデータに変換して使う
      // デコーダが見つからなかった時用に、ファイル名からファイル形式を抜き出しておく
      input = await File(filePath).readAsBytes();
      fileTypeByFilePath = filePath;
    } else if (imageProvider != null) {
      // ImageProviderが与えられたので、ImageInfoに変換してからバイトデータに変換して使う
      final imageInfo = await imageProvider.toImageInfo(timeout: imageConvertTimeout);

      // 中間ファイルをByteデータにする
      //
      // Note: PNGに変換している
      // Note: なぜPNGに変換するの？ -> ImageProviderからバイト配列を得る方法はそれしかなさそうだから
      final byteData = await imageInfo.image.toByteData(format: ImageByteFormat.png);

      // toByteDataの定義を見ていくとnot-nullな値をnullableで返却してるメソッドがいる
      // ignore: avoid-non-null-assertion
      input = byteData!.buffer.asUint8List();
      fileTypeByFilePath = "png";
      byteDataFromImageProvider = true;
    } else {
      throw Exception("cannot create multipart file as all inputs are null");
    }

    // Byteデータから回転情報を削除する
    final result = await _removeExifAndEncodeIfNeed(
      input,
      filePathForDecoderNotFound: fileTypeByFilePath,
      fromImageProvider: byteDataFromImageProvider,
      maxSize: maxSize,
    );

    final filename = "${await getTemporaryDirectory().then((x) => x.path)}/$multipartFilename.${result.fileType}";

    print("create multipart file. filetype = ${result.fileType}, field = $multipartFieldKey, filename = $filename");

    // MultipartFileを作成
    final multipartFile = MultipartFile.fromBytes(
      // API側で指定されているフィールド名
      multipartFieldKey,
      // バイトデータ
      result.bytes,
      // ファイル名
      //
      // Note: バイトデータを送っているので不要そうだが、ないとAPI側でエラーになる
      // Note: ファイル名の重複による想定外のエラーを避けるため、ちゃんとした名前で送る
      filename: filename,
      // ContentType
      // FIXME: fileTypeがnullになるエラーがたまに報告されている（nullable対応前から）
      contentType: MediaType("image", result.fileType ?? "image/png"),
    );

    return MultipartFileInfo(multipartFile, result);
  }

  static Future<EncodeInfo> _removeExifAndEncodeIfNeed(
    List<int> input, {
    String? filePathForDecoderNotFound,
    required bool fromImageProvider,
    required int maxSize,
  }) async {
    int? beforeResizeLength;
    int? beforeResizeWidth;
    int? beforeResizeHeight;
    int? afterResizeLength;
    int? afterResizeWidth;
    int? afterResizeHeight;
    var resizeDone = false;
    String decoderName;

    final decodeAndResize = (List<int> input, image.Decoder decoder) {
      print("decode by ${decoder.runtimeType}.");

      // デコードする
      // Note: これまでにnullになったことはない
      // ignore: avoid-non-null-assertion
      final decoded = decoder.decodeImage(input)!;

      beforeResizeLength = decoded.length;
      beforeResizeWidth = decoded.width;
      beforeResizeHeight = decoded.height;

      // 画像が大きいときはリサイズする
      image.Image resized;
      if (decoded.width > maxSize || decoded.height > maxSize) {
        // 横長画像
        resized = decoded.width > decoded.height //
            ? image.copyResize(decoded, width: maxSize, interpolation: image.Interpolation.cubic) // 横長なのでwidthを揃える
            : image.copyResize(decoded, height: maxSize, interpolation: image.Interpolation.cubic); // 縦長なのでheightを揃える

        resizeDone = true;
      } else {
        resized = decoded;
      }

      afterResizeLength = resized.length;
      afterResizeWidth = resized.width;
      afterResizeHeight = resized.height;

      // 回転方向を補正してからExifを削除する
      //
      // Note: bakeOrienation内で行われているexifデータの削除は効果がないので別途削除する
      // Note: bakeOrientation内ではexif.dataを削除しているが、encodeメソッドはexif.rawDataを参照している
      final baked = image.bakeOrientation(resized) //
        ..exif.rawData = [];

      return baked;
    };

    image.Decoder? decoder;

    if (fromImageProvider) {
      // 背景: ImageProviderをPng形式のバイトデータに変換した後、image.findDecoderForDataにかけると、Jpegとして判定されてしまう
      // 問題: そのまま処理を続けるとJpegDecoder.decodeImageでExceptionが図れる
      // 対応: ImageProvider経由でExif削除を行うときは常にPngDecoderを使う
      decoder = image.PngDecoder();
      decoderName = "force png";
    } else {
      decoder = image.findDecoderForData(input);
      decoderName = "find ${decoder?.fileType}";
    }

    if (decoder == null && filePathForDecoderNotFound != null) {
      // データ構造からファイル形式を知ることに失敗したら、ファイル名から推察してみる
      //
      // Note: 常にファイル名があるとは限らない

      print("findDecoderForData failed. try to get decoder from filename.");
      decoder = image.getDecoderForNamedImage(filePathForDecoderNotFound);
      decoderName = "by filename ${decoder?.fileType}";
    }

    if (decoder == null) {
      // デコーダが存在しない（.HEIC等）ので何もせずに終わる
      print("ImageConvertHelper: decoded not found. nothing to do.");

      // 背景: ファイル形式を知る方法は2つある（ファイル名等とデコード情報）
      // 背景: ImagePickerにはファイル形式をjpgに書き換えてしまうバグがあるので、ファイル名からファイル形式を知る方法は使えない（2020/08/14 現在）（https://github.com/flutter/flutter/issues/47719）
      // 背景: FilePickerはたまに .m ファイルを返してくるのでなんかおかしい（2020/08/14 現在）
      // 背景: HEIC等、デコーダが用意されていないファイル形式がある
      // 問題: ファイル形式を知るのが難しい
      // 対応: デコーダが見つかればデコーダ、見つからなければファイル名で形式を決める（結局バグると思うがやらないよりましかな？程度）
      final ex = Exception("decoder not found");
      onErrorCallback?.call(ex, StackTrace.current);

      return EncodeInfo(bytes: input as Uint8List, fileType: filePathForDecoderNotFound);
    } else if (decoder is image.GifDecoder) {
      // GifアニメーションをdecodeImageするとアニメーションが失われてしまうので何もせずに終了する
      // （別途decodeAnimationというメソッドが用意されているが、これに対してリサイズはできなさそう）（Frameごとにresizeすれば良い？）
      return EncodeInfo(bytes: input as Uint8List, fileType: "gif");
    }

    final type = decoder.fileType ?? filePathForDecoderNotFound;

    try {
      final decodedImage = decodeAndResize(input, decoder);

      Uint8List encoded;

      switch (type) {
        case "jpg":
        case "jpeg":
          print("encode by JpegEncoder.");
          encoded = image.encodeJpg(decodedImage) as Uint8List;
          break;
        case "png":
        default:
          print("encode by PngEncoder.");
          encoded = image.encodePng(decodedImage) as Uint8List;
          break;
      }

      return EncodeInfo(
        bytes: encoded,
        fileType: type,
        resizeDone: resizeDone,
        beforeResizeLength: beforeResizeLength,
        beforeResizeWidth: beforeResizeWidth,
        beforeResizeHeight: beforeResizeHeight,
        afterResizeLength: afterResizeLength,
        afterResizeWidth: afterResizeWidth,
        afterResizeHeight: afterResizeHeight,
        decoderName: decoderName,
      );
    } catch (e, st) {
      onErrorCallback?.call(e, st);

      // 背景: findDecoderForDataはJpegとして判定したが、JpegDecoder.decodeImageを実行するとエラーになるデータがある
      // 対応: エラーが出たら何もせずに終了する
      return EncodeInfo(
        bytes: input as Uint8List,
        fileType: filePathForDecoderNotFound,
        resizeDone: resizeDone,
        beforeResizeLength: beforeResizeLength,
        beforeResizeWidth: beforeResizeWidth,
        beforeResizeHeight: beforeResizeHeight,
        afterResizeLength: afterResizeLength,
        afterResizeWidth: afterResizeWidth,
        afterResizeHeight: afterResizeHeight,
        decoderName: decoderName,
        decodeException: e,
      );
    }
  }
}

class EncodeInfo {
  final Uint8List bytes;
  final String? fileType;
  final int? beforeResizeLength;
  final int? beforeResizeWidth;
  final int? beforeResizeHeight;
  final int? afterResizeLength;
  final int? afterResizeWidth;
  final int? afterResizeHeight;

  final bool resizeDone;
  final String? decoderName;
  final dynamic decodeException;

  EncodeInfo({
    required this.bytes,
    required this.fileType,
    this.beforeResizeLength,
    this.beforeResizeWidth,
    this.beforeResizeHeight,
    this.afterResizeLength,
    this.afterResizeWidth,
    this.afterResizeHeight,
    this.resizeDone = false,
    this.decoderName,
    this.decodeException,
  });
}

class MultipartFileInfo {
  final MultipartFile file;
  final EncodeInfo encodeInfo;

  const MultipartFileInfo(this.file, this.encodeInfo);
}

extension _DecorderEx on image.Decoder {
  String? get fileType {
    switch (runtimeType) {
      case image.JpegDecoder:
        return "jpg";
      case image.PngDecoder:
        return "png";
      case image.GifDecoder:
        return "gif";
      case image.ExrDecoder:
        return "exr";
      case image.BmpDecoder:
        return "bmp";
      case image.TgaDecoder:
        return "tga";
      case image.TiffDecoder:
        return "tif";
      case image.PsdDecoder:
        return "psd";
      case image.WebPDecoder:
        return "webp";
    }

    return null;
  }
}
