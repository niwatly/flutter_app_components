import 'dart:async';
import 'dart:core';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:rxdart/rxdart.dart';
import 'package:state_notifier/state_notifier.dart';

extension StringHelper on String {
  bool get isNullOrEmpty => this == null || isEmpty;
}

extension IntHelper on int {
  String toCommaString() => NumberFormat("#,###").format(this);

  String toMoneyString() => "¥${toCommaString()}";

  String toDateStringByUnixSeconds({String format = "M/dd"}) {
    final formatter = DateFormat(format);
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(this * 1000));
  }
}

extension BoolHelper on bool {
  int get flagInt => this ? 1 : 0;
}

extension DoubleHelper on double {
  String toCommaString() => NumberFormat("#,###.###").format(this);
}

extension DateHelper on DateTime {
  String toJsonString() => toUtc().toIso8601String();
}

extension MapHelper<K, V> on Map<K, V> {
  V getOrDefault(K key, V fallback) {
    if (containsKey(key)) {
      return this[key];
    } else {
      return fallback;
    }
  }
}

extension IterableHelper<T> on Iterable<T> {
  //nullable
  T get firstOrNull => isNotEmpty ? first : null;
  T get lastOrNull => isNotEmpty ? last : null;
}

extension ListHelper<T> on Iterable<T> {
  Iterable<V> mapIndexed<V>(V Function(int index, T value) f) sync* {
    final list = toList();
    for (var i = 0; i < length; i++) {
      yield f(i, list[i]);
    }
  }

  Iterable<T> insertBetween(T Function(int index) f) sync* {
    final list = toList();
    for (var i = 0; i < length; i++) {
      yield list[i];
      if (i < length - 1) {
        yield f(i);
      }
    }
  }

  String toFoldString({String delimiter = ", "}) => fold("", (acc, v) {
        final prefix = acc.isNotEmpty ? "$acc$delimiter" : "";
        return "$prefix$v";
      });
}

extension ObjectHelper<T extends Object> on T {
  R let<R>(R selector(T self)) {
    return selector(this);
  }
}

extension ImageProviderHelper<T> on ImageProvider<T> {
  /// ImageProviderをImageInfoに変換します
  Future<ImageInfo> toImageInfo({Duration timeout = const Duration(seconds: 10)}) async {
    final stream = resolve(const ImageConfiguration());

    final subject = ReplaySubject<ImageInfo>(maxSize: 1);

    final listener = ImageStreamListener(
      (image, sync) => subject.add(image),
      onError: (e, st) {
        subject.addError(e);
      },
    );

    stream.addListener(listener);

    try {
      return await subject.first.timeout(timeout);
    } catch (e) {
      return Future.error(e);
    } finally {
      stream.removeListener(listener);
      subject.close();
    }
  }
}

extension BuildContextEx on BuildContext {
  /// Theme.of(context).colorScheme への convenience method です
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Theme.of(context).textTheme への convenience method です
  TextTheme get texts => Theme.of(this).textTheme;

  T readOrWatch<T>(bool inBuild) {
    if (inBuild) {
      return watch<T>();
    } else {
      return read<T>();
    }
  }
}

extension StateNotifierEx<T> on StateNotifier<T> {
  /// StateNotifierの更新を監視し、更新のたびに値を送出するStreamを生成します
  ///
  /// StateNotifierがdisposeされたときにStreamもCloseされるべきですが、その実装はありません。
  /// 代わりに、StreamController.broadcastに備わっている「購読数が0になったらcloseする」機能を利用します
  ///
  /// このメソッドで生成されたStreamの購読者は、必ずStateNotifierのdisposeと同じタイミングでcancelしてください
  Stream<T> asStream() {
    // ignore: close_sinks
    final sc = StreamController<T>.broadcast();

    VoidCallback removeListener;

    final op = CancelableOperation.fromFuture(
      Future.microtask(() {
        // StateNotifierのinitStateでaddListenerすると警告が出るので少しだけ待つ
        removeListener = addListener((x) => sc.add(x));
      }),
    );

    final finallyCallback = () {
      op.cancel();
      removeListener?.call();
    };
    return sc.stream //
        .doOnDone(() => finallyCallback())
        .doOnCancel(() => finallyCallback());
  }

  // ignore: invalid_use_of_protected_member
  Stream<T> get streamAndStartWith => Rx.defer(() => stream.startWith(state));
}

extension StreamEx<T> on Stream<T> {
  Stream<List<T>> bufferWhile(Stream<bool> predicate) {
    final window = Rx.combineLatest2<void, bool, bool>(
      startWith(null),
      predicate,
      (_, condition) => condition,
    );

    return buffer(window.where((x) => !x));
  }
}

extension BoolStreamEx on Stream<bool> {
  Stream<bool> not() => map((x) => !x);
}
