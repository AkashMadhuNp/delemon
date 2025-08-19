import 'package:flutter/material.dart';
import 'package:delemon/core/utils/task_utils.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/core/service/task_service.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ProjectModel? project;
  final TaskService taskService;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TaskCard({
    super.key,
    required this.task,
    this.project,
    required this.taskService,
    required this.onTap,
    required this.onLongPress,
  });

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Icons.keyboard_arrow_down;
      case TaskPriority.medium: return Icons.remove;
      case TaskPriority.high: return Icons.keyboard_arrow_up;
      case TaskPriority.critical: return Icons.priority_high;
    }
  }

  Color _getTimeSpentColor(double spent, double estimate) {
    if (estimate <= 0) return Colors.orange;
    if (spent <= estimate) return Colors.orange;
    if (spent <= estimate * 1.2) return Colors.amber;
    return Colors.red;
  }

  Color _getProgressColor(double spent, double estimate) {
    if (estimate <= 0) return Colors.grey;
    final percentage = (spent / estimate) * 100;
    if (percentage <= 80) return Colors.green;
    if (percentage <= 100) return Colors.orange;
    return Colors.red;
  }

  int _getProgressPercentage(double spent, double estimate) {
    if (estimate <= 0) return 0;
    return ((spent / estimate) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null && 
                     task.dueDate!.isBefore(DateTime.now()) && 
                     task.status != TaskStatus.completed &&
                     task.status != TaskStatus.done;
    
    final isBeingTracked = taskService.isTaskBeingTracked(task.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              if (isBeingTracked) _buildTimeTrackingIndicator(),
              if (isBeingTracked) const SizedBox(height: 8),
              if (project != null) _buildProjectTag(),
              const SizedBox(height: 8),
              if (task.description.isNotEmpty) _buildDescription(),
              const SizedBox(height: 12),
              _buildBottomRow(context, isOverdue),
              if (task.estimateHours > 0 || task.timeSpentHours > 0)
                _buildTimeInfo(),
              if (task.assigneeIds.isNotEmpty)
                _buildAssignees(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: (task.status == TaskStatus.completed || task.status == TaskStatus.done) 
                  ? TextDecoration.lineThrough : null,
              color: (task.status == TaskStatus.completed || task.status == TaskStatus.done) 
                  ? Colors.grey : null,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TaskUtils.getPriorityColor(task.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TaskUtils.getPriorityColor(task.priority).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPriorityIcon(task.priority),
                size: 16,
                color: TaskUtils.getPriorityColor(task.priority),
              ),
              const SizedBox(width: 4),
              Text(
                TaskUtils.getPriorityDisplayName(task.priority),
                style: TextStyle(
                  fontSize: 12,
                  color: TaskUtils.getPriorityColor(task.priority),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTrackingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Time tracking active',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder, size: 14, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            project!.name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      task.description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomRow(BuildContext context, bool isOverdue) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: TaskUtils.getStatusColor(task.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TaskUtils.getStatusColor(task.status).withOpacity(0.3),
            ),
          ),
          child: Text(
            TaskUtils.getStatusDisplayName(task.status),
            style: TextStyle(
              fontSize: 12,
              color: TaskUtils.getStatusColor(task.status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onLongPress,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.blue[700]),
                const SizedBox(width: 4),
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (task.dueDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOverdue ? Icons.warning : Icons.schedule,
                  size: 14,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          if (task.estimateHours > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Est: ${task.estimateHours}h',
                style: const TextStyle(fontSize: 10, color: Colors.blue),
              ),
            ),
          if (task.estimateHours > 0 && task.timeSpentHours > 0)
            const SizedBox(width: 8),
          if (task.timeSpentHours > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getTimeSpentColor(task.timeSpentHours, task.estimateHours).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Spent: ${task.timeSpentHours}h',
                style: TextStyle(
                  fontSize: 10,
                  color: _getTimeSpentColor(task.timeSpentHours, task.estimateHours),
                ),
              ),
            ),
          if (task.estimateHours > 0 && task.timeSpentHours > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getProgressColor(task.timeSpentHours, task.estimateHours).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_getProgressPercentage(task.timeSpentHours, task.estimateHours)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: _getProgressColor(task.timeSpentHours, task.estimateHours),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignees() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FutureBuilder<List<UserModel>>(
        future: TaskUtils.loadAssignees(task.assigneeIds, taskService),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Wrap(
              spacing: 4,
              children: snapshot.data!.map((user) => 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user.name,
                    style: const TextStyle(fontSize: 10, color: Colors.green),
                  ),
                )
              ).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}