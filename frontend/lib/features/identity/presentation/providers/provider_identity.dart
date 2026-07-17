import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../profile/presentation/providers/provider_profile.dart';
import '../../data/repository_identity.dart';
import '../../domain/state_identity.dart';
import 'package:dio/dio.dart';

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
  return ProviderIdentityNotifier(repository, ref);
});

class ProviderIdentityNotifier extends StateNotifier<IdentityState> {
  final RepositoryIdentity _repository;
  final Ref _ref;

  ProviderIdentityNotifier(this._repository, this._ref)
      : super(const IdentityState());

  Future<void> login(String email, String password) async {
    _ref.read(providerProfile.notifier).reset();
    state = state.copyWith(status: StatusAuth.loading);
    try {
      final isEmailVerified =
          await _repository.login(email: email, password: password);
      state = state.copyWith(
        status: StatusAuth.authenticated,
        isEmailVerified: isEmailVerified,
      );
    } catch (error) {
      state = state.copyWith(
        status: StatusAuth.error,
        errorMessage: _extractErrorMessage(error),
      );
    }
  }

  Future<void> register(String email, String password) async {
    _ref.read(providerProfile.notifier).reset();
    state = state.copyWith(status: StatusAuth.loading);
    try {
      final isEmailVerified = await _repository.register(
        email: email,
        password: password,
        rgpdConsent: true,
      );
      state = state.copyWith(
        status: StatusAuth.authenticated,
        isEmailVerified: isEmailVerified,
      );
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
      _ref.read(providerProfile.notifier).reset();
      state = state.copyWith(status: StatusAuth.unauthenticated);
    } catch (error) {
      _ref.read(providerProfile.notifier).reset();
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
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<void> deleteAccount({required String password}) async {
    try {
      await _repository.deleteAccount(password: password);
      _ref.read(providerProfile.notifier).reset();
      state = state.copyWith(status: StatusAuth.unauthenticated);
    } catch (error) {
      state = state.copyWith(
        status: StatusAuth.error,
        errorMessage: _extractErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<void> refreshEmailVerificationStatus() async {
    try {
      final isEmailVerified = await _repository.checkEmailVerificationStatus();
      state = state.copyWith(isEmailVerified: isEmailVerified);
    } catch (error) {
      // silencieux — on retentera plus tard
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _repository.resendVerificationEmail();
    } catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final errorMessage = data['error'];

        if (errorMessage is String && errorMessage.isNotEmpty) {
          return errorMessage;
        }

        final message = data['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Impossible de contacter le serveur';
      }
    }

    return 'Une erreur est survenue';
  }
}
