import 'package:delemon/data/datasources/sub_task_local_datasource.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/data/datasources/task_local_datasource.dart';
import 'package:flutter/material.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final AuthService _authService = AuthService();
  final TaskLocalDatasource _taskDataSource = TaskLocalDatasource();
  final SubtaskLocalDatasource _subtaskDataSource = SubtaskLocalDatasource();

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<UserModel?> _getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  Future<void> createTask(BuildContext context, TaskModel task) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) throw Exception("No user logged in!");

      final updatedTask = TaskModel(
        id: task.id,
        projectId: task.projectId,
        title: task.title,
        description: task.description,
        status: task.status,
        priority: task.priority,
        startDate: task.startDate,
        dueDate: task.dueDate,
        estimateHours: task.estimateHours,
        timeSpentHours: task.timeSpentHours,
        assigneeIds: task.assigneeIds,
        createdBy: currentUser.id,
        createdAt: task.createdAt,
        updatedAt: task.createdAt, 
        subtaskIds: task.subtaskIds,
      );

      await _taskDataSource.createTask(updatedTask);
      
      _showSnackBar(context, "✅ Task created successfully!", Colors.green);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to create task: $e", Colors.red);
      rethrow;
    }
  }

  Future<void> updateTask(BuildContext context, TaskModel task) async {
    try {
      print("🔄 Starting task update: ${task.id} - Status: ${task.status}");
      
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      
      // Update in Hive
      await _taskDataSource.updateTask(updatedTask);
      
      // Verify the update was successful
      final verification = await _taskDataSource.verifyTaskStatusUpdate(task.id, task.status);
      
      if (verification) {
        _showSnackBar(context, "✅ Task updated successfully!", Colors.blue);
        print("✅ Task update completed and verified");
      } else {
        _showSnackBar(context, "⚠️ Task updated but verification failed", Colors.orange);
        print("⚠️ Task update verification failed");
      }
    } catch (e) {
      _showSnackBar(context, "❌ Failed to update task: $e", Colors.red);
      print("❌ Task update error: $e");
      rethrow;
    }
  }

  // New method specifically for updating task status
  Future<void> updateTaskStatus(BuildContext context, String taskId, int newStatus) async {
    try {
      print("🔄 Updating task status: $taskId to status $newStatus");
      
      // Get the current task
      final currentTask = await _taskDataSource.getTaskById(taskId);
      if (currentTask == null) {
        throw Exception("Task not found with ID: $taskId");
      }
      
      // Create updated task with new status
      final updatedTask = currentTask.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      
      // Update in Hive
      await _taskDataSource.updateTask(updatedTask);
      
      // Verify the update
      final verification = await _taskDataSource.verifyTaskStatusUpdate(taskId, newStatus);
      
      if (verification) {
        _showSnackBar(context, "✅ Task status updated successfully!", Colors.blue);
        print("✅ Task status update completed and verified");
      } else {
        _showSnackBar(context, "⚠️ Task status updated but verification failed", Colors.orange);
        print("⚠️ Task status update verification failed");
      }
    } catch (e) {
      _showSnackBar(context, "❌ Failed to update task status: $e", Colors.red);
      print("❌ Task status update error: $e");
      rethrow;
    }
  }

  Future<void> deleteTask(BuildContext context, String id) async {
    try {
      await _taskDataSource.deleteTask(id);
      
      _showSnackBar(context, "🗑 Task deleted successfully", Colors.orange);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to delete task: $e", Colors.red);
      rethrow;
    }
  }

  Future<List<TaskModel>> fetchTasks([BuildContext? context]) async {
    try {
      final tasks = await _taskDataSource.getAllTasks();
      print("📋 Fetched ${tasks.length} tasks from Hive");
      return tasks;
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load tasks: $e", Colors.orange);
      }
      print("❌ Error fetching tasks: $e");
      return [];
    }
  }

  Future<List<TaskModel>> fetchTasksByProject(String projectId, [BuildContext? context]) async {
    try {
      return await _taskDataSource.getTasksByProjectId(projectId);
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load project tasks: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<TaskModel?> getTask(String id) async {
    try {
      return await _taskDataSource.getTaskById(id);
    } catch (e) {
      print("❌ Failed to get task: $e");
      return null;
    }
  }

  Future<List<TaskModel>> getTasksByAssignee(String assigneeId, [BuildContext? context]) async {
    try {
      final tasks = await _taskDataSource.getTasksByAssigneeId(assigneeId);
      print("👤 Fetched ${tasks.length} tasks for assignee $assigneeId");
      return tasks;
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load assigned tasks: $e", Colors.orange);
      }
      print("❌ Error fetching tasks by assignee: $e");
      return [];
    }
  }

  Future<List<TaskModel>> getTasksByStatus(int status, [BuildContext? context]) async {
    try {
      final tasks = await _taskDataSource.getTasksByStatus(status);
      print("📊 Fetched ${tasks.length} tasks with status $status");
      return tasks;
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load tasks by status: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<List<TaskModel>> getTasksByPriority(int priority, [BuildContext? context]) async {
    try {
      return await _taskDataSource.getTasksByPriority(priority);
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load tasks by priority: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<List<TaskModel>> getOverdueTasks([BuildContext? context]) async {
    try {
      return await _taskDataSource.getOverdueTasks();
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load overdue tasks: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<List<TaskModel>> searchTasks(String query, [BuildContext? context]) async {
    try {
      return await _taskDataSource.searchTasks(query);
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to search tasks: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<List<TaskModel>> getTasksWithFilters({
    String? projectId,
    String? assigneeId,
    int? status,
    int? priority,
    String? searchQuery,
    BuildContext? context,
  }) async {
    try {
      return await _taskDataSource.getTasksWithFilters(
        projectId: projectId,
        assigneeId: assigneeId,
        status: status,
        priority: priority,
        searchQuery: searchQuery,
      );
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load filtered tasks: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<void> clearAllTasks(BuildContext context) async {
    try {
      await _taskDataSource.clearAllTasks();
      _showSnackBar(context, "🗑 All tasks cleared successfully", Colors.orange);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to clear tasks: $e", Colors.red);
      rethrow;
    }
  }

  Future<void> debugPrintAllTasksStatus() async {
    try {
      final tasksStatus = await _taskDataSource.getAllTasksWithStatus();
      print("🐛 DEBUG - All tasks status:");
      tasksStatus.forEach((id, data) {
        print("   $id: ${data['title']} - Status: ${data['status']} - Updated: ${data['updatedAt']}");
      });
    } catch (e) {
      print("❌ Debug print error: $e");
    }
  }

  Future<List<UserModel>> getStaffMembers() async {
    try {
      final allUsers = await _authService.getAllUsers();
      return allUsers.where((user) => user.role == UserRoleAdapter.staff).toList();
    } catch (e) {
      print("❌ Failed to fetch staff members: $e");
      return [];
    }
  }

  Future<List<UserModel>> getAllAssignableUsers() async {
    try {
      return await _authService.getAllUsers();
    } catch (e) {
      print("❌ Failed to fetch users: $e");
      return [];
    }
  }

  Future<void> dispose() async {
    try {
      await _taskDataSource.closeBox();
    } catch (e) {
      print("❌ Failed to close task box: $e");
    }
  }
}