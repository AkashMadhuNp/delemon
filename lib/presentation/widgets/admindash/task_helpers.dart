// lib/presentation/admin/widgets/task_helpers.dart
import 'package:delemon/domain/entities/task.dart';
import 'package:flutter/material.dart';

class TaskHelpers {
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
        return "completed";
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

  static IconData getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.blocked:
        return Icons.block;
      case TaskStatus.inReview:
        return Icons.rate_review;
      case TaskStatus.done:
        return Icons.check_circle;
      
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }

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
        return Colors.green;
      
      case TaskStatus.completed:
                return Colors.green;

    }
  }
}