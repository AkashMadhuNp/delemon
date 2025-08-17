import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserLocalDataSource {
  static const String userBoxName = 'usersBox';

  Future<void> addUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    await box.put(user.id, user);
  }

  
  Future<UserModel?> getUserByEmail(String email) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    
    try {
      return box.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    return box.values.toList();
  }



  Future<List<UserModel>> getAllStaffs()async{
    final box=await Hive.openBox<UserModel>(UserLocalDataSource.userBoxName);
    return box.values.where((user)=>user.role == UserRoleAdapter.staff).toList();
  }

  Future<void> printAllUsersToTerminal() async {
    final box = await Hive.openBox<UserModel>("usersBox");
    
    print('\n=== HIVE BOX CONTENTS ===');
    print('Total users: ${box.length}');
    print('Box keys: ${box.keys.toList()}');
    
    if (box.isEmpty) {
      print('❌ No users in the box');
      return;
    }
    
    box.values.toList().asMap().forEach((index, user) {
      print('\n--- User ${index + 1} ---');
      print('ID: ${user.id}');
      print('Name: ${user.name}');
      print('Email: ${user.email}');
      print('Role: ${user.role}');
      print('Password: ${user.password}');
    });
    
    print('\n=== END ===\n');
  }

  
  Future<UserModel?> validateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }

  
  Future<void> deleteUser(String userId) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    await box.delete(userId);
  }

  
  Future<void> updateUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    await box.put(user.id, user);
  }
}