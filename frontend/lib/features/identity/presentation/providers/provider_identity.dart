import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/format_exception.dart';
import '../../../profile/presentation/providers/provider_profile.dart';
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
    StateNotifierProvider<ProviderIdentityNotifier, StateIdentity>((ref) {
  final repository = ref.watch(providerIdentityRepository);
  return ProviderIdentityNotifier(repository, ref);
});

class ProviderIdentityNotifier extends StateNotifier<StateIdentity> {
  final RepositoryIdentity _repository;
  final Ref _ref;

  ProviderIdentityNotifier(this._repository, this._ref)
      : super(
          const StateIdentity(
            status: StatusAuth.loading,
            isRestoringSession: true,
          ),
        ) {
    Future.microtask(_restoreSession);
  }

  Future<void> _restoreSession() async {
    try {
      final isEmailVerified = await _repository.restoreSession();

      if (isEmailVerified == null) {
        state = state.copyWith(
          status: StatusAuth.unauthenticated,
          isEmailVerified: false,
          isRestoringSession: false,
          clearErrorMessage: true,
        );
        return;
      }

      await _ref.read(providerProfile.notifier).loadProfile();

      state = state.copyWith(
        status: StatusAuth.authenticated,
        isEmailVerified: isEmailVerified,
        isRestoringSession: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        status: StatusAuth.unauthenticated,
        isEmailVerified: false,
        isRestoringSession: false,
        clearErrorMessage: true,
      );
    }
  }

  Future<void> login(
    String email,
    String password, {
    required bool rememberMe,
  }) async {
    _ref.read(providerProfile.notifier).reset();
    state = state.copyWith(
      status: StatusAuth.loading,
      isRestoringSession: false,
      clearErrorMessage: true,
    );

    try {
      final isEmailVerified = await _repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      await _ref.read(providerProfile.notifier).loadProfile();

      state = state.copyWith(
        status: StatusAuth.authenticated,
        isEmailVerified: isEmailVerified,
        isRestoringSession: false,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: StatusAuth.unauthenticated,
        isRestoringSession: false,
        errorMessage: formatExceptionMessage(error),
      );
    }
  }

  void clearError() {
    if (state.errorMessage == null) return;
    state = state.copyWith(clearErrorMessage: true);
  }

  Future<void> register(String email, String password) async {
    _ref.read(providerProfile.notifier).reset();
    state = state.copyWith(
      status: StatusAuth.loading,
      isRestoringSession: false,
      clearErrorMessage: true,
    );

    try {
      final isEmailVerified = await _repository.register(
        email: email,
        password: password,
        rgpdConsent: true,
      );

      await _ref.read(providerProfile.notifier).loadProfile();

      state = state.copyWith(
        status: StatusAuth.authenticated,
        isEmailVerified: isEmailVerified,
        isRestoringSession: false,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: StatusAuth.error,
        isRestoringSession: false,
        errorMessage: formatExceptionMessage(error),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: StatusAuth.loading,
      isRestoringSession: false,
      clearErrorMessage: true,
    );

    try {
      await _repository.logout();
    } finally {
      _ref.read(providerProfile.notifier).reset();
      state = state.copyWith(
        status: StatusAuth.unauthenticated,
        isEmailVerified: false,
        isRestoringSession: false,
        clearErrorMessage: true,
      );
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _repository.requestPasswordReset(email: email);
    } catch (error) {
      throw Exception(
        formatExceptionMessage(
          error,
          fallback: 'Impossible d’envoyer le lien de réinitialisation',
        ),
      );
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
      throw Exception(formatExceptionMessage(error));
    }
  }

  Future<void> deleteAccount({required String password}) async {
    try {
      await _repository.deleteAccount(password: password);
    } catch (error) {
      throw Exception(formatExceptionMessage(error));
    }
  }

  void completeAccountDeletion() {
    _ref.read(providerProfile.notifier).reset();
    state = state.copyWith(
      status: StatusAuth.unauthenticated,
      isEmailVerified: false,
      isRestoringSession: false,
      clearErrorMessage: true,
    );
  }

  Future<void> refreshEmailVerificationStatus() async {
    try {
      final isEmailVerified = await _repository.checkEmailVerificationStatus();
      state = state.copyWith(isEmailVerified: isEmailVerified);
    } catch (_) {}
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _repository.resendVerificationEmail();
    } catch (error) {
      throw Exception(formatExceptionMessage(error));
    }
  }
}
