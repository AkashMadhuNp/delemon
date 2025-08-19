import 'package:delemon/core/utils/report_util.dart';
import 'package:delemon/domain/entities/report_model.dart';
import 'package:delemon/presentation/widgets/report/asignee_card.dart';
import 'package:delemon/presentation/widgets/report/distribution_chart.dart';
import 'package:delemon/presentation/widgets/report/empty_task_state.dart';
import 'package:delemon/presentation/widgets/report/stats_card.dart';
import 'package:flutter/material.dart';

class ProjectDetailView extends StatelessWidget {
  final ProjectReport project;
  final ThemeData theme;

  const ProjectDetailView({
    Key? key,
    required this.project,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 24),
          _buildStatsGrid(context),
          if (project.totalTasks > 0) ...[
            SizedBox(height: 24),
            _buildTaskDistributionSection(),
            if (project.assignees.isNotEmpty) ...[
              SizedBox(height: 24),
              _buildTeamPerformanceSection(),
            ],
          ] else ...[
            SizedBox(height: 24),
            EmptyTasksState(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Project Analytics Dashboard',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (project.archived) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ARCHIVED',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildCircularProgress(),
            ],
          ),
          SizedBox(height: 16),
          _buildProjectMetadata(),
        ],
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Container(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: project.totalTasks > 0 ? (project.completionPercentage / 100) : 0,
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: ReportUtils.getCompletionColor(project.completionPercentage),
            ),
          ),
          Center(
            child: Text(
              '${project.completionPercentage}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectMetadata() {
    return Row(
      children: [
        Icon(Icons.person, size: 16, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 8),
        Text(
          'Created by ${project.createdBy}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Spacer(),
        Icon(Icons.date_range, size: 16, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 8),
        Text(
          ReportUtils.formatDate(project.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        StatsCard(
          title: 'Total Tasks',
          value: project.totalTasks.toString(),
          icon: Icons.assignment,
          color: Colors.blue,
          theme: theme,
        ),
        StatsCard(
          title: 'Completed',
          value: project.completedTasks.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          theme: theme,
        ),
        StatsCard(
          title: 'In Progress',
          value: project.inProgressTasks.toString(),
          icon: Icons.pending,
          color: Colors.orange,
          theme: theme,
        ),
        StatsCard(
          title: 'Blocked',
          value: project.blockedTasks.toString(),
          icon: Icons.block,
          color: Colors.red,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTaskDistributionSection() {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Distribution',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          TaskDistributionChart(project: project, theme: theme),
        ],
      ),
    );
  }

  Widget _buildTeamPerformanceSection() {
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Performance',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...project.assignees.map((assignee) => AssigneeCard(
            assignee: assignee,
            theme: theme,
          )),
        ],
      ),
    );
  }
}
