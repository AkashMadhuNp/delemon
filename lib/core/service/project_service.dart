import 'package:delemon/data/datasources/project_local_datasource.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:hive/hive.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final ProjectLocalDatasource _db = ProjectLocalDatasource();

  Future<UserModel?> _getCurrentUser() async {
    try {
      final userBox = await Hive.openBox<UserModel>('userBox');
      return userBox.get('currentUser');
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) {
        throw Exception("No user logged in!");
      }

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
      return updatedProject;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(updatedAt: DateTime.now());
      await _db.updateProject(updatedProject);
      return updatedProject;
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _db.deleteProject(id);
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  Future<ProjectModel> toggleArchiveProject(ProjectModel project) async {
    try {
      final updatedProject = project.copyWith(
        archived: !project.archived,
        updatedAt: DateTime.now(),
      );
      await _db.updateProject(updatedProject);
      return updatedProject;
    } catch (e) {
      throw Exception('Failed to toggle archive: $e');
    }
  }

  Future<List<ProjectModel>> fetchProjects() async {
    try {
      return await _db.getProjects();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  Future<ProjectModel?> getProject(String id) async {
    try {
      return await _db.getProject(id);
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  Future<List<ProjectModel>> getActiveProjects() async {
    try {
      final projects = await fetchProjects();
      return projects.where((project) => !project.archived).toList();
    } catch (e) {
      throw Exception('Failed to get active projects: $e');
    }
  }

  Future<List<ProjectModel>> getArchivedProjects() async {
    try {
      final projects = await fetchProjects();
      return projects.where((project) => project.archived).toList();
    } catch (e) {
      throw Exception('Failed to get archived projects: $e');
    }
  }

  Future<List<ProjectModel>> searchProjects(String query) async {
    try {
      final projects = await fetchProjects();
      final searchQuery = query.toLowerCase();
      
      return projects.where((project) {
        return project.name.toLowerCase().contains(searchQuery) ||
               project.description.toLowerCase().contains(searchQuery) ||
               project.createdBy.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search projects: $e');
    }
  }

  Future<int> getProjectsCount({bool? archived}) async {
    try {
      final projects = await fetchProjects();
      if (archived == null) return projects.length;
      return projects.where((p) => p.archived == archived).length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<ProjectModel>> getProjectsByUser(String userName) async {
    try {
      final projects = await fetchProjects();
      return projects.where((project) => 
        project.createdBy.toLowerCase() == userName.toLowerCase()).toList();
    } catch (e) {
      throw Exception('Failed to get projects by user: $e');
    }
  }

  // Batch operations
  Future<void> deleteMultipleProjects(List<String> projectIds) async {
    try {
      for (final id in projectIds) {
        await _db.deleteProject(id);
      }
    } catch (e) {
      throw Exception('Failed to delete multiple projects: $e');
    }
  }

  Future<void> archiveMultipleProjects(List<String> projectIds) async {
    try {
      for (final id in projectIds) {
        final project = await getProject(id);
        if (project != null) {
          await toggleArchiveProject(project);
        }
      }
    } catch (e) {
      throw Exception('Failed to archive multiple projects: $e');
    }
  }

  // Validation methods
  Future<bool> projectExists(String id) async {
    try {
      final project = await getProject(id);
      return project != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isProjectNameUnique(String name, {String? excludeId}) async {
    try {
      final projects = await fetchProjects();
      return !projects.any((project) => 
        project.name.toLowerCase() == name.toLowerCase() && 
        project.id != excludeId);
    } catch (e) {
      return false;
    }
  }

  // Statistics methods
  Future<Map<String, int>> getProjectStatistics() async {
    try {
      final projects = await fetchProjects();
      return {
        'total': projects.length,
        'active': projects.where((p) => !p.archived).length,
        'archived': projects.where((p) => p.archived).length,
      };
    } catch (e) {
      return {'total': 0, 'active': 0, 'archived': 0};
    }
  }

  Future<List<ProjectModel>> getRecentProjects({int limit = 5}) async {
    try {
      final projects = await fetchProjects();
      projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return projects.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get recent projects: $e');
    }
  }
}