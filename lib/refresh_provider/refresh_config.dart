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

abstract class IPagiable<T> {
  T merge(T newOne);
  bool get hasMore;
  int get page;
}
