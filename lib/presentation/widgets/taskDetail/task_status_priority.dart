import 'package:delemon/core/utils/task_utils.dart';
import 'package:flutter/material.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/domain/entities/task.dart';

class TaskStatusPriorityWidget extends StatelessWidget {
  final TaskModel task;

  const TaskStatusPriorityWidget({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final status = TaskStatus.values[task.status];
    final priority = TaskPriority.values[task.priority];

    return Row(
      children: [
        Expanded(
          child: _buildStatusChip(status),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityChip(priority),
        ),
      ],
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    final color = TaskUtils.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            TaskUtils.getStatusDisplayName(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    final color = TaskUtils.getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            TaskUtils.getPriorityDisplayName(priority),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
