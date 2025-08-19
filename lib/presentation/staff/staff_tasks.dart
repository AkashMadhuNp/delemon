import 'package:delemon/core/utils/task_utils.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/presentation/widgets/stafftasks/dialogs/staff_time_tracking_dialogue.dart';
import 'package:delemon/presentation/widgets/stafftasks/dialogs/task_status_dialogue.dart';
import 'package:delemon/presentation/widgets/stafftasks/staff_task_banne.dart';
import 'package:delemon/presentation/widgets/stafftasks/staff_task_empty_state.dart';
import 'package:delemon/presentation/widgets/stafftasks/staff_task_search_bar.dart';
import 'package:delemon/presentation/widgets/stafftasks/task_card.dart';
import 'package:delemon/presentation/widgets/stafftasks/task_filter_row.dart';
import 'package:flutter/material.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/auth_service.dart';


class StaffTask extends StatefulWidget {
  const StaffTask({super.key});

  @override
  State<StaffTask> createState() => _StaffTaskState();
}

class _StaffTaskState extends State<StaffTask> with TickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  
  late TabController _tabController;
  List<TaskModel> _allTasks = [];
  Map<String, ProjectModel> _projects = {};
  UserModel? _currentUser;
  bool _isLoading = true;
  String _searchQuery = '';
  TaskPriority? _selectedPriority;
  String _sortBy = 'dueDate';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser == null) {
        throw Exception("No user logged in!");
      }

      final tasks = await _taskService.getTasksByAssignee(_currentUser!.id, context);
      final projects = await _projectService.fetchProjects();
      final projectMap = <String, ProjectModel>{};
      for (final project in projects) {
        projectMap[project.id] = project;
      }
      
      setState(() {
        _allTasks = tasks;
        _projects = projectMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<TaskModel> get _filteredTasks {
    var tasks = _allTasks;

    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) =>
        task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (_projects[task.projectId]?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    if (_selectedPriority != null) {
      tasks = tasks.where((task) => task.priority == _selectedPriority!.index).toList();
    }

    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0: break;
      case 1: tasks = tasks.where((task) => task.status == TaskStatus.todo.index).toList(); break;
      case 2: tasks = tasks.where((task) => task.status == TaskStatus.inProgress.index).toList(); break;
      case 3: tasks = tasks.where((task) => task.status == TaskStatus.inReview.index).toList(); break;
      case 4: tasks = tasks.where((task) => 
        task.status == TaskStatus.completed.index || 
        task.status == TaskStatus.done.index
      ).toList(); break;
      case 5: tasks = tasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        task.status != TaskStatus.completed.index &&
        task.status != TaskStatus.done.index
      ).toList(); break;
    }

    tasks.sort((a, b) {
      switch (_sortBy) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case 'priority': return b.priority.compareTo(a.priority);
        case 'status': return a.status.compareTo(b.status);
        case 'created': return b.createdAt.compareTo(a.createdAt);
        default: return 0;
      }
    });

    return tasks;
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    try {
      await _taskService.updateTaskStatus(context, task.id, newStatus.index);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to ${TaskUtils.getStatusDisplayName(newStatus)}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showTaskStatusDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskStatusDialog(
        task: task,
        onStatusUpdate: (newStatus) => _updateTaskStatus(task, newStatus),
      ),
    );
  }

  void _showTimeTrackingDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => TimeTrackingDialog(
        task: task,
        taskService: _taskService,
        onTimeUpdate: _loadData,
      ),
    );
  }

  int _getTaskCountForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: return _allTasks.length;
      case 1: return _allTasks.where((task) => task.status == TaskStatus.todo.index).length;
      case 2: return _allTasks.where((task) => task.status == TaskStatus.inProgress.index).length;
      case 3: return _allTasks.where((task) => task.status == TaskStatus.inReview.index).length;
      case 4: return _allTasks.where((task) => 
        task.status == TaskStatus.completed.index || 
        task.status == TaskStatus.done.index
      ).length;
      case 5: return _allTasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        task.status != TaskStatus.completed.index &&
        task.status != TaskStatus.done.index
      ).length;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks${_currentUser != null ? ' - ${_currentUser!.name}' : ''}'),
        actions: [
          if (_allTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: ${_allTasks.fold(0.0, (sum, task) => sum + task.timeSpentHours).toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) => setState(() {}),
          tabs: [
            Tab(text: 'All (${_getTaskCountForTab(0)})'),
            Tab(text: 'To Do (${_getTaskCountForTab(1)})'),
            Tab(text: 'In Progress (${_getTaskCountForTab(2)})'),
            Tab(text: 'In Review (${_getTaskCountForTab(3)})'),
            Tab(text: 'Completed (${_getTaskCountForTab(4)})'),
            Tab(text: 'Overdue (${_getTaskCountForTab(5)})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TaskSearchBar(
                  onSearchChanged: (value) => setState(() => _searchQuery = value),
                ),
                TaskFilterRow(
                  selectedPriority: _selectedPriority,
                  sortBy: _sortBy,
                  onPriorityChanged: (priority) => setState(() => _selectedPriority = priority),
                  onSortChanged: (sortBy) => setState(() => _sortBy = sortBy),
                ),
                const TaskInstructionBanner(),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(6, (index) {
                      final filteredTasks = _filteredTasks;
                      
                      if (filteredTasks.isEmpty) {
                        return const TaskEmptyState();
                      }
                      
                      return RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, taskIndex) {
                            final task = filteredTasks[taskIndex].toEntity();
                            return TaskCard(
                              task: task,
                              project: _projects[task.projectId],
                              taskService: _taskService,
                              onTap: () => _showTaskStatusDialog(task),
                              onLongPress: () => _showTimeTrackingDialog(task),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
    );
  }
}