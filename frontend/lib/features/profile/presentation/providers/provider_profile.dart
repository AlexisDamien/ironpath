import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repository_profile.dart';
import '../../domain/models/profile.dart';
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
    state = state.copyWith(status: StatusProfile.loading);
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        status: StatusProfile.success,
        profile: profile,
      );
    } catch (exception) {
      state = state.copyWith(
        status: StatusProfile.success,
        clearProfile: true,
      );
    }
  }

  Future<void> updateProfile(Profile profile) async {
    state = state.copyWith(status: StatusProfile.loading);
    try {
      final updatedProfile = await _repository.updateProfile(profile);
      state = state.copyWith(
        status: StatusProfile.success,
        profile: updatedProfile,
      );
    } catch (exception) {
      state = state.copyWith(
        status: StatusProfile.error,
        errorMessage: exception.toString(),
      );
    }
  }

  void reset() {
    state = const StateProfile();
  }
}
