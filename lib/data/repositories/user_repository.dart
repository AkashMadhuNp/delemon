
import 'package:delemon/domain/entities/user.dart';

abstract class UserRepository {
  Future<void> signUp(User user);
  Future<User?> login(String email, String password);
  Future<List<User>> getAllUsers();
}
