import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/core/theme/theme.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/subtask_model.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/presentation/auth/login_page.dart';
import 'package:delemon/presentation/admin/admin_dashboard.dart';
import 'package:delemon/presentation/blocs/login/bloc/login_bloc.dart';
import 'package:delemon/presentation/blocs/signup/bloc/signup_bloc.dart'; // Add this import
import 'package:delemon/presentation/splash_screen.dart';
import 'package:delemon/presentation/staff/staff_dashboard.dart';
import 'package:delemon/presentation/auth/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserRoleAdapterAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(ProjectModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SubtaskModelAdapter());
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => BlocProvider(
            create: (context) => SignUpBloc(authService: _authService),
            child: const SignUpScreen(),
          ),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => AdminDashboard(),
        ),
        GoRoute(
          path: '/staff-dashboard',
          builder: (context, state) => StaffDashboardPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: _authService),
      child: MaterialApp.router(
        title: "Flutter Delemon Task Application",
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}

// ========================================
// ALTERNATIVE APPROACH: Multi-BLoC Provider
// ========================================

// If you prefer to provide both BLoCs globally, you can use MultiBlocProvider:

class MyAppAlternative extends StatefulWidget {
  const MyAppAlternative({super.key});

  @override
  State<MyAppAlternative> createState() => _MyAppAlternativeState();
}

class _MyAppAlternativeState extends State<MyAppAlternative> {
  late final GoRouter _router;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _router = _createRouterAlternative();
  }

  GoRouter _createRouterAlternative() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => AdminDashboard(),
        ),
        GoRoute(
          path: '/staff-dashboard',
          builder: (context, state) => StaffDashboardPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authService: _authService)),
        BlocProvider(create: (context) => SignUpBloc(authService: _authService)),
      ],
      child: MaterialApp.router(
        title: "Flutter Delemon Task Application",
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}