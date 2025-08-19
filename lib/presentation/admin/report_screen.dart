import 'package:delemon/domain/entities/report_model.dart';
import 'package:delemon/presentation/widgets/report/empty_project_state.dart';
import 'package:delemon/presentation/widgets/report/error_state.dart';
import 'package:delemon/presentation/widgets/report/loading_state.dart';
import 'package:delemon/presentation/widgets/report/project_detail_view.dart';
import 'package:delemon/presentation/widgets/report/project_overview_grid.dart';
import 'package:delemon/presentation/widgets/report/report_header.dart';
import 'package:delemon/presentation/widgets/report/search_filter_section.dart';
import 'package:flutter/material.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ProjectService _projectService = ProjectService();
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  
  String _searchQuery = '';
  String? _selectedProject;
  late AnimationController _animationController;
  
  List<ProjectModel> _allProjects = [];
  List<ProjectReport> _projectReports = [];
  Map<String, UserModel> _usersMap = {};
  
  bool _isLoading = false;
  bool _isInitialLoad = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  /// Load all necessary data for reports
  Future<void> _loadInitialData() async {
    await _loadReportsData();
  }

  /// Main method to load reports data with proper error handling
  Future<void> _loadReportsData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      if (_isInitialLoad) {
        _error = null;
      }
    });

    try {
      // Load all required data concurrently for better performance
      await _loadAllRequiredData();
      
      // Generate reports after all data is loaded
      await _generateAllProjectReports();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = null;
          _isInitialLoad = false;
        });
        
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _formatError(e);
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    }
  }

  /// Load all required data concurrently
  Future<void> _loadAllRequiredData() async {
    try {
      final results = await Future.wait([
        _fetchProjects(),
        _fetchUsers(),
      ]);
      
      _allProjects = results[0] as List<ProjectModel>;
      _usersMap = results[1] as Map<String, UserModel>;
      
    } catch (e) {
      throw Exception('Failed to load initial data: ${e.toString()}');
    }
  }

  /// Fetch projects with error handling
  Future<List<ProjectModel>> _fetchProjects() async {
    try {
      final projects = await _projectService.fetchProjects();
      return projects.where((project) => !project.archived).toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: ${e.toString()}');
    }
  }

  /// Fetch users and convert to map for efficient lookup
  Future<Map<String, UserModel>> _fetchUsers() async {
    try {
      final users = await _authService.getAllUsers();
      return {for (var user in users) user.id: user};
    } catch (e) {
      debugPrint('Warning: Failed to fetch users: $e');
      return {}; // Return empty map instead of throwing to allow partial functionality
    }
  }

  /// Generate reports for all projects
  Future<void> _generateAllProjectReports() async {
    if (_allProjects.isEmpty) {
      _projectReports = [];
      return;
    }

    final List<ProjectReport> reports = [];
    
    // Process projects in batches to avoid overwhelming the system
    const batchSize = 5;
    for (int i = 0; i < _allProjects.length; i += batchSize) {
      final batch = _allProjects.skip(i).take(batchSize).toList();
      final batchReports = await _processBatchReports(batch);
      reports.addAll(batchReports);
      
      // Allow UI to update between batches
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
    
    _projectReports = reports;
  }

  /// Process a batch of project reports concurrently
  Future<List<ProjectReport>> _processBatchReports(List<ProjectModel> projects) async {
    try {
      final futures = projects.map((project) => _generateProjectReport(project));
      return await Future.wait(futures);
    } catch (e) {
      // If batch processing fails, process individually
      final reports = <ProjectReport>[];
      for (final project in projects) {
        try {
          final report = await _generateProjectReport(project);
          reports.add(report);
        } catch (e) {
          debugPrint('Failed to generate report for ${project.name}: $e');
          reports.add(ProjectReport.empty(project));
        }
      }
      return reports;
    }
  }

  /// Generate individual project report with improved error handling
  Future<ProjectReport> _generateProjectReport(ProjectModel project) async {
    try {
      final tasks = await _taskService.fetchTasksByProject(project.id);
      return _createProjectReport(project, tasks);
    } catch (e) {
      debugPrint('Error generating report for project ${project.name}: $e');
      return ProjectReport.empty(project);
    }
  }

  /// Create project report from tasks data
  ProjectReport _createProjectReport(ProjectModel project, List<dynamic> tasks) {
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
    final assigneeReports = _generateAssigneeReports(tasks);
    
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

  /// Generate assignee reports from tasks
  List<AssigneeReport> _generateAssigneeReports(List<dynamic> tasks) {
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
      final userName = _usersMap[userId]?.name ?? 'Unknown User';
      
      return AssigneeReport(userName, data.totalTasks, data.completedTasks);
    }).toList();
  }

  /// Get filtered projects based on search query
  List<ProjectReport> get filteredProjects {
    if (_searchQuery.isEmpty) {
      return _projectReports.where((project) => !project.archived).toList();
    }
    
    final query = _searchQuery.toLowerCase();
    return _projectReports.where((project) {
      final matchesSearch = project.name.toLowerCase().contains(query) ||
                           project.description.toLowerCase().contains(query);
      return matchesSearch && !project.archived;
    }).toList();
  }

  /// Get selected project data
  ProjectReport? get selectedProjectData {
    if (_selectedProject == null) return null;
    try {
      return _projectReports.firstWhere((p) => p.id == _selectedProject);
    } catch (e) {
      return null;
    }
  }

  /// Handle search query changes
  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  /// Handle project selection
  void _onProjectSelected(String? projectId) {
    if (mounted) {
      setState(() {
        _selectedProject = projectId;
      });
    }
  }

  /// Handle refresh action
  Future<void> _onRefresh() async {
    _animationController.reset();
    await _loadReportsData();
  }

  /// Clear search query
  void _clearSearch() {
    _searchController.clear();
    if (mounted) {
      setState(() {
        _searchQuery = '';
      });
    }
  }

  /// Format error messages for user display
  String _formatError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: ReportsHeader(onRefresh: _onRefresh),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _isInitialLoad) {
      return  LoadingState();
    }
    
    if (_error != null && _projectReports.isEmpty) {
      return ErrorState(
        error: _error!,
        onRetry: _loadReportsData,
      );
    }
    
    return Column(
      children: [
        SearchFilterSection(
          searchController: _searchController,
          searchQuery: _searchQuery,
          selectedProject: _selectedProject,
          projectReports: _projectReports,
          onSearchChanged: (_) => _onSearchChanged(),
          onProjectSelected: _onProjectSelected,
          onClearSearch: _clearSearch,
        ),
        
        if (_isLoading && !_isInitialLoad)
          const LinearProgressIndicator(),
        
        Expanded(
          child: _buildContent(theme),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (selectedProjectData != null) {
      return ProjectDetailView(
        project: selectedProjectData!,
        theme: theme,
      );
    }
    
    final filtered = filteredProjects;
    if (filtered.isEmpty) {
      return _searchQuery.isNotEmpty 
          ? _buildNoSearchResults()
          :  EmptyProjectsState();
    }
    
    return ProjectOverviewGrid(
      projects: filtered,
      animationController: _animationController,
      theme: theme,
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects found for "$_searchQuery"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _clearSearch,
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }
}

// Helper class for assignee task data
class AssigneeTaskData {
  int totalTasks = 0;
  int completedTasks = 0;
}