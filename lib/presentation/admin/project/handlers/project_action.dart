import 'package:delemon/presentation/admin/project/controllers/project_controllers.dart';
import 'package:delemon/presentation/admin/project/project_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:delemon/data/models/project_model.dart';

class ProjectActions {
  static void editProject(BuildContext context, ProjectModel project, ProjectController controller) {
    Navigator.pushNamed(
      context, 
      '/edit-project',
      arguments: project,
    ).then((_) => controller.loadProjects(context));
  }

  static void showDeleteConfirmation(BuildContext context, ProjectModel project, ProjectController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_rounded, color: Colors.red[600], size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Delete Project'),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '"${project.name}"',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '? This action cannot be undone.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await controller.deleteProject(context, project);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  static void viewProject(BuildContext context, ProjectModel project) {
    // Validate project ID
    if (project.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid project ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(project:project ,),
      ),
    ).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening project: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  static void showArchiveConfirmation(BuildContext context, ProjectModel project, ProjectController controller) {
    final isArchiving = !project.archived;
    final actionText = isArchiving ? 'Archive' : 'Unarchive';
    final icon = isArchiving ? Icons.archive : Icons.unarchive;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.amber[600], size: 24),
              ),
              const SizedBox(width: 12),
              Text('$actionText Project'),
            ],
          ),
          content: Text(
            'Are you sure you want to ${actionText.toLowerCase()} "${project.name}"?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await controller.toggleArchive(context, project);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
              ),
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }
}