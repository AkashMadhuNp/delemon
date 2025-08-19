import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/presentation/admin/dashboard_overview.dart';
import 'package:delemon/presentation/admin/project/project_screen.dart';
import 'package:delemon/presentation/admin/report_screen.dart';
import 'package:delemon/presentation/admin/staff_screen.dart';
import 'package:delemon/presentation/admin/task/task_screen.dart';
import 'package:delemon/presentation/widgets/admindash/project_creation_dialoggue.dart';
import 'package:delemon/presentation/widgets/admindash/task_creation_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  VoidCallback? _refreshProjectsCallback;
  final AuthService _authService = AuthService();

  static const Color _primaryColor = Color(0xFF0EA5E9);

  List<Widget> get _pages => [
    const DashboardOverviewPage(),
    ProjectsScreen(
      onRefreshCallbackSet: (callback) => _refreshProjectsCallback = callback,
    ),
     TasksPage(),
     StaffScreen(),
     ReportsPage(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
    BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
    BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); 
                                await _performLogout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      await _authService.logout();
      
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      items: _navItems,
    );
  }

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 1: // Projects tab
        return FloatingActionButton(
          heroTag: "admin_projects_fab", 
          backgroundColor: _primaryColor,
          onPressed: _showCreateProjectDialog,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Tasks tab
        return FloatingActionButton(
          heroTag: "admin_tasks_fab", 
          backgroundColor: _primaryColor,
          onPressed: _showCreateTaskDialog,
          child: const Icon(Icons.add_task, color: Colors.white),
        );
      default:
        return null;
    }
  }

  void _showCreateProjectDialog() {
    ProjectCreationDialog.show(
      context: context,
      onProjectCreated: () {
        _refreshProjectsCallback?.call();
        _showSuccessSnackBar('Project created successfully!');
      },
      onError: (error) => _showErrorSnackBar('Error creating project: $error'),
    );
  }

  void _showCreateTaskDialog() {
    TaskCreationDialog.show(
      context: context,
      onTaskCreated: () => _showSuccessSnackBar('Task created successfully!'),
      onError: (error) => _showErrorSnackBar('Error creating task: $error'),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
      ),
    );
  }
}