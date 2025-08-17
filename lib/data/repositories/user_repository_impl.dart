import 'package:delemon/data/datasources/user_local_datasource.dart';
import 'package:delemon/data/repositories/user_repository.dart';
import 'package:delemon/domain/entities/user.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl(this.localDataSource);

  @override
  Future<void> signUp(User user) async {
    final userModel = UserModel.fromEntity(user);
    await localDataSource.addUser(userModel);
  }

  @override
  Future<User?> login(String email, String password) async {
    final userModel = await localDataSource.getUserByEmail(email);
    if (userModel != null && userModel.password == password) {
      return userModel.toEntity();
    }
    return null;
  }

  @override
  Future<List<User>> getAllUsers() async {
    final models = await localDataSource.getAllUsers();
    return models.map((m) => m.toEntity()).toList();
  }
}
