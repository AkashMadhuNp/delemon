import 'package:flutter/material.dart';

class TaskEditAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSaving;
  final bool canSave;
  final VoidCallback onSave;

  const TaskEditAppBar({
    super.key,
    required this.isSaving,
    required this.canSave,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Edit Task'),
      elevation: 1,
      actions: [
        if (canSave)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(isSaving ? 'Saving...' : 'SAVE'),
              style: TextButton.styleFrom(
                foregroundColor: isSaving 
                    ? Colors.grey 
                    : Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
