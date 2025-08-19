// Updated part of the TasksPage to add navigation
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/presentation/admin/task/task_detail_screen.dart';
import 'package:delemon/presentation/widgets/task/task_app_bar.dart';
import 'package:delemon/presentation/widgets/task/task_empty_state.dart';
import 'package:delemon/presentation/widgets/task/task_filter_bottomsheet.dart';
import 'package:delemon/presentation/widgets/task/task_filter_chips.dart';
import 'package:delemon/presentation/widgets/task/task_list_view.dart';
import 'package:delemon/presentation/widgets/task/task_loading_state.dart';
import 'package:delemon/presentation/widgets/task/task_search_bar.dart';
import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskService _taskService = TaskService();
  final ProjectService _projectService = ProjectService();
  final TextEditingController _searchController = TextEditingController();

  List<TaskModel> _allTasks = [];
  List<TaskModel> _filteredTasks = [];
  List<ProjectModel> _projects = [];
  List<UserModel> _users = [];
  
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedProjectId;
  int? _selectedStatus;
  int? _selectedPriority;
  String? _selectedAssigneeId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        _loadTasks(),
        _loadProjects(),
        _loadUsers(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _taskService.fetchTasks(context);
      setState(() {
        _allTasks = tasks;
        _applyFilters();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load tasks: $e');
    }
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _projectService.fetchProjects();
      setState(() {
        _projects = projects.where((p) => !p.archived).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load projects: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _taskService.getAllAssignableUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load users: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<TaskModel> filtered = List.from(_allTasks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) =>
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query)).toList();
    }

    // Apply project filter
    if (_selectedProjectId != null) {
      filtered = filtered.where((task) => task.projectId == _selectedProjectId).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((task) => task.status == _selectedStatus).toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered.where((task) => task.priority == _selectedPriority).toList();
    }

    // Apply assignee filter
    if (_selectedAssigneeId != null) {
      filtered = filtered.where((task) => task.assigneeIds.contains(_selectedAssigneeId)).toList();
    }

    // Sort by priority and due date
    filtered.sort((a, b) {
      // First by priority (higher priority first)
      int priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      
      // Then by due date (earliest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      return 0;
    });

    setState(() {
      _filteredTasks = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedProjectId = null;
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedAssigneeId = null;
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TaskFilterBottomSheet(
        selectedProjectId: _selectedProjectId,
        selectedStatus: _selectedStatus,
        selectedPriority: _selectedPriority,
        selectedAssigneeId: _selectedAssigneeId,
        projects: _projects,
        users: _users,
        onFiltersChanged: (projectId, status, priority, assigneeId) {
          setState(() {
            _selectedProjectId = projectId;
            _selectedStatus = status;
            _selectedPriority = priority;
            _selectedAssigneeId = assigneeId;
            _applyFilters();
          });
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedProjectId != null ||
        _selectedStatus != null ||
        _selectedPriority != null ||
        _selectedAssigneeId != null;
  }

  void _sortByPriority() {
    setState(() {
      _filteredTasks.sort((a, b) => b.priority.compareTo(a.priority));
    });
  }

  void _sortByDueDate() {
    setState(() {
      _filteredTasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    });
  }

  void _handleTaskAction(String action, TaskModel task) {
    switch (action) {
      case 'edit':
        break;
      case 'delete':
        _showDeleteConfirmation(task);
        break;
    }
  }

  void _showDeleteConfirmation(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _taskService.deleteTask(context, task.id);
                await _loadTasks(); // Refresh the list
              } catch (e) {
                _showErrorSnackBar('Failed to delete task: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  // Updated navigation method
  void _navigateToTaskDetails(TaskModel task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: task.id),
      ),
    );
    
    // If task was deleted, refresh the list
    if (result == true) {
      await _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: TaskAppBar(
        onRefresh: _loadTasks,
        onClearFilters: _clearFilters,
        onSortByPriority: _sortByPriority,
        onSortByDueDate: _sortByDueDate,
      ),
      body: Column(
        children: [
          TaskSearchFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onFilterPressed: _showFilterBottomSheet,
          ),
          TaskFilterChips(
            selectedProjectId: _selectedProjectId,
            selectedStatus: _selectedStatus,
            selectedPriority: _selectedPriority,
            selectedAssigneeId: _selectedAssigneeId,
            projects: _projects,
            users: _users,
            hasActiveFilters: _hasActiveFilters(),
            onClearFilters: _clearFilters,
            onFilterChanged: (projectId, status, priority, assigneeId) {
              setState(() {
                if (projectId != null) _selectedProjectId = projectId;
                if (status != null) _selectedStatus = status;
                if (priority != null) _selectedPriority = priority;
                if (assigneeId != null) _selectedAssigneeId = assigneeId;
                _applyFilters();
              });
            },
          ),
          Expanded(
            child: _isLoading
                ? const TaskLoadingState()
                : _filteredTasks.isEmpty
                    ? TaskEmptyState(
                        hasSearchQuery: _searchQuery.isNotEmpty,
                        hasActiveFilters: _hasActiveFilters(),
                        onClearFilters: _clearFilters,
                      )
                    : TaskListView(
                        tasks: _filteredTasks,
                        projects: _projects,
                        users: _users,
                        onRefresh: _loadTasks,
                        onTaskTap: _navigateToTaskDetails,
                        onTaskAction: _handleTaskAction,
                      ),
          ),
        ],
      ),
    );
  }
}