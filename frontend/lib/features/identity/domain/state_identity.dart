enum StatusAuth {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class IdentityState {
  final StatusAuth status;
  final String? errorMessage;
  final String? userId;

  const IdentityState({
    this.status = StatusAuth.initial,
    this.errorMessage,
    this.userId,
  });

  IdentityState copyWith({
    StatusAuth? status,
    String? errorMessage,
    String? userId,
  }) {
    return IdentityState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
    );
  }
}
