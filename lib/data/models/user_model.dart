import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
enum UserRoleAdapter {
  @HiveField(0)
  admin,

  @HiveField(1)
  staff,
}

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final UserRoleAdapter role; 

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  /// Convert Data -> Domain
  User toEntity() => User(
        id: id,
        name: name,
        email: email,
        password: password,
        role: role == UserRoleAdapter.admin
            ? UserRole.admin
            : UserRole.staff,
      );

  /// Convert Domain -> Data
  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: user.password,
        role: user.role == UserRole.admin
            ? UserRoleAdapter.admin
            : UserRoleAdapter.staff,
      );
}
