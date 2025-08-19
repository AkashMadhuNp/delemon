import 'package:flutter/material.dart';
import 'package:delemon/core/utils/task_utils.dart';
import 'package:delemon/domain/entities/task.dart';

class TaskFilterRow extends StatelessWidget {
  final TaskPriority? selectedPriority;
  final String sortBy;
  final Function(TaskPriority?) onPriorityChanged;
  final Function(String) onSortChanged;

  const TaskFilterRow({
    super.key,
    required this.selectedPriority,
    required this.sortBy,
    required this.onPriorityChanged,
    required this.onSortChanged,
  });

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Icons.keyboard_arrow_down;
      case TaskPriority.medium: return Icons.remove;
      case TaskPriority.high: return Icons.keyboard_arrow_up;
      case TaskPriority.critical: return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<TaskPriority?>(
              value: selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Priorities')),
                ...TaskPriority.values.map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Icon(
                        _getPriorityIcon(priority), 
                        size: 16, 
                        color: TaskUtils.getPriorityColor(priority)
                      ),
                      const SizedBox(width: 8),
                      Text(TaskUtils.getPriorityDisplayName(priority)),
                    ],
                  ),
                )),
              ],
              onChanged: onPriorityChanged,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: sortBy,
              decoration: InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'dueDate', child: Text('Due Date')),
                DropdownMenuItem(value: 'priority', child: Text('Priority')),
                DropdownMenuItem(value: 'status', child: Text('Status')),
                DropdownMenuItem(value: 'created', child: Text('Created Date')),
              ],
              onChanged: (value) => onSortChanged(value ?? 'dueDate'),
            ),
          ),
        ],
      ),
    );
  }
}
