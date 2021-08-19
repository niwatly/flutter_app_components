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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshState &&
          runtimeType == other.runtimeType &&
          isRefreshing == other.isRefreshing &&
          initialRefreshCompleted == other.initialRefreshCompleted &&
          value == other.value &&
          error == other.error &&
          lastRefreshedAt == other.lastRefreshedAt;

  @override
  int get hashCode => isRefreshing.hashCode ^ initialRefreshCompleted.hashCode ^ value.hashCode ^ error.hashCode ^ lastRefreshedAt.hashCode;
}

extension RefreshControllerRx<T, E> on Stream<RefreshState<T, E>> {
  // ignore: invalid_use_of_protected_member
  Stream<T> successValueDistinct() => where((x) => x.isSuccess && !x.isRefreshing).map((x) {
        final value = x.value;
        if (value == null) {
          throw Exception("Invalid RefreshState found. isSuccess is true, but value is null.");
        }

        return value;
      }).distinct();
}
