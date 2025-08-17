import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/core/colors/color.dart';
import 'package:delemon/presentation/widgets/projectCard/components/project_card_footer.dart';
import 'package:delemon/presentation/widgets/projectCard/components/project_card_header.dart';
import 'package:flutter/material.dart';

class ProjectCardContent extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback onArchive;

  const ProjectCardContent({
    super.key,
    required this.project,
    this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.darkText : AppColors.lightText).withOpacity(0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProjectCardHeader(project: project),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDescription(theme, isDark),
                ],
                const SizedBox(height: 12),
                ProjectCardFooter(
                  project: project,
                  onArchive: onArchive,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, bool isDark) {
    return Text(
      project.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: (isDark ? AppColors.darkSubText : AppColors.lightSubText),
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
