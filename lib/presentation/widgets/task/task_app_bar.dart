import 'package:flutter/material.dart';

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;
  final VoidCallback onSortByPriority;
  final VoidCallback onSortByDueDate;

  const TaskAppBar({
    Key? key,
    required this.onRefresh,
    required this.onClearFilters,
    required this.onSortByPriority,
    required this.onSortByDueDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      title: Text(
        'Tasks',
        style: theme.appBarTheme.titleTextStyle ?? 
               theme.textTheme.titleLarge?.copyWith(
                 color: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary,
               ),
      ),
      backgroundColor: theme.appBarTheme.backgroundColor ?? colorScheme.primary,
      foregroundColor: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary,
      elevation: theme.appBarTheme.elevation ?? 0,
      iconTheme: IconThemeData(
        color: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary,
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary,
          ),
          onPressed: onRefresh,
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: theme.appBarTheme.foregroundColor ?? colorScheme.onPrimary,
          ),
          color: colorScheme.surface,
          onSelected: (value) {
            switch (value) {
              case 'clear_filters':
                onClearFilters();
                break;
              case 'sort_priority':
                onSortByPriority();
                break;
              case 'sort_due_date':
                onSortByDueDate();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear_filters',
              child: Row(
                children: [
                  Icon(
                    Icons.clear_all,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Clear Filters',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sort_priority',
              child: Row(
                children: [
                  Icon(
                    Icons.sort,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sort by Priority',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sort_due_date',
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sort by Due Date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}