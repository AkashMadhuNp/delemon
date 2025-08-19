import 'package:flutter/material.dart';
import 'package:delemon/data/models/task_model.dart';

class TaskTimeTrackingWidget extends StatelessWidget {
  final TaskModel task;

  const TaskTimeTrackingWidget({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final estimated = task.estimateHours ?? 0;
    final spent = task.timeSpentHours ?? 0;
    final progress = estimated > 0 ? (spent / estimated).clamp(0.0, 1.0) : 0.0;
    final isOverTime = spent > estimated && estimated > 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Estimated: ${estimated}h'),
            Text('Spent: ${spent}h'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOverTime ? Colors.red : Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
