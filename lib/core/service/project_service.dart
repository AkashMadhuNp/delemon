import 'package:delemon/data/datasources/project_local_datasource.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final ProjectLocalDatasource _db = ProjectLocalDatasource();

  Future<UserModel?> _getCurrentUser() async {
    final userBox = await Hive.openBox<UserModel>('userBox');
    return userBox.get('currentUser');
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> createProject(BuildContext context, ProjectModel project) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) throw Exception("No user logged in!");

      final updatedProject = ProjectModel(
        id: project.id,
        name: project.name,
        description: project.description,
        createdBy: currentUser.name,
        archived: false,
        createdAt: project.createdAt,
        updatedAt: project.createdAt,
      );

      await _db.addProject(updatedProject);
      _showSnackBar(context, "✅ Project created successfully!", Colors.green);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to create project: $e", Colors.red);
    }
  }

  Future<void> updateProject(BuildContext context, ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      await _db.updateProject(updatedProject);
      _showSnackBar(context, "✅ Project updated successfully!", Colors.blue);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to update project: $e", Colors.red);
    }
  }

  Future<void> deleteProject(BuildContext context, String id) async {
    try {
      await _db.deleteProject(id);
      _showSnackBar(context, "🗑 Project deleted successfully", Colors.orange);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to delete project: $e", Colors.red);
    }
  }

  Future<void> toggleArchiveProject(BuildContext context, ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(
        archived: !project.archived,
        updatedAt: DateTime.now(),
      );
      await _db.updateProject(updatedProject);
      
      final message = updatedProject.archived 
          ? "📦 Project archived successfully" 
          : "📋 Project unarchived successfully";
      _showSnackBar(context, message, Colors.amber);
    } catch (e) {
      _showSnackBar(context, "❌ Failed to toggle archive: $e", Colors.red);
    }
  }

  Future<List<ProjectModel>> fetchProjects([BuildContext? context]) async {
    try {
      return await _db.getProjects();
    } catch (e) {
      if (context != null) {
        _showSnackBar(context, "⚠️ Failed to load projects: $e", Colors.orange);
      }
      return [];
    }
  }

  Future<ProjectModel?> getProject(String id) async {
    return await _db.getProject(id);
  }
}