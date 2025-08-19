import 'package:equatable/equatable.dart';
import 'package:delemon/domain/entities/report_model.dart';
import 'package:delemon/data/models/user_model.dart';

abstract class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {
  final bool isInitialLoad;
  final List<ProjectReport> currentReports;
  
  ReportsLoading({
    this.isInitialLoad = true, 
    this.currentReports = const []
  });
  
  @override
  List<Object?> get props => [isInitialLoad, currentReports];
}

class ReportsLoaded extends ReportsState {
  final List<ProjectReport> projectReports;
  final Map<String, UserModel> usersMap;
  final String searchQuery;
  final String? selectedProjectId;
  final List<ProjectReport> filteredProjects;
  final ProjectReport? selectedProject;
  
  ReportsLoaded({
    required this.projectReports,
    required this.usersMap,
    this.searchQuery = '',
    this.selectedProjectId,
    required this.filteredProjects,
    this.selectedProject,
  });
  
  @override
  List<Object?> get props => [
    projectReports, 
    usersMap, 
    searchQuery, 
    selectedProjectId, 
    filteredProjects,
    selectedProject
  ];
  
  ReportsLoaded copyWith({
    List<ProjectReport>? projectReports,
    Map<String, UserModel>? usersMap,
    String? searchQuery,
    String? selectedProjectId,
    List<ProjectReport>? filteredProjects,
    ProjectReport? selectedProject,
    bool clearSelectedProject = false,
  }) {
    return ReportsLoaded(
      projectReports: projectReports ?? this.projectReports,
      usersMap: usersMap ?? this.usersMap,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedProjectId: clearSelectedProject ? null : (selectedProjectId ?? this.selectedProjectId),
      filteredProjects: filteredProjects ?? this.filteredProjects,
      selectedProject: clearSelectedProject ? null : (selectedProject ?? this.selectedProject),
    );
  }
}

class ReportsError extends ReportsState {
  final String message;
  final List<ProjectReport> currentReports;
  
  ReportsError(this.message, {this.currentReports = const []});
  
  @override
  List<Object?> get props => [message, currentReports];
}
