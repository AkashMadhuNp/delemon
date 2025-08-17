import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/widgets/projectCard/components/archive_button.dart';
import 'package:delemon/presentation/widgets/projectCard/components/creator_chip.dart';
import 'package:delemon/presentation/widgets/projectCard/components/date_chip.dart';
import 'package:flutter/material.dart';

class ProjectCardFooter extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onArchive;

  const ProjectCardFooter({
    super.key,
    required this.project,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CreatorChip(createdBy: project.createdBy),
        const Spacer(),
        DateChip(createdAt: project.createdAt),
        const SizedBox(width: 12),
        ArchiveButton(
          isArchived: project.archived,
          onTap: onArchive,
        ),
      ],
    );
  }
}


