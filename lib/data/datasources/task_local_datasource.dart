import 'package:delemon/data/datasources/sub_task_local_datasource.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:hive/hive.dart';

class TaskLocalDatasource {
  static const String _boxName = "taskBox";
  final SubtaskLocalDatasource _subtaskDatasource = SubtaskLocalDatasource();

  Future<Box<TaskModel>> _openBox() async {
    return await Hive.openBox<TaskModel>(_boxName);
  }

  Future<void> createTask(TaskModel task) async {
    final box = await _openBox();
    await box.put(task.id, task);
    
    // Debug log
    print("✅ Task created in Hive: ${task.id} - ${task.title}");
  }

  Future<List<TaskModel>> getAllTasks() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<List<TaskModel>> getTasksByProjectId(String projectId) async {
    final box = await _openBox();
    return box.values.where((task) => task.projectId == projectId).toList();
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    final box = await _openBox();
    return box.get(taskId);
  }

  Future<void> updateTask(TaskModel task) async {
    final box = await _openBox();
    await box.put(task.id, task);
    
    // Debug log
    print("✅ Task updated in Hive: ${task.id} - Status: ${task.status} - ${task.title}");
    
    // Verify the update was successful
    final updatedTask = box.get(task.id);
    if (updatedTask != null) {
      print("✅ Verification: Task status in Hive is now: ${updatedTask.status}");
    } else {
      print("❌ Warning: Task not found after update!");
    }
  }

  Future<void> deleteTask(String taskId) async {
    final box = await _openBox();
    
    // Also delete all associated subtasks
    await _subtaskDatasource.deleteSubtasksByTaskId(taskId);
    
    await box.delete(taskId);
    
    // Debug log
    print("🗑️ Task deleted from Hive: $taskId");
  }

  Future<List<TaskModel>> getTasksByAssigneeId(String assigneeId) async {
    final box = await _openBox();
    return box.values
        .where((task) => task.assigneeIds.contains(assigneeId))
        .toList();
  }

  Future<List<TaskModel>> getTasksByStatus(int status) async {
    final box = await _openBox();
    final tasks = box.values.where((task) => task.status == status).toList();
    
    // Debug log
    print("📊 Found ${tasks.length} tasks with status $status");
    
    return tasks;
  }

  Future<List<TaskModel>> getTasksByPriority(int priority) async {
    final box = await _openBox();
    return box.values.where((task) => task.priority == priority).toList();
  }

  // Fixed the overdue tasks method - changed from status != 4 to status != 2
  Future<List<TaskModel>> getOverdueTasks() async {
    final box = await _openBox();
    final now = DateTime.now();
    final overdueTasks = box.values
        .where((task) => 
            task.dueDate != null && 
            task.dueDate!.isBefore(now) && 
            task.status != 2) // Changed from 4 to 2 (Completed status)
        .toList();
    
    // Debug log
    print("⏰ Found ${overdueTasks.length} overdue tasks");
    
    return overdueTasks;
  }

  Future<List<TaskModel>> searchTasks(String query) async {
    final box = await _openBox();
    final lowerQuery = query.toLowerCase();
    return box.values
        .where((task) =>
            task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<List<TaskModel>> getTasksWithFilters({
    String? projectId,
    String? assigneeId,
    int? status,
    int? priority,
    String? searchQuery,
  }) async {
    final box = await _openBox();
    var tasks = box.values.toList();

    if (projectId != null) {
      tasks = tasks.where((task) => task.projectId == projectId).toList();
    }

    if (assigneeId != null) {
      tasks = tasks
          .where((task) => task.assigneeIds.contains(assigneeId))
          .toList();
    }

    if (status != null) {
      tasks = tasks.where((task) => task.status == status).toList();
    }

    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      tasks = tasks
          .where((task) =>
              task.title.toLowerCase().contains(lowerQuery) ||
              task.description.toLowerCase().contains(lowerQuery))
          .toList();
    }

    // Debug log
    print("🔍 Filtered tasks result: ${tasks.length} tasks found");

    return tasks;
  }

  // New method to get task with its subtasks
  Future<Map<String, dynamic>?> getTaskWithSubtasks(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) return null;

    final subtasks = await _subtaskDatasource.getSubtasksByIds(task.subtaskIds);
    
    return {
      'task': task,
      'subtasks': subtasks,
    };
  }

  // Method to verify task status update
  Future<bool> verifyTaskStatusUpdate(String taskId, int expectedStatus) async {
    final box = await _openBox();
    final task = box.get(taskId);
    
    if (task != null) {
      final isCorrect = task.status == expectedStatus;
      print("✅ Status verification for $taskId: Expected $expectedStatus, Got ${task.status}, Correct: $isCorrect");
      return isCorrect;
    }
    
    print("❌ Task $taskId not found during verification");
    return false;
  }

  // Method to get all tasks with their current status (for debugging)
  Future<Map<String, Map<String, dynamic>>> getAllTasksWithStatus() async {
    final box = await _openBox();
    final result = <String, Map<String, dynamic>>{};
    
    for (final task in box.values) {
      result[task.id] = {
        'title': task.title,
        'status': task.status,
        'updatedAt': task.updatedAt,
      };
    }
    
    return result;
  }

  Future<void> clearAllTasks() async {
    final box = await _openBox();
    await _subtaskDatasource.clearAllSubtasks(); 
    await box.clear();
    
    // Debug log
    print("🗑️ All tasks cleared from Hive");
  } 

  Future<void> closeBox() async {
    final box = await _openBox();
    await _subtaskDatasource.closeBox(); 
    await box.close();
  }
}