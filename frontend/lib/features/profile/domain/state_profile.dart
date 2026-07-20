import '../../../core/constants/enums.dart';
import 'models/profile.dart';

export '../../../core/constants/enums.dart' show StatusProfile;

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
    bool clearProfile = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return StateProfile(
      status: status ?? this.status,
      profile: clearProfile ? null : profile ?? this.profile,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
