import 'package:flutter/material.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/data/models/project_model.dart';

enum ProjectFilter { all, active, archived }

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  ProjectFilter _selectedFilter = ProjectFilter.all;
  bool _isLoading = true;
  String _searchQuery = '';

  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get filteredProjects => _filteredProjects;
  ProjectFilter get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int get totalProjectsCount => _projects.length;
  int get activeProjectsCount => _projects.where((p) => !p.archived).length;
  int get archivedProjectsCount => _projects.where((p) => p.archived).length;

  Future<void> loadProjects(BuildContext context) async {
    _setLoading(true);
    
    try {
      final fetchedProjects = await _projectService.fetchProjects();
      _projects = fetchedProjects;
      _applyFiltersAndSearch();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _showError(context, 'Error loading projects: $e');
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFiltersAndSearch();
  }

  void updateFilter(ProjectFilter filter) {
    _selectedFilter = filter;
    _applyFiltersAndSearch();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFiltersAndSearch();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedFilter = ProjectFilter.all;
    _applyFiltersAndSearch();
  }

  Future<void> deleteProject(BuildContext context, ProjectModel project) async {
    try {
      await _projectService.deleteProject(project.id);
      await loadProjects(context);
      _showSuccessMessage(context, "🗑 Project deleted successfully");
    } catch (e) {
      _showError(context, 'Error deleting project: $e');
    }
  }

  Future<void> toggleArchive(BuildContext context, ProjectModel project) async {
    try {
      await _projectService.toggleArchiveProject(project);
      await loadProjects(context);
      final message = project.archived 
          ? "📋 Project unarchived successfully" 
          : "📦 Project archived successfully";
      _showSuccessMessage(context, message);
    } catch (e) {
      _showError(context, 'Error updating project: $e');
    }
  }

  void _applyFiltersAndSearch() {
    List<ProjectModel> filtered = List.from(_projects);

  switch (_selectedFilter) {
      case ProjectFilter.active:
        filtered = filtered.where((p) => !p.archived).toList();
        break;
      case ProjectFilter.archived:
        filtered = filtered.where((p) => p.archived).toList();
        break;
      case ProjectFilter.all:
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((project) {
        return project.name.toLowerCase().contains(_searchQuery) ||
               project.description.toLowerCase().contains(_searchQuery) ||
               project.createdBy.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Sort projects (active first, then by creation date)
    filtered.sort((a, b) {
      if (a.archived != b.archived) {
        return a.archived ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    _filteredProjects = filtered;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}