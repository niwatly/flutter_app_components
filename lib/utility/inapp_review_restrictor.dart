import 'package:in_app_review/in_app_review.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version/version.dart';

const String _prefKeyReviewedVersions = "flutter_app_components_reviewed_versions";
const String _prefKeyNotNowTime = "flutter_app_components_not_now_time";

class InAppReviewRestrictor {
  static Function(dynamic e, StackTrace st)? errorCallback;

  final Future<String>? requestReviewVersion;
  final Future<InAppReviewNavigationKind>? reviewKind;
  final String? appStoreId;
  final Duration keepSilentFromLastNotNow;

  InAppReviewRestrictor({
    this.requestReviewVersion,
    this.reviewKind,
    this.appStoreId,
    this.keepSilentFromLastNotNow = const Duration(days: 7),
  });

  Future openStore({bool saveCurrentVersionAsReviewed = true}) async {
    await InAppReview.instance.openStoreListing(appStoreId: appStoreId);

    if (saveCurrentVersionAsReviewed) {
      await _saveReviewedVersion();
    }
  }

  Future requestReview() async {
    await InAppReview.instance.requestReview();
    await _saveReviewedVersion();
  }

  Future denyReview() async {
    await _saveReviewedVersion();
  }

  Future saveNotNow() async {
    final instance = await SharedPreferences.getInstance();
    final str = DateTime.now().toIso8601String();
    await instance.setString(_prefKeyNotNowTime, str);
  }

  Future handleNavigationKind(InAppReviewNavigationKind kind) async {
    switch (kind) {
      case InAppReviewNavigationKind.RequestReview:
        await requestReview();
        break;
      case InAppReviewNavigationKind.OpenStore:
        await openStore();
        break;
      case InAppReviewNavigationKind.Silent:
        break;
    }
  }

  Future<InAppReviewNavigationKind> determineNavigation() async {
    final available = await InAppReview.instance.isAvailable();

    if (!available) {
      _log("$runtimeType: InAppReview is not available. determine Silent.");
      // InAppReviewを利用できないので何もしない
      return InAppReviewNavigationKind.Silent;
    }

    final lastNotNow = await _getLastNotNow();

    if (lastNotNow != null) {
      final diffFromLastNotNow = DateTime.now().difference(lastNotNow);

      if (lastNotNow != null && diffFromLastNotNow < keepSilentFromLastNotNow) {
        // 前回の「あとで」から時間がたっていないので何もしない
        _log("$runtimeType: diff $diffFromLastNotNow is less than $keepSilentFromLastNotNow. determine Silent.");
        return InAppReviewNavigationKind.Silent;
      }
    }

    final _request = await requestReviewVersion!;

    if (_request == null || _request.isEmpty) {
      _log("review request version missing. do nothing.");
      // 要求バージョンが存在しない場合は何もしない
      return InAppReviewNavigationKind.Silent;
    }

    final _reviewed = await _getReviewedVersions();

    if (_reviewed == null) {
      _log("failed to get reviewed version. do nothing.");
      // レビュー済みバージョンの取得に失敗しているので何もしない
      return InAppReviewNavigationKind.Silent;
    }

    final kind = await reviewKind!;

    final reviewed = _reviewed.map((x) => Version.parse(x)).toList(growable: false);
    final request = Version.parse(_request);
    final current = await PackageInfo.fromPlatform().then((x) => Version.parse(x.version));

    if (current < request) {
      // 要求されているバージョンよりも古いバージョンを使っているので何もしない
      // 青
      _log("current app version is smaller than review request version. do nothing.");
      return InAppReviewNavigationKind.Silent;
    }

    if (reviewed.isEmpty) {
      // 要求されているバージョン以上を使っていて、まだ一度もレビューしたことがない
      // 赤
      _log("current app version can review and not yet. do $kind");
      return kind;
    }

    if (reviewed.contains(request)) {
      // 要求されているバージョンはレビュー済みなので何もしない
      // 黄
      _log("current app version already has been reviewed. do nothing.");
      return InAppReviewNavigationKind.Silent;
    } else {
      final lastReviewed = reviewed.last;
      if (lastReviewed < request) {
        // 過去にレビュー経験があるが、それよりも新しいバージョンのレビューがリクエストされている
        // 緑
        _log("current app version can re-review and not yet. do $kind");
        return kind;
      } else {
        // レビューが要求されたバージョンではレビューしなかったが、その次のバージョンでレビューした
        _log("review request version has been reviewed on old app version. do nothing.");
        return InAppReviewNavigationKind.Silent;
      }
    }
  }

  Future<DateTime?> _getLastNotNow() async {
    final instance = await SharedPreferences.getInstance();
    final str = instance.getString(_prefKeyNotNowTime);

    if (str == null || str.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(str);
    } catch (e, st) {
      errorCallback?.call(e, st);
      await instance.remove(_prefKeyNotNowTime);
      return null;
    }
  }

  Future<List<String>?> _getReviewedVersions() async {
    try {
      final instance = await SharedPreferences.getInstance();

      return instance.getStringList(_prefKeyReviewedVersions) ?? [];
    } catch (e, st) {
      errorCallback?.call(e, st);
      return null;
    }
  }

  Future _saveReviewedVersion() async {
    try {
      final previousVersions = await _getReviewedVersions();

      if (previousVersions == null) {
        return;
      }

      final instance = await SharedPreferences.getInstance();
      final version = await PackageInfo.fromPlatform().then((x) => x.version);

      if (previousVersions.contains(version)) {
        return;
      }

      instance.setStringList(_prefKeyReviewedVersions, [...previousVersions, version]);
    } catch (e, st) {
      errorCallback?.call(e, st);
    }
  }

  void _log(String message) {
    print("$runtimeType: $message");
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

extension InAppReviewNavigationKindEx on InAppReviewNavigationKind {
  String get jsonValue {
    switch (this) {
      case InAppReviewNavigationKind.RequestReview:
        return "request_review";
      case InAppReviewNavigationKind.OpenStore:
        return "open_store";
      case InAppReviewNavigationKind.Silent:
        return "silent";
    }

    return "unknown";
  }
}
