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

  // FIXME: よくあるcopyWithの書き方を真似るとerrorをnullで上書きできないので、個別にcopyWithを作成している
  RefreshState<V, E> copyWithIsRefreshingTrue() {
    return RefreshState(
      value: value,
      error: error,
      isRefreshing: true,
      initialRefreshCompleted: initialRefreshCompleted,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }

  RefreshState<V, E> copyWithSuccessValue(V v) {
    return RefreshState(
      value: v,
      error: null,
      isRefreshing: false,
      initialRefreshCompleted: true,
      lastRefreshedAt: DateTime.now(),
    );
  }

  RefreshState<V, E> copyWithError(E e) {
    return RefreshState(
      // エラー時、直前までは成功していた分でUI表示を行いたいケースを考慮し、valueは初期化しない
      value: value,
      error: e,
      isRefreshing: false,
      initialRefreshCompleted: initialRefreshCompleted,
      lastRefreshedAt: lastRefreshedAt,
    );
  }

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
