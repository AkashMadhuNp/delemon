import 'package:flutter/material.dart';

enum TaskStatus {
  notStarted(0, 'Not Started', Colors.grey),
  inProgress(1, 'In Progress', Colors.blue),
  completed(2, 'Completed', Colors.green),
  cancelled(3, 'Cancelled', Colors.red),
  blocked(4, 'Blocked', Colors.orange);

  const TaskStatus(this.value, this.label, this.color);

  final int value;
  final String label;
  final Color color;

  static TaskStatus fromValue(int value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.notStarted,
    );
  }

  static List<TaskStatus> getSelectableStatuses({bool includeBlocked = false}) {
    List<TaskStatus> statuses = [
      TaskStatus.notStarted,
      TaskStatus.inProgress,
      TaskStatus.completed,
    ];
    
    if (includeBlocked) {
      statuses.add(TaskStatus.blocked);
    }
    
    return statuses;
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.notStarted:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.autorenew;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
      case TaskStatus.blocked:
        return Icons.block;
    }
  }

  bool get isCompleted => this == TaskStatus.completed;
  bool get isActive => this == TaskStatus.inProgress || this == TaskStatus.notStarted;
  bool get isClosed => this == TaskStatus.completed || this == TaskStatus.cancelled;
}

enum TaskPriority {
  low(0, 'Low', Colors.green),
  medium(1, 'Medium', Colors.orange),
  high(2, 'High', Colors.red),
  critical(3, 'Critical', Colors.purple);

  const TaskPriority(this.value, this.label, this.color);

  final int value;
  final String label;
  final Color color;

  static TaskPriority fromValue(int value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => TaskPriority.low,
    );
  }

  IconData get icon {
    switch (this) {
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
}
