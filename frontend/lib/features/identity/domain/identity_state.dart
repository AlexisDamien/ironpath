enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class IdentityState {
  final AuthStatus status;
  final String? errorMessage;
  final String? userId;

  const IdentityState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.userId,
  });

  IdentityState copyWith({
    AuthStatus? status,
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
