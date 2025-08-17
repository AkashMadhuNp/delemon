import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/core/colors/color.dart';
import 'package:flutter/material.dart';

class ArchiveConfirmationDialog {
  static Future<bool?> show({
    required BuildContext context,
    required ProjectModel project,
  }) {
    final isArchived = project.archived;
    final action = isArchived ? 'unarchive' : 'archive';
    final actionTitle = isArchived ? 'Unarchive' : 'Archive';
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isArchived ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
                  color: isArchived ? Colors.green[600] : Colors.orange[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$actionTitle Project',
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  children: [
                    TextSpan(text: 'Are you sure you want to $action '),
                    TextSpan(
                      text: '"${project.name}"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '?'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkText : AppColors.lightText).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isDark ? AppColors.darkText : AppColors.lightText).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArchived 
                          ? 'This project will be moved back to active projects and will be visible in the main list.'
                          : 'Archived projects will be hidden from the main view but can be restored later.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: (isDark ? AppColors.darkSubText : AppColors.lightSubText),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: (isDark ? AppColors.darkSubText : AppColors.lightSubText),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isArchived ? Colors.green[600] : Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionTitle),
            ),
          ],
        );
      },
    );
  }
}
