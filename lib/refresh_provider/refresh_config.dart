class RefreshConfig {
  final bool resetLifetime;
  final bool silent;
  final bool stack;

  RefreshConfig({
    this.resetLifetime = false,
    this.silent = false,
    this.stack = false,
  });
}

abstract class IContinuable<R> {
  R merge(R newOne);
}

abstract class IPagiable<R> implements IContinuable<R> {
  bool get hasMore;
  int get page;
}

abstract class ICursorable<R, C> implements IContinuable<R> {
  bool get hasMore;
  C? get cursor;
}
