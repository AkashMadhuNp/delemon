import 'package:delemon/core/utils/report_util.dart';
import 'package:delemon/domain/entities/report_model.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final ProjectReport project;
  final AnimationController animationController;
  final ThemeData theme;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.animationController,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationController.value)),
          child: Opacity(
            opacity: animationController.value,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 16),
                  _buildProgressSection(),
                  SizedBox(height: 16),
                  _buildStatsRow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (project.description.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  project.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ReportUtils.getCompletionColor(project.completionPercentage).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${project.completionPercentage}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ReportUtils.getCompletionColor(project.completionPercentage),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: project.totalTasks > 0 ? (project.completionPercentage / 100) : 0,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: ReportUtils.getCompletionColor(project.completionPercentage),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItem(
          icon: Icons.task_alt,
          value: '${project.completedTasks}/${project.totalTasks}',
          label: 'Tasks',
          color: Colors.green,
          theme: theme,
        ),
        StatItem(
          icon: Icons.schedule,
          value: '${project.inProgressTasks}',
          label: 'In Progress',
          color: Colors.blue,
          theme: theme,
        ),
        StatItem(
          icon: Icons.warning,
          value: '${project.overdueTasks}',
          label: 'Overdue',
          color: Colors.red,
          theme: theme,
        ),
      ],
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
