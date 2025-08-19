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
    final userModel = await localDataSource.validateUser(email, password);
    return userModel?.toEntity();
  }

  @override
  Future<List<User>> getAllUsers() async {
    final models = await localDataSource.getAllUsers();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<List<User>> getAllStaffs() async {
    final models = await localDataSource.getAllStaffs();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> deleteUser(String userId) async {
    await localDataSource.deleteUser(userId);
  }

  Future<void> updateUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await localDataSource.updateUser(userModel);
  }
}