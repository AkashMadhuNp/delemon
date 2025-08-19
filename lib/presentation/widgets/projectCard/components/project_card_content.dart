import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/widgets/projectCard/components/project_card_header.dart';
import 'package:delemon/presentation/widgets/projectCard/components/project_card_footer.dart';
import 'package:flutter/material.dart';

class ProjectCardContent extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final VoidCallback? onArchive;

  const ProjectCardContent({
    super.key,
    required this.project,
    this.onTap,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProjectCardHeader(project: project),
              const SizedBox(height: 8),
              
              if (project.description.isNotEmpty) ...[
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              
              if (onArchive != null)
                ProjectCardFooter(
                  project: project,
                  onArchive: onArchive!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}