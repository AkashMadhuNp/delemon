import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/core/colors/color.dart';
import 'package:flutter/material.dart';

class ProjectCardHeader extends StatelessWidget {
  final ProjectModel project;

  const ProjectCardHeader({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Expanded(
          child: Text(
            project.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
        if (project.archived) _buildArchivedBadge(),
      ],
    );
  }

  Widget _buildArchivedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Text(
        'ARCHIVED',
        style: TextStyle(
          color: Colors.amber[700],
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}
