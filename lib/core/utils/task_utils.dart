import 'package:flutter/material.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:intl/intl.dart';

class TaskUtils {
  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.inReview:
        return Colors.orange;
      case TaskStatus.done:
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.critical:
        return Colors.purple;
    }
  }

  static String getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return "To Do";
      case TaskStatus.inProgress:
        return "In Progress";
      case TaskStatus.blocked:
        return "Blocked";
      case TaskStatus.inReview:
        return "In Review";
      case TaskStatus.done:
        return "Done";
      case TaskStatus.completed:
        return "Completed";
    }
  }

  static String getPriorityDisplayName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return "Low";
      case TaskPriority.medium:
        return "Medium";
      case TaskPriority.high:
        return "High";
      case TaskPriority.critical:
        return "Critical";
    }
  }

  static Future<List<UserModel>> loadAssignees(
    List<String> assigneeIds, 
    TaskService taskService,
  ) async {
    if (assigneeIds.isEmpty) return [];
    
    try {
      final allUsers = await taskService.getAllAssignableUsers();
      return allUsers.where((user) => assigneeIds.contains(user.id)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<UserModel?> loadCreator(
    String creatorId, 
    TaskService taskService,
  ) async {
    try {
      final allUsers = await taskService.getAllAssignableUsers();
      return allUsers.firstWhere(
        (user) => user.id == creatorId,
        orElse: () => throw Exception('Creator not found'),
      );
    } catch (e) {
      return null;
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }
}
