import 'package:delemon/data/models/project_model.dart';
import 'package:flutter/material.dart';

class ProjectInfoCard extends StatelessWidget {
  final ProjectModel project;
  final bool isDark;

  const ProjectInfoCard({
    super.key,
    required this.project,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder,
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Project Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (project.archived ?? false)
                        ? (isDark ? Colors.orange.shade900 : Colors.orange.shade100)
                        : (isDark ? Colors.green.shade900 : Colors.green.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (project.archived ?? false) ? 'ARCHIVED' : 'ACTIVE',
                    style: TextStyle(
                      color: (project.archived ?? false)
                          ? (isDark ? Colors.orange.shade200 : Colors.orange.shade800)
                          : (isDark ? Colors.green.shade200 : Colors.green.shade800),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Project ID', project.id ?? 'N/A'),
            _buildDetailRow('Created By', project.createdBy ?? 'N/A'),
            _buildDetailRow(
              'Created At', 
              project.createdAt != null 
                  ? '${project.createdAt!.day}/${project.createdAt!.month}/${project.createdAt!.year}'
                  : 'N/A'
            ),
            if (project.description != null && project.description!.isNotEmpty)
              _buildDetailRow('Description', project.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
