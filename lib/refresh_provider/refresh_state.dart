class RefreshState<V, E> {
  final bool isRefreshing;
  final bool initialRefreshCompleted;
  final V? value;
  final E? error;

  RefreshState({
    this.value,
    this.error,
    this.isRefreshing = false,
    this.initialRefreshCompleted = false,
  });

  bool get isSuccess => value != null;

  bool get hasError => error != null;

  RefreshState<V, E> copyWith({
    V? value,
    E? error,
    bool? isRefreshing,
    bool? initialRefreshCompleted,
  }) =>
      RefreshState(
        value: value ?? this.value,
        error: error ?? this.error,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        initialRefreshCompleted: initialRefreshCompleted ?? this.initialRefreshCompleted,
      );
}
