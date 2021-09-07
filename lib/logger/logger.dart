import 'package:stack_trace/stack_trace.dart' show Trace;

abstract class ILogger {
  void info(dynamic msg);
  void warning(dynamic msg, {StackTrace? st});
}

class PrintLogger implements ILogger {
  const PrintLogger();

  @override
  void info(dynamic msg) {
    _output(msg, "INFO");
  }

  @override
  void warning(dynamic msg, {StackTrace? st}) {
    _output(msg, "WARN", st: st);
  }

  void _output(dynamic msg, String label, {StackTrace? st}) {
    //Traceの最上段はここ（PrintLoggerの_outputメソッドの1行目）であり、2段目は呼び出し元（info, warning, etc, ...） なので、3段目を取得する
    final trace = Trace.current(2);

    final frameText = trace.frames.isNotEmpty ? trace.frames.first.location : "Frame is not available";

    final date = DateTime.now();

    print("[$label: ${date.hour}:${date.minute}:${date.second}: $frameText] $msg");

    if (st != null) {
      print(st.toString());
    }
  }
}

class SilentLogger implements ILogger {
  const SilentLogger();

  @override
  void info(dynamic msg) {}

  @override
  void warning(dynamic msg, {StackTrace? st}) {}
}
