import 'package:flutter/material.dart';
import 'package:delemon/core/utils/task_utils.dart';
import 'package:delemon/domain/entities/task.dart';

class TaskStatusDialog extends StatelessWidget {
  final Task task;
  final Function(TaskStatus) onStatusUpdate;

  const TaskStatusDialog({
    super.key,
    required this.task,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final availableStatuses = [
      TaskStatus.todo,
      TaskStatus.inProgress,
      TaskStatus.inReview,
      TaskStatus.completed,
      TaskStatus.blocked,
    ];

    return AlertDialog(
      title: const Text('Update Task Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Change status for: ${task.title}'),
          const SizedBox(height: 16),
          ...availableStatuses.map((status) {
            return ListTile(
              leading: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: TaskUtils.getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(TaskUtils.getStatusDisplayName(status)),
              onTap: () {
                Navigator.pop(context);
                onStatusUpdate(status);
              },
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
