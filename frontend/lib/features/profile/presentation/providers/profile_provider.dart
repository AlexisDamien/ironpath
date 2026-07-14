import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/profile_repository.dart';
import '../../domain/models/profile.dart';
import '../../domain/profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

final profileProvider =
StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      );
    } catch (exception) {
      state = state.copyWith(
        status: ProfileStatus.success,
        profile: null,
      );
    }
  }

  Future<void> updateProfile(Profile profile) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final updatedProfile = await _repository.updateProfile(profile);
      state = state.copyWith(
        status: ProfileStatus.success,
        profile: updatedProfile,
      );
    } catch (exception) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: exception.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = const ProfileState();
  }
}