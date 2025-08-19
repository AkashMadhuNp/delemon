import 'package:delemon/presentation/blocs/report/bloc/report_bloc.dart';
import 'package:delemon/presentation/blocs/report/bloc/report_event.dart';
import 'package:delemon/presentation/blocs/report/bloc/report_state.dart';
import 'package:delemon/presentation/widgets/report/empty_project_state.dart';
import 'package:delemon/presentation/widgets/report/error_state.dart';
import 'package:delemon/presentation/widgets/report/loading_state.dart';
import 'package:delemon/presentation/widgets/report/project_detail_view.dart';
import 'package:delemon/presentation/widgets/report/project_overview_grid.dart';
import 'package:delemon/presentation/widgets/report/report_header.dart';
import 'package:delemon/presentation/widgets/report/search_filter_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _searchController.addListener(_onSearchChanged);
    
    // Load initial data
    context.read<ReportsBloc>().add(LoadReportsEvent());
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

  void _onSearchChanged() {
    final query = _searchController.text;
    context.read<ReportsBloc>().add(SearchReportsEvent(query));
  }

  void _onProjectSelected(String? projectId) {
    context.read<ReportsBloc>().add(SelectProjectEvent(projectId));
  }

  Future<void> _onRefresh() async {
    _animationController.reset();
    context.read<ReportsBloc>().add(RefreshReportsEvent());
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ReportsBloc>().add(ClearSearchEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: ReportsHeader(onRefresh: _onRefresh),
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsLoaded) {
            _animationController.forward();
            
            if (state.searchQuery != _searchController.text) {
              _searchController.text = state.searchQuery;
            }
          }
        },
        builder: (context, state) {
          return _buildBody(theme, state);
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ReportsState state) {
    if (state is ReportsLoading && state.isInitialLoad) {
      return LoadingState();
    }
    
    if (state is ReportsError && state.currentReports.isEmpty) {
      return ErrorState(
        error: state.message,
        onRetry: () => context.read<ReportsBloc>().add(LoadReportsEvent()),
      );
    }
    
    return Column(
      children: [
        if (state is ReportsLoaded)
          SearchFilterSection(
            searchController: _searchController,
            searchQuery: state.searchQuery,
            selectedProject: state.selectedProjectId,
            projectReports: state.projectReports,
            onSearchChanged: (_) => _onSearchChanged(),
            onProjectSelected: _onProjectSelected,
            onClearSearch: _clearSearch,
          ),
        
        if (state is ReportsLoading && !state.isInitialLoad)
          const LinearProgressIndicator(),
        
        Expanded(
          child: _buildContent(theme, state),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, ReportsState state) {
    if (state is ReportsLoaded) {
      if (state.selectedProject != null) {
        return ProjectDetailView(
          project: state.selectedProject!,
          theme: theme,
        );
      }
      
      if (state.filteredProjects.isEmpty) {
        return state.searchQuery.isNotEmpty 
            ? _buildNoSearchResults(state.searchQuery)
            : EmptyProjectsState();
      }
      
      return ProjectOverviewGrid(
        projects: state.filteredProjects,
        animationController: _animationController,
        theme: theme,
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildNoSearchResults(String searchQuery) {
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
            'No projects found for "$searchQuery"',
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
