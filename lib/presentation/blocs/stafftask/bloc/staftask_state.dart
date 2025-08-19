import 'package:equatable/equatable.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/domain/entities/task.dart';

enum StaffTaskStatus { initial, loading, success, error }

class StaffTaskState extends Equatable {
  final StaffTaskStatus status;
  final List<TaskModel> allTasks;
  final List<TaskModel> filteredTasks;
  final Map<String, ProjectModel> projects;
  final UserModel? currentUser;
  final String searchQuery;
  final TaskPriority? selectedPriority;
  final String sortBy;
  final int selectedTabIndex;
  final String? errorMessage;
  final double totalTimeSpent;

  const StaffTaskState({
    this.status = StaffTaskStatus.initial,
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.projects = const {},
    this.currentUser,
    this.searchQuery = '',
    this.selectedPriority,
    this.sortBy = 'dueDate',
    this.selectedTabIndex = 0,
    this.errorMessage,
    this.totalTimeSpent = 0.0,
  });

  StaffTaskState copyWith({
    StaffTaskStatus? status,
    List<TaskModel>? allTasks,
    List<TaskModel>? filteredTasks,
    Map<String, ProjectModel>? projects,
    UserModel? currentUser,
    String? searchQuery,
    TaskPriority? selectedPriority,
    String? sortBy,
    int? selectedTabIndex,
    String? errorMessage,
    double? totalTimeSpent,
  }) {
    return StaffTaskState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      projects: projects ?? this.projects,
      currentUser: currentUser ?? this.currentUser,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      sortBy: sortBy ?? this.sortBy,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
    );
  }

  int getTaskCountForTab(int tabIndex) {
    switch (tabIndex) {
      case 0: return allTasks.length;
      case 1: return allTasks.where((task) => task.status == TaskStatus.todo.index).length;
      case 2: return allTasks.where((task) => task.status == TaskStatus.inProgress.index).length;
      case 3: return allTasks.where((task) => task.status == TaskStatus.inReview.index).length;
      case 4: return allTasks.where((task) => 
        task.status == TaskStatus.completed.index || 
        task.status == TaskStatus.done.index
      ).length;
      case 5: return allTasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        task.status != TaskStatus.completed.index &&
        task.status != TaskStatus.done.index
      ).length;
      default: return 0;
    }
  }

  @override
  List<Object?> get props => [
        status,
        allTasks,
        filteredTasks,
        projects,
        currentUser,
        searchQuery,
        selectedPriority,
        sortBy,
        selectedTabIndex,
        errorMessage,
        totalTimeSpent,
      ];
}
