import 'package:delemon/core/utils/task_utils.dart';
import 'package:delemon/data/models/task_model.dart';
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
    _tabController = TabController(length: 6, vsync: this); // Updated to 6 tabs
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
      // Get current user
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser == null) {
        throw Exception("No user logged in!");
      }

      // Load tasks assigned to current user
      final tasks = await _taskService.getTasksByAssignee(_currentUser!.id, context);
      
      // Load projects for task details
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

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.critical:
        return Icons.priority_high;
    }
  }

  List<TaskModel> get _filteredTasks {
    var tasks = _allTasks;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) =>
        task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        task.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (_projects[task.projectId]?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Filter by priority
    if (_selectedPriority != null) {
      tasks = tasks.where((task) => task.priority == _selectedPriority!.index).toList();
    }

    // Filter by tab (status)
    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0: // All tasks
        break;
      case 1: // To Do
        tasks = tasks.where((task) => task.status == TaskStatus.todo.index).toList();
        break;
      case 2: // In Progress
        tasks = tasks.where((task) => task.status == TaskStatus.inProgress.index).toList();
        break;
      case 3: // In Review
        tasks = tasks.where((task) => task.status == TaskStatus.inReview.index).toList();
        break;
      case 4: // Completed
        tasks = tasks.where((task) => 
          task.status == TaskStatus.completed.index || 
          task.status == TaskStatus.done.index
        ).toList();
        break;
      case 5: // Overdue
        tasks = tasks.where((task) => 
          task.dueDate != null && 
          task.dueDate!.isBefore(DateTime.now()) && 
          task.status != TaskStatus.completed.index &&
          task.status != TaskStatus.done.index
        ).toList();
        break;
    }

    // Sort tasks
    tasks.sort((a, b) {
      switch (_sortBy) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case 'priority':
          return b.priority.compareTo(a.priority); // High priority first
        case 'status':
          return a.status.compareTo(b.status);
        case 'created':
          return b.createdAt.compareTo(a.createdAt); // Newest first
        default:
          return 0;
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
    final availableStatuses = [
      TaskStatus.todo,
      TaskStatus.inProgress,
      TaskStatus.inReview,
      TaskStatus.completed,
      TaskStatus.blocked,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Task Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change status for: ${task.title}'),
            const SizedBox(height: 16),
            ...availableStatuses.map((status) {
              return ListTile(
                leading: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: TaskUtils.getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(TaskUtils.getStatusDisplayName(status)),
                onTap: () {
                  Navigator.pop(context);
                  _updateTaskStatus(task, status);
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final project = _projects[task.projectId];
    final isOverdue = task.dueDate != null && 
                     task.dueDate!.isBefore(DateTime.now()) && 
                     task.status != TaskStatus.completed &&
                     task.status != TaskStatus.done;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTaskStatusDialog(task),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: (task.status == TaskStatus.completed || task.status == TaskStatus.done) 
                            ? TextDecoration.lineThrough : null,
                        color: (task.status == TaskStatus.completed || task.status == TaskStatus.done) 
                            ? Colors.grey : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TaskUtils.getPriorityColor(task.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TaskUtils.getPriorityColor(task.priority).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPriorityIcon(task.priority),
                          size: 16,
                          color: TaskUtils.getPriorityColor(task.priority),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          TaskUtils.getPriorityDisplayName(task.priority),
                          style: TextStyle(
                            fontSize: 12,
                            color: TaskUtils.getPriorityColor(task.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Project name
              if (project != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Description
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // Bottom row with status, due date, and time info
              Row(
                children: [
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: TaskUtils.getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TaskUtils.getStatusColor(task.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      TaskUtils.getStatusDisplayName(task.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: TaskUtils.getStatusColor(task.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Due date
                  if (task.dueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOverdue ? Icons.warning : Icons.schedule,
                            size: 14,
                            color: isOverdue ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              // Time tracking info
              if (task.estimateHours > 0 || task.timeSpentHours > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      if (task.estimateHours > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Est: ${task.estimateHours}h',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      if (task.estimateHours > 0 && task.timeSpentHours > 0)
                        const SizedBox(width: 8),
                      if (task.timeSpentHours > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Spent: ${task.timeSpentHours}h',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
              // Assignees
              if (task.assigneeIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FutureBuilder<List<UserModel>>(
                    future: TaskUtils.loadAssignees(task.assigneeIds, _taskService),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return Wrap(
                          spacing: 4,
                          children: snapshot.data!.map((user) => 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          ).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Priority filter
          Expanded(
            child: DropdownButtonFormField<TaskPriority?>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Priorities')),
                ...TaskPriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority), 
                        size: 16, 
                        color: TaskUtils.getPriorityColor(priority)
                      ),
                      const SizedBox(width: 8),
                      Text(TaskUtils.getPriorityDisplayName(priority)),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Sort dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'dueDate', child: Text('Due Date')),
                DropdownMenuItem(value: 'priority', child: Text('Priority')),
                DropdownMenuItem(value: 'status', child: Text('Status')),
                DropdownMenuItem(value: 'created', child: Text('Created Date')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value ?? 'dueDate';
                });
              },
            ),
          ),
        ],
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
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks or projects...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                
                // Filter row
                _buildFilterRow(),
                
                // Task list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(6, (index) {
                      final filteredTasks = _filteredTasks;
                      
                      if (filteredTasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, taskIndex) {
                            return _buildTaskCard(filteredTasks[taskIndex].toEntity());
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