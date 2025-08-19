import 'package:delemon/presentation/admin/project/controllers/project_controllers.dart';
import 'package:delemon/presentation/admin/project/project_screen.dart';
import 'package:flutter/material.dart';

class ProjectResultsHeader extends StatelessWidget {
  final bool isLoading;
  final String searchQuery;
  final ProjectFilter selectedFilter;
  final int resultCount;

  const ProjectResultsHeader({
    super.key,
    required this.isLoading,
    required this.searchQuery,
    required this.selectedFilter,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    String headerText = '';
    if (searchQuery.isNotEmpty) {
      headerText = 'Found $resultCount result${resultCount != 1 ? 's' : ''} for "$searchQuery"';
    } else {
      final filterName = selectedFilter.name.toLowerCase();
      headerText = 'Showing $resultCount ${filterName == 'all' ? '' : filterName} project${resultCount != 1 ? 's' : ''}';
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
}