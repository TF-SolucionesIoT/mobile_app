class ConfirmCodeState {
  final bool loading;
  final String? error;
  final String? code;
  ConfirmCodeState({
    required this.loading,
    this.error,
    this.code,
  });

  factory ConfirmCodeState.initial() =>
      ConfirmCodeState(loading: false, error: null, code: null);

  ConfirmCodeState copyWith({
    bool? loading,
    String? error,
    String? code,
  }) {
    return ConfirmCodeState(
      loading: loading ?? this.loading,
      error: error,
      code: code,
    );
  }
  
}