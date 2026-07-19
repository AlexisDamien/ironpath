import '../../../core/constants/enums.dart';

export '../../../core/constants/enums.dart' show StatusAuth;

class StateIdentity {
  final StatusAuth status;
  final String? errorMessage;
  final String? userId;
  final bool isEmailVerified;

  const StateIdentity({
    this.status = StatusAuth.initial,
    this.errorMessage,
    this.userId,
    this.isEmailVerified = false,
  });

  StateIdentity copyWith({
    StatusAuth? status,
    String? errorMessage,
    String? userId,
    bool? isEmailVerified,
    bool clearErrorMessage = false,
  }) {
    return StateIdentity(
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
