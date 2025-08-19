import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/admin/project/controllers/project_controllers.dart';
import 'package:delemon/presentation/admin/project/handlers/project_action.dart';
import 'package:delemon/presentation/admin/project/project_detail_screen.dart';
import 'package:delemon/presentation/widgets/project/project_empty_state.dart';
import 'package:delemon/presentation/widgets/project/project_filter_chips.dart';
import 'package:delemon/presentation/widgets/project/project_result_header.dart';
import 'package:delemon/presentation/widgets/project/project_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:delemon/presentation/widgets/projectCard/swipable_projectcards.dart';

class ProjectsScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallbackSet;
  
  const ProjectsScreen({
    super.key,
    this.onRefreshCallbackSet,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late final ProjectController _controller;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _controller = ProjectController();
    _controller.loadProjects(context);
    widget.onRefreshCallbackSet?.call(() => _controller.loadProjects(context));
    _searchController.addListener(_onSearchChanged);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    _controller.updateSearchQuery(_searchController.text);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchActive = false;
    });
  }

void _navigateToProjectDetails(ProjectModel project) {
  print('=== Navigation Debug Start ===');
  print('Project: ${project.name}');
  print('Context mounted: ${mounted}');
  print('Navigator can pop: ${Navigator.canPop(context)}');
  
  try {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          print('MaterialPageRoute builder called');
          return ProjectDetailsScreen(project: project);
        },
      ),
    ).then((result) {
      print('Navigation completed, result: $result');
    }).catchError((error) {
      print('Navigation error: $error');
    });
    
    print('Navigator.push called successfully');
  } catch (e) {
    print('Exception during navigation: $e');
    print('Stack trace: ${StackTrace.current}');
  }
  
  print('=== Navigation Debug End ===');
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive 
            ? ProjectSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onClear: _clearSearch,
              )
            : const Text('Projects'),
        elevation: 0,
        actions: [
          if (!_isSearchActive) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearch,
              tooltip: 'Search projects',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.loadProjects(context),
              tooltip: 'Refresh',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Clear search',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          ProjectFilterChips(
            selectedFilter: _controller.selectedFilter,
            totalCount: _controller.totalProjectsCount,
            activeCount: _controller.activeProjectsCount,
            archivedCount: _controller.archivedProjectsCount,
            onFilterChanged: _controller.updateFilter,
          ),
          ProjectResultsHeader(
            isLoading: _controller.isLoading,
            searchQuery: _controller.searchQuery,
            selectedFilter: _controller.selectedFilter,
            resultCount: _controller.filteredProjects.length,
          ),
          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _controller.loadProjects(context),
                    child: _controller.filteredProjects.isEmpty
                        ? ProjectEmptyState(
                            searchQuery: _controller.searchQuery,
                            selectedFilter: _controller.selectedFilter,
                            onShowAll: _controller.resetFilters,
                          )
                        : _buildProjectsList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.filteredProjects.length,
      itemBuilder: (context, index) {
        final project = _controller.filteredProjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SwipeableProjectCard(
            project: project,
            onTap: () => _navigateToProjectDetails(project), 
            onDelete: () => ProjectActions.showDeleteConfirmation(context, project, _controller),
            onArchive: () => ProjectActions.showArchiveConfirmation(context, project, _controller),
          ),
        );
      },
    );
  }
}