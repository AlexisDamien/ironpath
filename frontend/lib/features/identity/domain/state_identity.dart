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
  final bool isEmailVerified;

  const IdentityState({
    this.status = StatusAuth.initial,
    this.errorMessage,
    this.userId,
    this.isEmailVerified = false,
  });

  IdentityState copyWith({
    StatusAuth? status,
    String? errorMessage,
    String? userId,
    bool? isEmailVerified,
  }) {
    return IdentityState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
