import 'package:delemon/presentation/blocs/stafftask/bloc/staftask_event.dart';
import 'package:delemon/presentation/blocs/stafftask/bloc/staftask_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/domain/entities/task.dart';

class StaffTaskBloc extends Bloc<StaffTaskEvent, StaffTaskState> {
  final TaskService _taskService;
  final ProjectService _projectService;
  final AuthService _authService;
  final BuildContext context;

  StaffTaskBloc({
    required TaskService taskService,
    required ProjectService projectService,
    required AuthService authService,
    required this.context,
  })  : _taskService = taskService,
        _projectService = projectService,
        _authService = authService,
        super(const StaffTaskState()) {
    
    on<LoadStaffTasks>(_onLoadStaffTasks);
    on<RefreshStaffTasks>(_onRefreshStaffTasks);
    on<SearchTasks>(_onSearchTasks);
    on<FilterByPriority>(_onFilterByPriority);
    on<SortTasks>(_onSortTasks);
    on<FilterByTab>(_onFilterByTab);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
  }

  Future<void> _onLoadStaffTasks(
    LoadStaffTasks event,
    Emitter<StaffTaskState> emit,
  ) async {
    emit(state.copyWith(status: StaffTaskStatus.loading));
    
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No user logged in!");
      }

      final tasks = await _taskService.getTasksByAssignee(currentUser.id, context);
      final projects = await _projectService.fetchProjects();
      final projectMap = <String, ProjectModel>{};
      for (final project in projects) {
        projectMap[project.id] = project;
      }

      final totalTimeSpent = tasks.fold(0.0, (sum, task) => sum + task.timeSpentHours);
      final filteredTasks = _applyFilters(tasks);

      emit(state.copyWith(
        status: StaffTaskStatus.success,
        allTasks: tasks,
        filteredTasks: filteredTasks,
        projects: projectMap,
        currentUser: currentUser,
        totalTimeSpent: totalTimeSpent,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StaffTaskStatus.error,
        errorMessage: 'Failed to load tasks: $e',
      ));
    }
  }

  Future<void> _onRefreshStaffTasks(
    RefreshStaffTasks event,
    Emitter<StaffTaskState> emit,
  ) async {
    add(LoadStaffTasks());
  }

  void _onSearchTasks(
    SearchTasks event,
    Emitter<StaffTaskState> emit,
  ) {
    final filteredTasks = _applyFilters(state.allTasks, searchQuery: event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredTasks: filteredTasks,
    ));
  }

  void _onFilterByPriority(
    FilterByPriority event,
    Emitter<StaffTaskState> emit,
  ) {
    final filteredTasks = _applyFilters(state.allTasks, selectedPriority: event.priority);
    emit(state.copyWith(
      selectedPriority: event.priority,
      filteredTasks: filteredTasks,
    ));
  }

  void _onSortTasks(
    SortTasks event,
    Emitter<StaffTaskState> emit,
  ) {
    final filteredTasks = _applyFilters(state.allTasks, sortBy: event.sortBy);
    emit(state.copyWith(
      sortBy: event.sortBy,
      filteredTasks: filteredTasks,
    ));
  }

  void _onFilterByTab(
    FilterByTab event,
    Emitter<StaffTaskState> emit,
  ) {
    final filteredTasks = _applyFilters(state.allTasks, tabIndex: event.tabIndex);
    emit(state.copyWith(
      selectedTabIndex: event.tabIndex,
      filteredTasks: filteredTasks,
    ));
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<StaffTaskState> emit,
  ) async {
    try {
      await _taskService.updateTaskStatus(context, event.task.id, event.newStatus.index);
      add(RefreshStaffTasks());
    } catch (e) {
      emit(state.copyWith(
        status: StaffTaskStatus.error,
        errorMessage: 'Failed to update task: $e',
      ));
    }
  }

  List<TaskModel> _applyFilters(
    List<TaskModel> tasks, {
    String? searchQuery,
    TaskPriority? selectedPriority,
    String? sortBy,
    int? tabIndex,
  }) {
    var filteredTasks = List<TaskModel>.from(tasks);
    final query = searchQuery ?? state.searchQuery;
    final priority = selectedPriority ?? state.selectedPriority;
    final sort = sortBy ?? state.sortBy;
    final tab = tabIndex ?? state.selectedTabIndex;

    // Apply search filter
    if (query.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) =>
        task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase()) ||
        (state.projects[task.projectId]?.name.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }

    // Apply priority filter
    if (priority != null) {
      filteredTasks = filteredTasks.where((task) => task.priority == priority.index).toList();
    }

    // Apply tab filter
    switch (tab) {
      case 0: break; // All tasks
      case 1: filteredTasks = filteredTasks.where((task) => task.status == TaskStatus.todo.index).toList(); break;
      case 2: filteredTasks = filteredTasks.where((task) => task.status == TaskStatus.inProgress.index).toList(); break;
      case 3: filteredTasks = filteredTasks.where((task) => task.status == TaskStatus.inReview.index).toList(); break;
      case 4: filteredTasks = filteredTasks.where((task) => 
        task.status == TaskStatus.completed.index || 
        task.status == TaskStatus.done.index
      ).toList(); break;
      case 5: filteredTasks = filteredTasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) && 
        task.status != TaskStatus.completed.index &&
        task.status != TaskStatus.done.index
      ).toList(); break;
    }

    // Apply sorting
    filteredTasks.sort((a, b) {
      switch (sort) {
        case 'dueDate':
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case 'priority': return b.priority.compareTo(a.priority);
        case 'status': return a.status.compareTo(b.status);
        case 'created': return b.createdAt.compareTo(a.createdAt);
        default: return 0;
      }
    });

    return filteredTasks;
  }
}
