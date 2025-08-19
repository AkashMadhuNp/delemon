import 'package:delemon/presentation/admin/project/controllers/project_controllers.dart';
import 'package:delemon/presentation/admin/project/project_screen.dart';
import 'package:flutter/material.dart';

class ProjectEmptyState extends StatelessWidget {
  final String searchQuery;
  final ProjectFilter selectedFilter;
  final VoidCallback onShowAll;

  const ProjectEmptyState({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.isNotEmpty;
    final isFiltered = selectedFilter != ProjectFilter.all;
    
    IconData icon;
    String title;
    String subtitle;
    
    if (isSearching) {
      icon = Icons.search_off;
      title = 'No results found';
      subtitle = 'Try a different search term or check your spelling';
    } else if (isFiltered) {
      icon = selectedFilter == ProjectFilter.archived 
          ? Icons.archive_outlined 
          : Icons.folder_open;
      title = selectedFilter == ProjectFilter.archived 
          ? 'No archived projects' 
          : 'No active projects';
      subtitle = selectedFilter == ProjectFilter.archived
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
              onPressed: onShowAll,
              child: const Text('Show all projects'),
            ),
          ],
        ],
      ),
    );
  }
}