import 'models/profile.dart';

enum StatusProfile { idle, loading, success, error }

class StateProfile {
  final StatusProfile status;
  final Profile? profile;
  final String? errorMessage;

  const StateProfile({
    this.status = StatusProfile.idle,
    this.profile,
    this.errorMessage,
  });

  StateProfile copyWith({
    StatusProfile? status,
    Profile? profile,
    String? errorMessage,
  }) {
    return StateProfile(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
