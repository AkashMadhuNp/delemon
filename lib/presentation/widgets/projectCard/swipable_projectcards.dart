import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/presentation/widgets/projectCard/components/dialogs/archive_confirmation_dialog.dart';
import 'package:flutter/material.dart';

class SwipeableProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback? onTap;

  const SwipeableProjectCard({
    super.key,
    required this.project,
    required this.onDelete,
    required this.onArchive,
    this.onTap,
  });

  Future<void> _showArchiveDialog(BuildContext context) async {
    final result = await ArchiveConfirmationDialog.show(
      context: context,
      project: project,
    );
    if (result == true) {
      onArchive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(project.id), 
      direction: DismissDirection.endToStart, 
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            print('Card tapped for project: ${project.name}');
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: project.archived 
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        project.archived ? 'Archived' : 'Active',
                        style: TextStyle(
                          color: project.archived ? Colors.orange[700] : Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
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
                
                // Footer with archive/restore button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Show appropriate button based on archive status
                    TextButton.icon(
                      onPressed: () => _showArchiveDialog(context),
                      icon: Icon(
                        project.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
                        size: 16,
                      ),
                      label: Text(project.archived ? 'Restore' : 'Archive'),
                      style: TextButton.styleFrom(
                        foregroundColor: project.archived ? Colors.green : Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}