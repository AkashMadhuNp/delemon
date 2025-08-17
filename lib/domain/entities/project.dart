class Project {
  final String id;
  final String name;
  final String description;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  
}