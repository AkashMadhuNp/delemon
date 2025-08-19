import 'package:flutter/material.dart';

class TaskEmptyState extends StatelessWidget {
  final bool hasSearchQuery;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  const TaskEmptyState({
    Key? key,
    required this.hasSearchQuery,
    required this.hasActiveFilters,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery || hasActiveFilters
                ? 'No tasks match your criteria'
                : 'No tasks yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery || hasActiveFilters
                ? 'Try adjusting your search or filters'
                : 'Create your first task to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (hasActiveFilters || hasSearchQuery)
            ElevatedButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            )
         
        ],
      ),
    );
  }
}