// Updated TasksSection widget with fixed switch cases
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/admin/task/task_detail_screen.dart';
import 'package:flutter/material.dart';

class TasksSection extends StatelessWidget {
  final List<TaskModel> projectTasks;
  final bool isDark;

  const TasksSection({
    super.key,
    required this.projectTasks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt,
                  color: isDark ? Colors.green.shade300 : Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Project Tasks (${projectTasks.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (projectTasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tasks found for this project',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(projectTasks.map((task) => TaskItem(
                task: task, 
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailPage(taskId: task.id),
                    ),
                  );
                },
              ))),
          ],
        ),
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.isDark,
    this.onTap,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
      case TaskStatus.blocked:
        return Colors.red;
      case TaskStatus.inReview:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
    }
  }
  
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.blue;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.critical:
        return Colors.purple;
    }
  }

  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return "TO DO";
      case TaskStatus.inProgress:
        return "IN PROGRESS";
      case TaskStatus.done:
        return "DONE";
      case TaskStatus.blocked:
        return "BLOCKED";
      case TaskStatus.inReview:
        return "IN REVIEW";
      case TaskStatus.completed:
        return "COMPLETED";
        throw UnimplementedError();
    }
  }

  String _getPriorityDisplayName(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return "LOW";
      case TaskPriority.medium:
        return "MEDIUM";
      case TaskPriority.high:
        return "HIGH";
      case TaskPriority.critical:
        return "CRITICAL";
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = TaskStatus.values[task.status];
    final priority = TaskPriority.values[task.priority];
    
    final statusColor = _getStatusColor(status);
    final priorityColor = _getPriorityColor(priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getPriorityDisplayName(priority),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDisplayName(status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (task.dueDate != null) ...[
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: task.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    style: TextStyle(
                      color: task.dueDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      fontSize: 10,
                      fontWeight: task.dueDate!.isBefore(DateTime.now())
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
                const Spacer(),
                if (task.assigneeIds.isNotEmpty) ...[
                  Icon(
                    Icons.person,
                    size: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.assigneeIds.length}',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}