import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' hide Locator;
import 'package:rxdart/rxdart.dart';
import 'package:state_notifier/state_notifier.dart';

extension StringHelper on String? {
  @Deprecated("nullチェックした場合と比べてsmart castが効かないため非推奨")
  bool get isNullOrEmpty => this?.isNotEmpty != true;
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
    final v = this[key];

    if (v == null) {
      return fallback;
    }

    return v;
  }
}

extension ListHelper<T> on Iterable<T> {
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

extension ImageProviderHelper<T extends Object> on ImageProvider<T> {
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
  // ignore: invalid_use_of_protected_member
  Stream<T> get streamAndStartWith => Rx.defer(() => stream.startWith(state));
}

extension StreamEx<T> on Stream<T> {
  Stream<List<T>> bufferWhile(Stream<bool> predicate) {
    return Stream<List<T>>.eventTransformed(this, (sink) => BufferWhileEventSink<T>(predicate, sink));
  }

  Stream<T> logging({
    Function(String msg)? onLogging,
    String? prefix,
  }) {
    final log = onLogging ?? (String msg) => print(msg);
    final _prefix = prefix != null ? "${prefix}:" : "";

    return doOnData((x) => log("${_prefix}onData: $x")) //
        .doOnListen(() => log("${_prefix}onListen")) //
        .doOnCancel(() => log("${_prefix}onCancel"))
        .doOnDone(() => log("${_prefix}onDone"))
        .doOnError((x, st) => log("${_prefix}onError: $x"));
  }
}

extension BoolStreamEx on Stream<bool> {
  Stream<bool> not() => map((x) => !x);
}

class BufferWhileEventSink<T> implements EventSink<T> {
  final Stream<bool> windowStream;
  final EventSink<List<T>> outputSink;
  List<T> _buffer = [];
  late StreamSubscription _sub;
  var windowOpen = false;

  BufferWhileEventSink(this.windowStream, this.outputSink) {
    _sub = this.windowStream.listen((x) {
      windowOpen = !x;
      tryOutput();
    });
  }

  void tryOutput() {
    if (windowOpen) {
      outputSink.add(_buffer);
      _buffer.clear();
    }
  }

  @override
  void add(T event) {
    _buffer.add(event);

    tryOutput();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _buffer.clear();
    _sub.cancel();
  }
}

extension EdgeInsetsEx on EdgeInsets {
  EdgeInsets withSystemPadding(BuildContext context) => add(MediaQuery.of(context).padding) as EdgeInsets;
}
