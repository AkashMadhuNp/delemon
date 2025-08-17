import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/admin/dashboard_overview.dart';
import 'package:delemon/presentation/admin/project/project_screen.dart';
import 'package:delemon/presentation/admin/report_screen.dart';
import 'package:delemon/presentation/admin/staff_screen.dart';
import 'package:delemon/presentation/admin/task_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ProjectService _projectService = ProjectService();

  int _currentIndex = 0;
  
  // Callback function to refresh projects
  VoidCallback? _refreshProjectsCallback;

  List<Widget> get _pages => [
    DashboardOverviewPage(),
    ProjectsScreen(
      onRefreshCallbackSet: (callback) {
        _refreshProjectsCallback = callback;
      },
    ),
    TasksPage(),
    StaffScreen(),
    ReportsPage(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
    BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
    BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0EA5E9),
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    if (_currentIndex == 1) {
      return FloatingActionButton(
        backgroundColor: const Color(0xFF0EA5E9),
        onPressed: () => _handleCreateProjectWithRealTimeValidation(),
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_currentIndex == 2) {
      return FloatingActionButton(
        backgroundColor: const Color(0xFF0EA5E9),
        onPressed: () => _handleCreateTask(),
        child: const Icon(Icons.add_task, color: Colors.white),
      );
    }
    return null;
  }




// Add these validation methods to your _AdminDashboardState class

String? _validateProjectName(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'Project name is required';
  }
  
  final trimmedName = name.trim();
  if (trimmedName.length < 3) {
    return 'Project name must be at least 3 characters long';
  }
  
  if (trimmedName.length > 100) {
    return 'Project name must be less than 100 characters';
  }
  
  // Check for special characters if needed
  if (trimmedName.contains(RegExp(r'[<>:"/\\|?*]'))) {
    return 'Project name contains invalid characters';
  }
  
  return null;
}

String? _validateProjectDescription(String? description) {
  if (description != null && description.trim().length > 500) {
    return 'Description must be less than 500 characters';
  }
  return null;
}

void _showValidationError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

// Alternative: Enhanced validation with real-time feedback
void _handleCreateProjectWithRealTimeValidation() {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Create New Project",
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Project Name Field with Validation
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Project Name *",
                  hintText: "Enter project name (3-100 characters)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.folder_outlined),
                ),
                maxLength: 100,
                validator: _validateProjectName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              
              const SizedBox(height: 12),
              
              // Description Field with Validation
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Enter project description (optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                maxLength: 500,
                validator: _validateProjectDescription,
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final newProject = ProjectModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      archived: false,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(), 
                      createdBy: '',
                    );

                    try {
                      await _projectService.createProject(context, newProject);
                      
                      _nameController.clear();
                      _descController.clear();
                      Navigator.pop(context);
                      _refreshProjectsCallback?.call();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Project created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error creating project: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Save Project",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _handleCreateTask() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("Create New Task", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "Task Title")),
            TextField(decoration: InputDecoration(labelText: "Deadline")),
          ],
        ),
      ),
    );
  }
}
