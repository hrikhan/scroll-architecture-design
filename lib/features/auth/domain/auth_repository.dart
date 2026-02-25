import 'user_model.dart';

abstract class AuthRepository {
  Future<User?> restoreUserSession();

  Future<User> login({
    required String username,
    required String password,
  });

  Future<void> logout();
}
