import 'package:delemon/core/utils/report_util.dart';
import 'package:delemon/domain/entities/report_model.dart';
import 'package:delemon/presentation/widgets/report/asignee_card.dart';
import 'package:delemon/presentation/widgets/report/distribution_chart.dart';
import 'package:delemon/presentation/widgets/report/empty_task_state.dart';
import 'package:delemon/presentation/widgets/report/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
          _buildExportSection(context),
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

  Widget _buildExportSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.download,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Export Data',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildExportButton(
                      context,
                      'Project Summary',
                      Icons.summarize,
                      () => _exportProjectSummary(context),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildExportButton(
                      context,
                      'Team Performance',
                      Icons.people,
                      () => _exportTeamPerformance(context),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Icon(
                Icons.download,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                'Export Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Spacer(),
              _buildExportButton(
                context,
                isTablet ? 'Project Summary' : 'Summary',
                Icons.summarize,
                () => _exportProjectSummary(context),
              ),
              SizedBox(width: 8),
              _buildExportButton(
                context,
                isTablet ? 'Team Performance' : 'Team',
                Icons.people,
                () => _exportTeamPerformance(context),
              ),
            ],
          ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isMobile ? 14 : 16),
      label: Text(
        label,
        style: TextStyle(fontSize: isMobile ? 10 : 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12, 
          vertical: isMobile ? 6 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _exportProjectSummary(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting project summary...'),
            ],
          ),
        ),
      );

      // Prepare CSV data for project summary
      List<List<String>> csvData = [
        // Header row
        [
          'Project Name',
          'Created By',
          'Created Date',
          'Status',
          'Total Tasks',
          'Completed Tasks',
          'In Progress Tasks',
          'Blocked Tasks',
          'Completion Percentage',
        ],
        // Data row
        [
          project.name,
          project.createdBy,
          ReportUtils.formatDate(project.createdAt),
          project.archived ? 'Archived' : 'Active',
          project.totalTasks.toString(),
          project.completedTasks.toString(),
          project.inProgressTasks.toString(),
          project.blockedTasks.toString(),
          '${project.completionPercentage}%',
        ],
      ];

      await _generateAndShareCSV(
        context,
        csvData,
        '${project.name}_summary_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog(context, 'Failed to export project summary: $e');
    }
  }

  Future<void> _exportTeamPerformance(BuildContext context) async {
    if (project.assignees.isEmpty) {
      _showErrorDialog(context, 'No team members data available to export.');
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting team performance...'),
            ],
          ),
        ),
      );

      // Prepare CSV data for team performance
      List<List<String>> csvData = [
        // Header row
        [
          'Team Member',
          'Total Tasks',
          'Completed Tasks',
          'Pending Tasks',
          'Completion Rate',
        ],
      ];

      // Add data rows for each team member
      for (var assignee in project.assignees) {
        final pendingTasks = assignee.totalTasks - assignee.completedTasks;
        final completionRate = assignee.totalTasks > 0 
            ? (assignee.completedTasks / assignee.totalTasks * 100).toStringAsFixed(1)
            : '0.0';
        
        csvData.add([
          assignee.name,
          assignee.totalTasks.toString(),
          assignee.completedTasks.toString(),
          pendingTasks.toString(),
          '$completionRate%',
        ]);
      }

      await _generateAndShareCSV(
        context,
        csvData,
        '${project.name}_team_performance_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog(context, 'Failed to export team performance: $e');
    }
  }

  Future<void> _generateAndShareCSV(
    BuildContext context,
    List<List<String>> csvData,
    String filename,
  ) async {
    try {
      String csv = const ListToCsvConverter().convert(csvData);

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$filename.csv';

      final file = File(path);
      await file.writeAsString(csv);

      Navigator.of(context).pop();

      await Share.shareXFiles([XFile(path)], text: 'Project Report CSV Export');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV exported and shared successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); 
      _showErrorDialog(context, 'Failed to generate CSV: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 768;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
          isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
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
                  SizedBox(height: 16),
                  Center(child: _buildCircularProgress()),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: (isTablet 
                              ? theme.textTheme.headlineMedium 
                              : theme.textTheme.headlineSmall)?.copyWith(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        
        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Created by ${project.createdBy}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.date_range, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 6),
                  Text(
                    ReportUtils.formatDate(project.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
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
      },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                style: (isMobile 
                    ? theme.textTheme.titleMedium 
                    : theme.textTheme.titleLarge)?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              TaskDistributionChart(project: project, theme: theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeamPerformanceSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                style: (isMobile 
                    ? theme.textTheme.titleMedium 
                    : theme.textTheme.titleLarge)?.copyWith(
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
      },
    );
  }
}