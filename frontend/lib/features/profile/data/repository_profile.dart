import '../../../core/network/api_client.dart';
import '../domain/models/profile.dart';

class RepositoryProfile {
  final ApiClient _apiClient;

  RepositoryProfile(this._apiClient);

  Future<Profile> getProfile() async {
    final response = await _apiClient.get('/profile');
    return Profile.fromJson(response.data);
  }

  Future<Profile> updateProfile(Profile profile) async {
    final response = await _apiClient.put('/profile', data: profile.toJson());
    return Profile.fromJson(response.data);
  }
}
