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
  static Function(dynamic e, StackTrace st) onErrorCallback;

  static Future<MultipartFile> createMultipartFileWithoutExif({
    @required String multipartFieldKey,
    @required String multipartFilename,
    String filePath,
    File file,
    Uint8List bytes,
    ImageProvider imageProvider,
  }) async {
    Uint8List input;
    String fileTypeByFilePath;
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
      final imageInfo = await imageProvider.toImageInfo(timeout: const Duration(seconds: 20));

      // 中間ファイルをByteデータにする
      //
      // Note: PNGに変換している
      // Note: なぜPNGに変換するの？ -> ImageProviderからバイト配列を得る方法はそれしかなさそうだから
      final byteData = await imageInfo.image.toByteData(format: ImageByteFormat.png);

      input = byteData.buffer.asUint8List();
      fileTypeByFilePath = "png";
      byteDataFromImageProvider = true;
    } else {
      throw Exception("cannot create multipartfile as all inputs are null");
    }

    // Byteデータから回転情報を削除する
    final result = await _removeExifAndEncodeIfNeed(
      input,
      filePathForDecoderNotFound: fileTypeByFilePath,
      fromImageProvider: byteDataFromImageProvider,
    );

    final filename = "${await getTemporaryDirectory().then((x) => x.path)}/$multipartFilename.${result.filetype}";

    print("create multipart file. filetype = ${result.filetype}, field = $multipartFieldKey, fielname = $filename");

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
      contentType: MediaType("image", result.filetype),
    );

    return multipartFile;
  }

  static Future<EncodeResult> _removeExifAndEncodeIfNeed(
    List<int> input, {
    String filePathForDecoderNotFound,
    bool fromImageProvider,
  }) async {
    final decodeAndResize = (List<int> input, image.Decoder decoder) {
      const maxSize = 960;

      print("decode by ${decoder.runtimeType}.");

      // デコードする
      final decoded = decoder.decodeImage(input);

      // 画像が大きいときはリサイズする
      image.Image resized;
      if (decoded.width > maxSize || decoded.height > maxSize) {
        // 横長画像
        resized = decoded.width > decoded.height //
            ? image.copyResize(decoded, width: 960) // 横長なのでwidthを揃える
            : image.copyResize(decoded, height: 960); // 縦長なのでheightを揃える
      } else {
        resized = decoded;
      }

      // 回転方向を補正してからExifを削除する
      //
      // Note: bakeOrienation内で行われているexifデータの削除は効果がないので別途削除する
      // Note: bakeOrientation内ではexif.dataを削除しているが、encodeメソッドはexif.rawDataを参照している
      final baked = image.bakeOrientation(resized) //
        ..exif.rawData = [];

      return baked;
    };

    image.Decoder decoder;

    if (fromImageProvider) {
      // 背景: ImageProviderをPng形式のバイトデータに変換した後、image.findDecoderForDataにかけると、Jpegとして判定されてしまう
      // 問題: そのまま処理を続けるとJpegDecoder.decodeImageでExceptionが図れる
      // 対応: ImageProvider経由でExif削除を行うときは常にPngDecoderを使う
      decoder = image.PngDecoder();
    } else {
      decoder = image.findDecoderForData(input);
    }

    if (decoder == null && filePathForDecoderNotFound != null) {
      // データ構造からファイル形式を知ることに失敗したら、ファイル名から推察してみる
      //
      // Note: 常にファイル名があるとは限らない

      print("findDecoderForData failed. try to get decoder from filename.");
      decoder = image.getDecoderForNamedImage(filePathForDecoderNotFound);
    }

    if (decoder == null) {
      // デコーダが存在しない（.HEIC等）ので何もせずに終わる
      print("ImageConvertHelper: decorded not found. nothing to do.");

      // 背景: ファイル形式を知る方法は2つある（ファイル名等とデコード情報）
      // 背景: ImagePickerにはファイル形式をjpgに書き換えてしまうバグがあるので、ファイル名からファイル形式を知る方法は使えない（2020/08/14 現在）（https://github.com/flutter/flutter/issues/47719）
      // 背景: FilePickerはたまに .m ファイルを返してくるのでなんかおかしい（2020/08/14 現在）
      // 背景: HEIC等、デコーダが用意されていないファイル形式がある
      // 問題: ファイル形式を知るのが難しい
      // 対応: デコーダが見つかればデコーダ、見つからなければファイル名で形式を決める（結局バグると思うがやらないよりましかな？程度）
      final ex = Exception("decorder not found");
      onErrorCallback?.call(ex, StackTrace.current);
      return EncodeResult(input, filePathForDecoderNotFound);
    } else if (decoder is image.GifDecoder) {
      // GifアニメーションをdecodeImageするとアニメーションが失われてしまうので何もせずに終了する
      // （別途decodeAnimationというメソッドが用意されているが、これに対してリサイズはできなさそう）（Frameごとにresizeすれば良い？）
      return EncodeResult(input, "gif");
    }

    final type = decoder.fileType ?? filePathForDecoderNotFound;

    try {
      final decodedImage = decodeAndResize(input, decoder);

      Uint8List encoded;

      switch (type) {
        case "jpg":
        case "jpeg":
          print("encode by JpegEncoder.");
          encoded = image.encodeJpg(decodedImage);
          break;
        case "png":
        default:
          print("encode by PngEncoder.");
          encoded = image.encodePng(decodedImage);
          break;
      }

      return EncodeResult(encoded, type);
    } catch (e, st) {
      // 背景: findDecoderForDataはJpegとして判定したが、JpegDecoder.decodeImageを実行するとエラーになるデータがある
      // 対応: エラーが出たら何もせずに終了する
      onErrorCallback?.call(e, st);
      return EncodeResult(input, filePathForDecoderNotFound);
    }
  }
}

class EncodeResult {
  final Uint8List bytes;
  final String filetype;

  const EncodeResult(this.bytes, this.filetype);
}

extension _DecorderEx on image.Decoder {
  String get fileType {
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
