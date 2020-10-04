import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

const String _prefKey = "flutter_app_components_inapp_review_last";

class InAppReviewRestrictor {
  static Function(dynamic e, StackTrace st) errorCallback;

  final Future<String> requestReviewVersion;
  final Future<InAppReviewNavigationKind> reviewKind;
  final String appStoreId;

  InAppReviewRestrictor({
    this.requestReviewVersion,
    this.reviewKind,
    this.appStoreId,
  });

  Future openStore() async {
    await InAppReview.instance.openStoreListing(appStoreId: appStoreId);
    _saveLastVersion();
  }

  Future requestReview() async {
    await InAppReview.instance.requestReview();
    _saveLastVersion();
  }

  Future<InAppReviewNavigationKind> determineNavigation() async {
    final res = await Future.wait(
      [
        _getLastVersion(),
        requestReviewVersion,
        PackageInfo.fromPlatform().then((x) => x.version),
        reviewKind,
        InAppReview.instance.isAvailable(),
      ],
    );

    final String _last = res[0];
    final String _request = res[1];
    final String _current = res[2];
    final InAppReviewNavigationKind kind = res[3];
    final bool available = res[4];

    if (!available) {
      // InAppReviewを利用できないので何もしない
      return InAppReviewNavigationKind.Silent;
    }

    if (_request == null || _request.isEmpty) {
      // 要求バージョンが存在しない場合は何もしない
      return InAppReviewNavigationKind.Silent;
    }

    final request = Version.parse(_request);
    final current = Version.parse(_current);

    if (current < request) {
      // 要求されているバージョンよりも古いバージョンを使っているので何もしない
      // 青
      return InAppReviewNavigationKind.Silent;
    }

    if (_last == null || _last.isEmpty) {
      // 要求されているバージョン以上を使っていて、まだ一度もレビューしたことがない
      // 赤
      return kind;
    }

    final last = Version.parse(_last);

    if (last == request) {
      // 要求されているバージョンはレビュー済みなので何もしない
      // 黄
      return InAppReviewNavigationKind.Silent;
    } else if (last < request) {
      // 過去にレビュー経験があるが、ソレよりも新しいバージョンのレビューがリクエストされている
      // 緑
      return kind;
    } else {
      // lastの値が異常（要求よりも新しいバージョンでレビューしている）
      // グレー
      errorCallback?.call(InAppReviewDetermineException.invalidLast(last, request), StackTrace.current);
      return InAppReviewNavigationKind.Silent;
    }
  }

  Future<String> _getLastVersion() async {
    try {
      final instance = await SharedPreferences.getInstance();

      return instance.getString(_prefKey);
    } catch (e, st) {
      errorCallback?.call(e, st);
      return null;
    }
  }

  Future _saveLastVersion() async {
    try {
      final instance = await SharedPreferences.getInstance();
      final version = await PackageInfo.fromPlatform().then((x) => x.version);
      instance.setString(_prefKey, version);
    } catch (e, st) {
      errorCallback?.call(e, st);
    }
  }
}

class InAppReviewDetermineException implements Exception {
  final String message;

  InAppReviewDetermineException.invalidLast(Version last, Version request) : message = "last review version($last) must be smaller than request version($request)";

  @override
  String toString() => "$runtimeType($message)";
}

enum InAppReviewNavigationKind {
  RequestReview,
  OpenStore,
  Silent,
}
