import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/repository_identity.dart';
import '../../domain/state_identity.dart';

final providerIdentityRepository = Provider<RepositoryIdentity>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return RepositoryIdentity(
    dio: apiClient.dio,
    tokenStorage: tokenStorage,
  );
});

final providerIdentity =
    StateNotifierProvider<ProviderIdentityNotifier, IdentityState>((ref) {
  final repository = ref.watch(providerIdentityRepository);
  return ProviderIdentityNotifier(repository);
});

class ProviderIdentityNotifier extends StateNotifier<IdentityState> {
  final RepositoryIdentity _repository;

  ProviderIdentityNotifier(this._repository) : super(const IdentityState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: StatusAuth.loading);
    try {
      await _repository.login(email: email, password: password);
      state = state.copyWith(status: StatusAuth.authenticated);
    } catch (error) {
      state = state.copyWith(
        status: StatusAuth.error,
        errorMessage: _extractErrorMessage(error),
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(status: StatusAuth.loading);
    try {
      await _repository.register(
        email: email,
        password: password,
        rgpdConsent: true,
      );
      state = state.copyWith(status: StatusAuth.unauthenticated);
    } catch (error) {
      state = state.copyWith(
        status: StatusAuth.error,
        errorMessage: _extractErrorMessage(error),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: StatusAuth.loading);
    try {
      await _repository.logout();
      state = state.copyWith(status: StatusAuth.unauthenticated);
    } catch (error) {
      state = state.copyWith(status: StatusAuth.unauthenticated);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteAccount({required String password}) async {
    try {
      await _repository.deleteAccount(password: password);
      state = state.copyWith(status: StatusAuth.unauthenticated);
    } catch (error) {
      rethrow;
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'Une erreur est survenue';
  }

  Future<void> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    try {
      await _repository.updateEmail(
        currentPassword: currentPassword,
        newEmail: newEmail,
      );
    } catch (error) {
      rethrow;
    }
  }
}
