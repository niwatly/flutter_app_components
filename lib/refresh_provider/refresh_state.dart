class RefreshState<V, E> {
  final bool isRefreshing;
  final bool initialRefreshCompleted;
  final V? value;
  final E? error;
  final DateTime? lastRefreshedAt;

  RefreshState({
    this.value,
    this.error,
    this.isRefreshing = false,
    this.initialRefreshCompleted = false,
    this.lastRefreshedAt,
  });

  bool get isSuccess => value != null;

  bool get hasError => error != null;

  RefreshState<V, E> copyWith({
    V? value,
    E? error,
    bool? isRefreshing,
    bool? initialRefreshCompleted,
    DateTime? lastRefreshedAt,
  }) =>
      RefreshState(
        value: value ?? this.value,
        error: error ?? this.error,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        initialRefreshCompleted: initialRefreshCompleted ?? this.initialRefreshCompleted,
        lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
      );
}
