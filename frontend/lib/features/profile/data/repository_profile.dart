import '../../../core/network/api_client.dart';
import '../domain/models/profile.dart';
import '../domain/models/profile_input.dart';

class RepositoryProfile {
  final ApiClient _apiClient;

  RepositoryProfile(this._apiClient);

  Future<Profile?> getProfile() async {
    final response = await _apiClient.get('/profile');
    final data = response.data;

    if (response.statusCode == 204 || data == null || data == '') {
      return null;
    }

    if (data is! Map) {
      throw const FormatException('Réponse de profil invalide');
    }

    return Profile.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Profile> updateProfile(ProfileInput input) async {
    final response = await _apiClient.put(
      '/profile',
      data: input.toJson(),
    );
    final data = response.data;

    if (data is! Map) {
      throw const FormatException('Réponse de profil invalide');
    }

    return Profile.fromJson(Map<String, dynamic>.from(data));
  }
}
