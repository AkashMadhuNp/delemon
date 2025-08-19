import 'package:flutter/material.dart';

class TaskSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;
  final VoidCallback onFilterPressed;

  const TaskSearchFilterBar({
    Key? key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: onFilterPressed,
              tooltip: 'Filter Tasks',
            ),
          ),
        ],
      ),
    );
  }
}