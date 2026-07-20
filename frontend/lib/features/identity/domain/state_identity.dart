import '../../../core/constants/enums.dart';

export '../../../core/constants/enums.dart' show StatusAuth;

class StateIdentity {
  final StatusAuth status;
  final String? errorMessage;
  final String? userId;
  final bool isEmailVerified;
  final bool isRestoringSession;

  const StateIdentity({
    this.status = StatusAuth.initial,
    this.errorMessage,
    this.userId,
    this.isEmailVerified = false,
    this.isRestoringSession = false,
  });

  StateIdentity copyWith({
    StatusAuth? status,
    String? errorMessage,
    String? userId,
    bool? isEmailVerified,
    bool? isRestoringSession,
    bool clearErrorMessage = false,
  }) {
    return StateIdentity(
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      userId: userId ?? this.userId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isRestoringSession: isRestoringSession ?? this.isRestoringSession,
    );
  }
}
