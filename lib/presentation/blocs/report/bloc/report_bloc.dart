import 'package:delemon/presentation/blocs/report/bloc/report_event.dart';
import 'package:delemon/presentation/blocs/report/bloc/report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/report_model.dart';
import 'package:flutter/foundation.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ProjectService _projectService;
  final TaskService _taskService;
  final AuthService _authService;
  
  ReportsBloc({
    required ProjectService projectService,
    required TaskService taskService,
    required AuthService authService,
  }) : _projectService = projectService,
       _taskService = taskService,
       _authService = authService,
       super(ReportsInitial()) {
    
    on<LoadReportsEvent>(_onLoadReports);
    on<RefreshReportsEvent>(_onRefreshReports);
    on<SearchReportsEvent>(_onSearchReports);
    on<SelectProjectEvent>(_onSelectProject);
    on<ClearSearchEvent>(_onClearSearch);
  }
  
  Future<void> _onLoadReports(LoadReportsEvent event, Emitter<ReportsState> emit) async {
    final currentState = state;
    final currentReports = currentState is ReportsLoaded ? currentState.projectReports : <ProjectReport>[];
    
    emit(ReportsLoading(isInitialLoad: currentState is ReportsInitial, currentReports: currentReports));
    
    try {
      final results = await Future.wait([
        _fetchProjects(),
        _fetchUsers(),
      ]);
      
      final allProjects = results[0] as List<ProjectModel>;
      final usersMap = results[1] as Map<String, UserModel>;
      
      final projectReports = await _generateAllProjectReports(allProjects, usersMap);
      final filteredProjects = _filterProjects(projectReports, '');
      
      emit(ReportsLoaded(
        projectReports: projectReports,
        usersMap: usersMap,
        filteredProjects: filteredProjects,
      ));
      
    } catch (e) {
      emit(ReportsError(_formatError(e), currentReports: currentReports));
    }
  }
  
  Future<void> _onRefreshReports(RefreshReportsEvent event, Emitter<ReportsState> emit) async {
    add(LoadReportsEvent());
  }
  
  void _onSearchReports(SearchReportsEvent event, Emitter<ReportsState> emit) {
    final currentState = state;
    if (currentState is ReportsLoaded) {
      final filteredProjects = _filterProjects(currentState.projectReports, event.query);
      
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredProjects: filteredProjects,
        clearSelectedProject: true,
      ));
    }
  }
  
  void _onSelectProject(SelectProjectEvent event, Emitter<ReportsState> emit) {
    final currentState = state;
    if (currentState is ReportsLoaded) {
      ProjectReport? selectedProject;
      if (event.projectId != null) {
        try {
          selectedProject = currentState.projectReports.firstWhere(
            (p) => p.id == event.projectId
          );
        } catch (e) {
          selectedProject = null;
        }
      }
      
      emit(currentState.copyWith(
        selectedProjectId: event.projectId,
        selectedProject: selectedProject,
      ));
    }
  }
  
  void _onClearSearch(ClearSearchEvent event, Emitter<ReportsState> emit) {
    final currentState = state;
    if (currentState is ReportsLoaded) {
      final filteredProjects = _filterProjects(currentState.projectReports, '');
      
      emit(currentState.copyWith(
        searchQuery: '',
        filteredProjects: filteredProjects,
      ));
    }
  }
  
  Future<List<ProjectModel>> _fetchProjects() async {
    try {
      final projects = await _projectService.fetchProjects();
      return projects.where((project) => !project.archived).toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: ${e.toString()}');
    }
  }

  Future<Map<String, UserModel>> _fetchUsers() async {
    try {
      final users = await _authService.getAllUsers();
      return {for (var user in users) user.id: user};
    } catch (e) {
      debugPrint('Warning: Failed to fetch users: $e');
      return {}; 
    }
  }
  
  Future<List<ProjectReport>> _generateAllProjectReports(
    List<ProjectModel> allProjects, 
    Map<String, UserModel> usersMap
  ) async {
    if (allProjects.isEmpty) {
      return [];
    }

    final List<ProjectReport> reports = [];
    
    const batchSize = 5;
    for (int i = 0; i < allProjects.length; i += batchSize) {
      final batch = allProjects.skip(i).take(batchSize).toList();
      final batchReports = await _processBatchReports(batch, usersMap);
      reports.addAll(batchReports);
      
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    return reports;
  }

  Future<List<ProjectReport>> _processBatchReports(
    List<ProjectModel> projects, 
    Map<String, UserModel> usersMap
  ) async {
    try {
      final futures = projects.map((project) => _generateProjectReport(project, usersMap));
      return await Future.wait(futures);
    } catch (e) {
      final reports = <ProjectReport>[];
      for (final project in projects) {
        try {
          final report = await _generateProjectReport(project, usersMap);
          reports.add(report);
        } catch (e) {
          debugPrint('Failed to generate report for ${project.name}: $e');
          reports.add(ProjectReport.empty(project));
        }
      }
      return reports;
    }
  }

  Future<ProjectReport> _generateProjectReport(ProjectModel project, Map<String, UserModel> usersMap) async {
    try {
      final tasks = await _taskService.fetchTasksByProject(project.id);
      return _createProjectReport(project, tasks, usersMap);
    } catch (e) {
      debugPrint('Error generating report for project ${project.name}: $e');
      return ProjectReport.empty(project);
    }
  }

  ProjectReport _createProjectReport(
    ProjectModel project, 
    List<dynamic> tasks, 
    Map<String, UserModel> usersMap
  ) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.status == TaskStatus.done.index).length;
    final inProgressTasks = tasks.where((task) => task.status == TaskStatus.inProgress.index).length;
    final blockedTasks = tasks.where((task) => task.status == TaskStatus.blocked.index).length;
    
    final now = DateTime.now();
    final overdueTasks = tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(now) && 
      task.status != TaskStatus.done.index
    ).length;
    
    final completionPercentage = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0;
    final assigneeReports = _generateAssigneeReports(tasks, usersMap);
    
    return ProjectReport(
      id: project.id,
      name: project.name,
      description: project.description,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      blockedTasks: blockedTasks,
      overdueTasks: overdueTasks,
      completionPercentage: completionPercentage,
      assignees: assigneeReports,
      createdBy: project.createdBy,
      createdAt: project.createdAt,
      archived: project.archived,
    );
  }

  List<AssigneeReport> _generateAssigneeReports(List<dynamic> tasks, Map<String, UserModel> usersMap) {
    final Map<String, AssigneeTaskData> assigneeData = {};
    
    for (final task in tasks) {
      for (final assigneeId in task.assigneeIds) {
        assigneeData.putIfAbsent(assigneeId, () => AssigneeTaskData());
        
        assigneeData[assigneeId]!.totalTasks++;
        if (task.status == TaskStatus.done.index) {
          assigneeData[assigneeId]!.completedTasks++;
        }
      }
    }
    
    return assigneeData.entries.map((entry) {
      final userId = entry.key;
      final data = entry.value;
      final userName = usersMap[userId]?.name ?? 'Unknown User';
      
      return AssigneeReport(userName, data.totalTasks, data.completedTasks);
    }).toList();
  }
  
  List<ProjectReport> _filterProjects(List<ProjectReport> projectReports, String searchQuery) {
    if (searchQuery.isEmpty) {
      return projectReports.where((project) => !project.archived).toList();
    }
    
    final query = searchQuery.toLowerCase();
    return projectReports.where((project) {
      final matchesSearch = project.name.toLowerCase().contains(query) ||
                           project.description.toLowerCase().contains(query);
      return matchesSearch && !project.archived;
    }).toList();
  }
  
  String _formatError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}

class AssigneeTaskData {
  int totalTasks = 0;
  int completedTasks = 0;
}

