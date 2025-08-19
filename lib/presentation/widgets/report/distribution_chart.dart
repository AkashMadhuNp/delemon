import 'package:delemon/domain/entities/report_model.dart';
import 'package:flutter/material.dart';

class TaskDistributionChart extends StatelessWidget {
  final ProjectReport project;
  final ThemeData theme;

  const TaskDistributionChart({
    Key? key,
    required this.project,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoTasks = project.totalTasks - 
        project.completedTasks - 
        project.inProgressTasks - 
        project.blockedTasks;
    
    final data = [
      ChartData('Completed', project.completedTasks, Colors.green),
      ChartData('In Progress', project.inProgressTasks, Colors.blue),
      ChartData('Blocked', project.blockedTasks, Colors.red),
      ChartData('Todo', todoTasks, Colors.grey),
    ].where((data) => data.value > 0).toList();

    return Column(
      children: data.map((item) {
        final percentage = (item.value / project.totalTasks * 100).round();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '${item.value} ($percentage%)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: item.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
