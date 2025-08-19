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
    return AppBar(
      title: const Text('Tasks'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Refresh',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
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
            const PopupMenuItem(
              value: 'clear_filters',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear Filters'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_priority',
              child: Row(
                children: [
                  Icon(Icons.sort),
                  SizedBox(width: 8),
                  Text('Sort by Priority'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort_due_date',
              child: Row(
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 8),
                  Text('Sort by Due Date'),
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