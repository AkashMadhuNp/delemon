import 'package:flutter/material.dart';
import 'package:delemon/data/models/project_model.dart';

class ProjectReport {
  final String id;
  final String name;
  final String description;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int blockedTasks;
  final int overdueTasks;
  final int completionPercentage;
  final List<AssigneeReport> assignees;
  final String createdBy;
  final DateTime createdAt;
  final bool archived;

  ProjectReport({
    required this.id,
    required this.name,
    required this.description,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.blockedTasks,
    required this.overdueTasks,
    required this.completionPercentage,
    required this.assignees,
    required this.createdBy,
    required this.createdAt,
    required this.archived,
  });

  factory ProjectReport.empty(ProjectModel project) {
    return ProjectReport(
      id: project.id,
      name: project.name,
      description: project.description,
      totalTasks: 0,
      completedTasks: 0,
      inProgressTasks: 0,
      blockedTasks: 0,
      overdueTasks: 0,
      completionPercentage: 0,
      assignees: [],
      createdBy: project.createdBy,
      createdAt: project.createdAt,
      archived: project.archived,
    );
  }
}

class AssigneeReport {
  final String name;
  final int totalTasks;
  final int completedTasks;

  AssigneeReport(this.name, this.totalTasks, this.completedTasks);
}

class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}

class AssigneeTaskData {
  int totalTasks = 0;
  int completedTasks = 0;
}

enum TaskStatus {
  todo,
  inProgress,
  blocked,
  inReview,
  done,
}
