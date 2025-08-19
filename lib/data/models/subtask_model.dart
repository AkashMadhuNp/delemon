import 'package:hive/hive.dart';
part 'subtask_model.g.dart';

@HiveType(typeId: 5) 
class SubtaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
    final DateTime createdAt;


  @HiveField(6)
    final DateTime updatedAt;


  @HiveField(7)
    final int order; 


  

  const SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    bool? isCompleted,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }

  
  SubtaskModel toggleCompleted() {
    return copyWith(
      isCompleted: !isCompleted,
      updatedAt: DateTime.now(),
    );
  }
}
