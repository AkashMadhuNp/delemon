import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:flutter/material.dart';

class ProjectStatsCard extends StatelessWidget {
  final List<TaskModel> projectTasks;
  final List<UserModel> assignedStaff;
  final bool isDark;

  const ProjectStatsCard({
    super.key,
    required this.projectTasks,
    required this.assignedStaff,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final totalTasks = projectTasks.length;
    final completedTasks = projectTasks.where((task) => task.status == TaskStatus.done.index).length;
    final inProgressTasks = projectTasks.where((task) => task.status == TaskStatus.inProgress.index).length;
    final todoTasks = projectTasks.where((task) => task.status == TaskStatus.todo.index).length;
    final overdueTasks = projectTasks.where((task) {
      return task.dueDate != null && 
             task.dueDate!.isBefore(DateTime.now()) && 
             task.status != TaskStatus.done.index;
    }).length;

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
                  Icons.analytics,
                  color: isDark ? Colors.purple.shade300 : Colors.purple,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Project Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem('Total Tasks', totalTasks.toString(), Icons.assignment, Colors.blue)),
                Expanded(child: _buildStatItem('Completed', completedTasks.toString(), Icons.check_circle, Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatItem('In Progress', inProgressTasks.toString(), Icons.work, Colors.orange)),
                Expanded(child: _buildStatItem('To Do', todoTasks.toString(), Icons.pending, Colors.grey)),
              ],
            ),
            if (overdueTasks > 0) ...[
              const SizedBox(height: 12),
              _buildStatItem('Overdue', overdueTasks.toString(), Icons.warning, Colors.red),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatItem('Assigned Staff', assignedStaff.length.toString(), Icons.people, Colors.indigo)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
