import 'package:delemon/core/utils/report_util.dart';
import 'package:delemon/domain/entities/report_model.dart';
import 'package:flutter/material.dart';

class AssigneeCard extends StatelessWidget {
  final AssigneeReport assignee;
  final ThemeData theme;

  const AssigneeCard({
    Key? key,
    required this.assignee,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completionRate = assignee.totalTasks > 0 
        ? (assignee.completedTasks / assignee.totalTasks * 100).round() 
        : 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              ReportUtils.getUserInitials(assignee.name),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignee.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${assignee.completedTasks}/${assignee.totalTasks} tasks completed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ReportUtils.getCompletionColor(completionRate).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$completionRate%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ReportUtils.getCompletionColor(completionRate),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}