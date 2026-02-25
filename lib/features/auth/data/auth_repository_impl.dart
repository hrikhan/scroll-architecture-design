import 'dart:convert';

import '../../../core/storage/shared_prefs_service.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SharedPrefsService sharedPrefsService,
  })  : _remoteDataSource = remoteDataSource,
        _sharedPrefsService = sharedPrefsService;

  final AuthRemoteDataSource _remoteDataSource;
  final SharedPrefsService _sharedPrefsService;

  @override
  Future<User?> restoreUserSession() async {
    final token = _sharedPrefsService.readToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final cachedUserJson = _sharedPrefsService.readUserJson();
    if (cachedUserJson == null || cachedUserJson.isEmpty) {
      await _sharedPrefsService.clearSession();
      return null;
    }

    final decoded = jsonDecode(cachedUserJson);
    if (decoded is! Map<String, dynamic>) {
      await _sharedPrefsService.clearSession();
      return null;
    }

    return User.fromJson(decoded);
  }

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final token = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    final users = await _remoteDataSource.fetchUsers();
    final user = users.isEmpty
        ? User(
            id: 0,
            email: '',
            username: username,
            firstName: 'FakeStore',
            lastName: 'User',
          )
        : users.firstWhere(
            (u) => u.username == username,
            orElse: () => users.first,
          );

    await _sharedPrefsService.saveToken(token);
    await _sharedPrefsService.saveUserJson(jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<void> logout() => _sharedPrefsService.clearSession();
}
