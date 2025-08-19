import 'package:flutter/material.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:intl/intl.dart';

class TaskDatesWidget extends StatelessWidget {
  final TaskModel task;

  const TaskDatesWidget({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final hasStartDate = task.startDate != null;
    final hasDueDate = task.dueDate != null;
    
    if (!hasStartDate && !hasDueDate) {
      return const Text(
        'No dates set',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      children: [
        if (hasStartDate) ...[
          _buildDateRow(
            icon: Icons.play_arrow,
            iconColor: Colors.green,
            label: 'Start',
            date: task.startDate!,
          ),
          if (hasDueDate) const SizedBox(height: 8),
        ],
        if (hasDueDate)
          _buildDateRow(
            icon: Icons.schedule,
            iconColor: task.dueDate!.isBefore(DateTime.now()) 
                ? Colors.red 
                : Colors.orange,
            label: 'Due',
            date: task.dueDate!,
            isOverdue: task.dueDate!.isBefore(DateTime.now()),
          ),
      ],
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required DateTime date,
    bool isOverdue = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ${DateFormat('MMM dd, yyyy').format(date)}',
          style: TextStyle(
            color: isOverdue ? Colors.red : null,
            fontWeight: isOverdue ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
