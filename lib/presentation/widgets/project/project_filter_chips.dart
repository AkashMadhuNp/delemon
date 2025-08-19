import 'package:delemon/presentation/admin/project/controllers/project_controllers.dart';
import 'package:flutter/material.dart';

class ProjectFilterChips extends StatelessWidget {
  final ProjectFilter selectedFilter;
  final int totalCount;
  final int activeCount;
  final int archivedCount;
  final Function(ProjectFilter) onFilterChanged;

  const ProjectFilterChips({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.activeCount,
    required this.archivedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    count: totalCount,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Active',
                    filter: ProjectFilter.active,
                    count: activeCount,
                    theme: theme,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Archived',
                    filter: ProjectFilter.archived,
                    count: archivedCount,
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
    final isSelected = selectedFilter == filter;
    
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
      onSelected: (selected) => onFilterChanged(filter),
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
}