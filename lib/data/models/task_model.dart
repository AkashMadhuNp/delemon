
import 'package:delemon/domain/entities/task.dart';
import 'package:hive/hive.dart';
part 'task_model.g.dart';

@HiveType(typeId: 4) 
class TaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final int status; 

  @HiveField(5)
  final int priority;

  @HiveField(6)
  final DateTime? startDate;

  @HiveField(7)
  final DateTime? dueDate;

  @HiveField(8)
  final double estimateHours;

  @HiveField(9)
  final double timeSpentHours;

  @HiveField(10)
  final List<String> subtaskIds; 

  @HiveField(11)
  final List<String> assigneeIds;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  @HiveField(14)
  final String createdBy;

  const TaskModel({
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

    static TaskModel fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status.index,     
      priority: task.priority.index, 
      startDate: task.startDate,
      dueDate: task.dueDate,
      estimateHours: task.estimateHours,
      timeSpentHours: task.timeSpentHours,
      subtaskIds: task.subtaskIds,
      assigneeIds: task.assigneeIds,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      createdBy: task.createdBy,
    );
  }

  TaskModel copyWith({
  String? id,
  String? projectId,
  String? title,
  String? description,
  int? status,
  int? priority,
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
  return TaskModel(
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


Task toEntity() {
  return Task(
    id: id,
    projectId: projectId,
    title: title,
    description: description,
    status: TaskStatus.values[status],
    priority: TaskPriority.values[priority],
    startDate: startDate,
    dueDate: dueDate,
    estimateHours: estimateHours,
    timeSpentHours: timeSpentHours,
    subtaskIds: subtaskIds,
    assigneeIds: assigneeIds,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
  );
}

}
