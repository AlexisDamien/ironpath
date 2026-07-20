import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/format_exception.dart';
import '../../data/repository_profile.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/profile_input.dart';
import '../../domain/state_profile.dart';

final providerProfileRepository = Provider<RepositoryProfile>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RepositoryProfile(apiClient);
});

final providerProfile =
    StateNotifierProvider<ProviderProfileNotifier, StateProfile>((ref) {
  final repository = ref.watch(providerProfileRepository);
  return ProviderProfileNotifier(repository);
});

class ProviderProfileNotifier extends StateNotifier<StateProfile> {
  final RepositoryProfile _repository;

  ProviderProfileNotifier(this._repository) : super(const StateProfile());

  Future<void> loadProfile() async {
    state = state.copyWith(
      status: StatusProfile.loading,
      clearErrorMessage: true,
    );

    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        status: StatusProfile.success,
        profile: profile,
        clearProfile: profile == null,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: StatusProfile.error,
        errorMessage: formatExceptionMessage(error),
      );
    }
  }

  Future<Profile> updateProfile(ProfileInput input) async {
    final previousProfile = state.profile;

    state = state.copyWith(
      status: StatusProfile.loading,
      clearErrorMessage: true,
    );

    try {
      final updatedProfile = await _repository.updateProfile(input);
      state = state.copyWith(
        status: StatusProfile.success,
        profile: updatedProfile,
        clearErrorMessage: true,
      );
      return updatedProfile;
    } catch (error) {
      final message = formatExceptionMessage(error);
      state = state.copyWith(
        status: previousProfile == null
            ? StatusProfile.error
            : StatusProfile.success,
        profile: previousProfile,
        errorMessage: message,
      );
      throw Exception(message);
    }
  }

  void reset() {
    state = const StateProfile();
  }
}
