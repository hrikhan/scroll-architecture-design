import '../../../core/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.loginEndpoint,
      body: {'username': username, 'password': password},
    );

    if (response is! Map<String, dynamic> || response['token'] is! String) {
      throw ApiException(statusCode: 500, message: 'Invalid login response');
    }

    return response['token'] as String;
  }

  Future<List<User>> fetchUsers() async {
    final response = await _apiClient.get(ApiConstants.usersEndpoint);

    if (response is! List) {
      throw ApiException(statusCode: 500, message: 'Invalid users response');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(User.fromJson)
        .toList(growable: false);
  }
}
