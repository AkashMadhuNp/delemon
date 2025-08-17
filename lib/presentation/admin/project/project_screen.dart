import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/admin/project/project_details.dart';
import 'package:delemon/presentation/widgets/projectCard/swipable_projectcards.dart';
import 'package:flutter/material.dart';

enum ProjectFilter { all, active, archived }

class ProjectsScreen extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallbackSet;
  
  const ProjectsScreen({
    super.key,
    this.onRefreshCallbackSet,
  });

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final ProjectService _projectService = ProjectService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<ProjectModel> projects = [];
  List<ProjectModel> filteredProjects = [];
  bool _isLoading = true;
  bool _isSearchActive = false;
  ProjectFilter _selectedFilter = ProjectFilter.all;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    widget.onRefreshCallbackSet?.call(_loadProjects);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    List<ProjectModel> filtered = List.from(projects);

    // Apply filter
    switch (_selectedFilter) {
      case ProjectFilter.active:
        filtered = filtered.where((p) => !p.archived).toList();
        break;
      case ProjectFilter.archived:
        filtered = filtered.where((p) => p.archived).toList();
        break;
      case ProjectFilter.all:
        // No additional filtering needed
        break;
    }

    // Apply search
    final searchQuery = _searchController.text.trim().toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((project) {
        return project.name.toLowerCase().contains(searchQuery) ||
               project.description.toLowerCase().contains(searchQuery) ||
               project.createdBy.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Sort projects (active first, then by creation date)
    filtered.sort((a, b) {
      if (a.archived != b.archived) {
        return a.archived ? 1 : -1; // Active projects first
      }
      return b.createdAt.compareTo(a.createdAt); // Newest first
    });

    filteredProjects = filtered;
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    
    try {
      final fetchedProjects = await _projectService.fetchProjects(context);
      if (mounted) {
        setState(() {
          projects = fetchedProjects;
          _applyFiltersAndSearch();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _onFilterChanged(ProjectFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFiltersAndSearch();
    });
  }

  void _editProject(ProjectModel project) {
    Navigator.pushNamed(
      context, 
      '/edit-project',
      arguments: project,
    ).then((_) => _loadProjects());
  }

  void _deleteProject(ProjectModel project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_rounded, color: Colors.red[600], size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Delete Project'),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"${project.name}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '? This action cannot be undone.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _projectService.deleteProject(context, project.id);
                  _loadProjects();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting project: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _toggleArchive(ProjectModel project) async {
    try {
      await _projectService.toggleArchiveProject(context, project);
      _loadProjects();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewProject(ProjectModel project) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProjectDetail(),));

    
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive ? _buildSearchField() : const Text('Projects'),
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
              onPressed: _loadProjects,
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
          _buildFilterChips(theme),
          _buildResultsHeader(theme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProjects,
                    child: filteredProjects.isEmpty
                        ? _buildEmptyState()
                        : _buildProjectsList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search projects...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      style: Theme.of(context).textTheme.titleMedium,
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Filter:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    filter: ProjectFilter.all,
                    count: projects.length,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Active',
                    filter: ProjectFilter.active,
                    count: projects.where((p) => !p.archived).length,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Archived',
                    filter: ProjectFilter.archived,
                    count: projects.where((p) => p.archived).length,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ProjectFilter filter,
    required int count,
    required ThemeData theme,
  }) {
    final isSelected = _selectedFilter == filter;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white.withOpacity(0.3)
                  : theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => _onFilterChanged(filter),
      selectedColor: theme.colorScheme.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.outline.withOpacity(0.5),
      ),
    );
  }

  Widget _buildResultsHeader(ThemeData theme) {
    if (_isLoading) return const SizedBox.shrink();
    
    final searchQuery = _searchController.text.trim();
    final totalCount = filteredProjects.length;
    
    String headerText = '';
    if (searchQuery.isNotEmpty) {
      headerText = 'Found $totalCount result${totalCount != 1 ? 's' : ''} for "$searchQuery"';
    } else {
      final filterName = _selectedFilter.name.toLowerCase();
      headerText = 'Showing $totalCount ${filterName == 'all' ? '' : filterName} project${totalCount != 1 ? 's' : ''}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            headerText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProjects.length,
      itemBuilder: (context, index) {
        final project = filteredProjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SwipeableProjectCard(
            project: project,
            onEdit: () => _editProject(project),
            onDelete: () => _deleteProject(project),
            onArchive: () => _toggleArchive(project),
            onTap: () => _viewProject(project),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final searchQuery = _searchController.text.trim();
    final isSearching = searchQuery.isNotEmpty;
    final isFiltered = _selectedFilter != ProjectFilter.all;
    
    IconData icon;
    String title;
    String subtitle;
    
    if (isSearching) {
      icon = Icons.search_off;
      title = 'No results found';
      subtitle = 'Try a different search term or check your spelling';
    } else if (isFiltered) {
      icon = _selectedFilter == ProjectFilter.archived 
          ? Icons.archive_outlined 
          : Icons.folder_open;
      title = _selectedFilter == ProjectFilter.archived 
          ? 'No archived projects' 
          : 'No active projects';
      subtitle = _selectedFilter == ProjectFilter.archived
          ? 'Projects you archive will appear here'
          : 'Create your first project using the + button';
    } else {
      icon = Icons.folder_open;
      title = 'No projects yet';
      subtitle = 'Create your first project using the + button';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (isSearching || isFiltered) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _onFilterChanged(ProjectFilter.all);
              },
              child: const Text('Show all projects'),
            ),
          ],
        ],
      ),
    );
  }
}