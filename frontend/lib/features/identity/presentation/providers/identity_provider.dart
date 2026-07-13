import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/identity_repository.dart';
import '../../domain/identity_state.dart';

final identityRepositoryProvider = Provider<IdentityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return IdentityRepository(
    dio: apiClient.dio,
    tokenStorage: tokenStorage,
  );
});

final identityProvider =
    StateNotifierProvider<IdentityNotifier, IdentityState>((ref) {
  final repository = ref.watch(identityRepositoryProvider);
  return IdentityNotifier(repository);
});

class IdentityNotifier extends StateNotifier<IdentityState> {
  final IdentityRepository _repository;

  IdentityNotifier(this._repository) : super(const IdentityState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated);
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(error),
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.register(
        email: email,
        password: password,
        rgpdConsent: true,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _extractErrorMessage(error),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (error) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'Une erreur est survenue';
  }
}
