import 'package:delemon/domain/entities/project.dart';
import 'package:hive/hive.dart';
part 'project_model.g.dart';

@HiveType(typeId: 3)
class ProjectModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool archived;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final String createdBy;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Add copyWith method
  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Project toEntity() => Project(
    id: id,
    name: name,
    description: description,
    archived: archived,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
  );

  factory ProjectModel.fromEntity(Project project) => ProjectModel(
    id: project.id,
    name: project.name,
    description: project.description,
    archived: project.archived,
    createdAt: project.createdAt,
    updatedAt: project.updatedAt,
    createdBy: project.createdBy,
  );
}