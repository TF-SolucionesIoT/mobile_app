class InviteState {
  final bool loading;
  final String? code;
  final String? error;

  InviteState({
    required this.loading,
    this.code,
    this.error,
  });

  factory InviteState.initial() =>
      InviteState(loading: false, code: null, error: null);

  InviteState copyWith({
    bool? loading,
    String? code,
    String? error,
  }) {
    return InviteState(
      loading: loading ?? this.loading,
      code: code,
      error: error,
    );
  }
}
