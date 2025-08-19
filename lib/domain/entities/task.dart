enum TaskStatus {
  todo,
  inProgress,
  blocked,
  inReview,
  completed,
  done, 
}

enum TaskPriority {
  low,
  medium,
  high,
  critical,
}

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? startDate;
  final DateTime? dueDate;
  final double estimateHours;
  final double timeSpentHours;
  final List<String> subtaskIds;   
  final List<String> assigneeIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.startDate,
    this.dueDate,
    required this.estimateHours,
    required this.timeSpentHours,
    required this.subtaskIds,
    required this.assigneeIds,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? dueDate,
    double? estimateHours,
    double? timeSpentHours,
    List<String>? subtaskIds,
    List<String>? assigneeIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      estimateHours: estimateHours ?? this.estimateHours,
      timeSpentHours: timeSpentHours ?? this.timeSpentHours,
      subtaskIds: subtaskIds ?? this.subtaskIds,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
