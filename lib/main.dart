import 'package:delemon/core/theme/theme.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/presentation/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserRoleAdapterAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
  }if(!Hive.isAdapterRegistered(3)){
    Hive.registerAdapter(ProjectModelAdapter());
  }

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Delemon Task Application",
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      theme: AppTheme.light,     
      darkTheme: AppTheme.dark,  
      themeMode: ThemeMode.system,
    );
  }
}
