import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/presentation/widgets/projectDetail/assigned_staff_selection.dart';
import 'package:delemon/presentation/widgets/projectDetail/error_widget.dart';
import 'package:delemon/presentation/widgets/projectDetail/project_info_card.dart';
import 'package:delemon/presentation/widgets/projectDetail/project_stats_card.dart';
import 'package:delemon/presentation/widgets/projectDetail/task_selection.dart';
import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;
  
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final TaskService _taskService = TaskService();
  
  List<TaskModel> _projectTasks = [];
  List<UserModel> _assignedStaff = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch tasks for this project
      final tasks = await _taskService.fetchTasksByProject(widget.project.id!, context);
      
      // Get all assignable users
      final allUsers = await _taskService.getAllAssignableUsers();
      
      // Extract unique assignee IDs from project tasks
      final assigneeIds = <String>{};
      for (final task in tasks) {
        assigneeIds.addAll(task.assigneeIds);
      }
      
      // Filter users who are assigned to this project
      final assignedStaff = allUsers.where((user) => 
        assigneeIds.contains(user.id)).toList();

      setState(() {
        _projectTasks = tasks;
        _assignedStaff = assignedStaff;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.project.name ?? 'Project Details'),
        backgroundColor: isDark ? Colors.blue.shade800 : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjectData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? CustomErrorWidget(
                  errorMessage: _errorMessage!,
                  onRetry: _loadProjectData,
                  isDark: isDark,
                )
              : _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectInfoCard(project: widget.project, isDark: isDark),
          const SizedBox(height: 16),
          ProjectStatsCard(
            projectTasks: _projectTasks, 
            assignedStaff: _assignedStaff, 
            isDark: isDark
          ),
          const SizedBox(height: 16),
          AssignedStaffSection(
            assignedStaff: _assignedStaff, 
            projectTasks: _projectTasks, 
            isDark: isDark
          ),
          const SizedBox(height: 16),
          TasksSection(projectTasks: _projectTasks, isDark: isDark),
        ],
      ),
    );
  }
}
