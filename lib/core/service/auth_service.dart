import 'package:delemon/data/datasources/user_local_datasource.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final UserLocalDataSource _dataSource = UserLocalDataSource();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final emailLower = email.trim().toLowerCase();

      final existingUser = await _dataSource.getUserByEmail(emailLower);
      if (existingUser != null) {
        return AuthResult.failure("Account with email '$emailLower' already exists!");
      }

      UserRoleAdapter userRole = role == 'Admin' 
          ? UserRoleAdapter.admin 
          : UserRoleAdapter.staff;

      final userModel = UserModel(
        id: const Uuid().v4(),
        name: name.trim(),
        email: emailLower,
        password: password, 
        role: userRole,
      );

      await _dataSource.addUser(userModel);
      
      await _setCurrentUser(userModel);
      
      await _dataSource.printAllUsersToTerminal(); 

      return AuthResult.success(
        user: userModel,
        message: "Account created successfully! Welcome, ${userModel.name}!",
      );

    } catch (e) {
      return AuthResult.failure("Signup failed: $e");
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.validateUser(
        email.trim().toLowerCase(),
        password,
      );

      if (user != null) {
        await _setCurrentUser(user);
        
        return AuthResult.success(
          user: user,
          message: "Welcome back, ${user.name}!",
        );
      } else {
        return AuthResult.failure("Invalid email or password. Please try again.");
      }

    } catch (e) {
      return AuthResult.failure("Login failed: $e");
    }
  }

  Future<void> _setCurrentUser(UserModel user) async {
    try {
      final userBox = await Hive.openBox<UserModel>('userBox');
      await userBox.put('currentUser', user);
     // print("✅ Current user stored: ${user.name} (${user.email})");
    } catch (e) {
     // print("❌ Failed to store current user: $e");
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final userBox = await Hive.openBox<UserModel>('userBox');
      return userBox.get('currentUser');
    } catch (e) {
      //print("❌ Failed to get current user: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final userBox = await Hive.openBox<UserModel>('userBox');
      await userBox.delete('currentUser');
     // print("✅ User logged out successfully");
    } catch (e) {
      //print("❌ Failed to logout: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  Future<List<UserModel>> getAllUsers() async {
    return await _dataSource.getAllUsers();
  }

  Future<bool> emailExists(String email) async {
    final user = await _dataSource.getUserByEmail(email.trim().toLowerCase());
    return user != null;
  }
}

class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String message;

  AuthResult._({
    required this.isSuccess,
    this.user,
    required this.message,
  });

  factory AuthResult.success({UserModel? user, required String message}) {
    return AuthResult._(isSuccess: true, user: user, message: message);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}