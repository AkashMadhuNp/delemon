import 'package:delemon/core/colors/color.dart';
import 'package:flutter/material.dart';

class ArchiveButton extends StatelessWidget {
  final bool isArchived;
  final VoidCallback onTap;

  const ArchiveButton({
    super.key,
    required this.isArchived,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isArchived ? Colors.green[50] : Colors.orange[50];
    final borderColor = isArchived ? Colors.green[200] : Colors.orange[200];
    final iconColor = isArchived ? Colors.green[600] : Colors.orange[600];
    final tooltip = isArchived ? 'Unarchive Project' : 'Archive Project';
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor!, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
                  size: 16,
                  color: iconColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isArchived ? 'Restore' : 'Archive',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
