import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/admindash/task_helpers.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final List<ProjectModel> projects;
  final List<UserModel> users;
  final VoidCallback onTap;
  final Function(String) onAction;

  const TaskCard({
    Key? key,
    required this.task,
    required this.projects,
    required this.users,
    required this.onTap,
    required this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final project = projects.firstWhere(
      (p) => p.id == task.projectId,
      orElse: () => ProjectModel(
        updatedAt: DateTime.now(),
        id: task.projectId,
        name: 'Unknown Project',
        description: '',
        createdBy: '',
        createdAt: DateTime.now(),
        archived: false,
      ),
    );

    final assignees = users.where((u) => task.assigneeIds.contains(u.id)).toList();
    final isOverdue = task.dueDate != null && 
                     task.dueDate!.isBefore(DateTime.now()) && 
                     task.status != 4;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isOverdue),
              const SizedBox(height: 12),
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildProjectName(context, project),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDescription(context),
              ],
              const SizedBox(height: 12),
              _buildBottomRow(context, assignees, isOverdue),
              if (task.subtaskIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildLabels(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOverdue) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TaskHelpers.getPriorityColor(TaskPriority.values[task.priority]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            TaskHelpers.getPriorityDisplayName(TaskPriority.values[task.priority]),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TaskHelpers.getStatusColor(TaskStatus.values[task.status]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            TaskHelpers.getStatusDisplayName(TaskStatus.values[task.status]),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        if (isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, size: 12, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  'Overdue',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuButton<String>(
          onSelected: onAction,
          itemBuilder: (context) => [
            
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [Icon(Icons.delete), SizedBox(width: 8), Text('Delete')],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      task.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProjectName(BuildContext context, ProjectModel project) {
    return Row(
      children: [
        Icon(Icons.folder, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          project.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      task.description,
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomRow(BuildContext context, List<UserModel> assignees, bool isOverdue) {
    return Row(
      children: [
        if (task.dueDate != null) ...[
          Icon(
            Icons.schedule,
            size: 14,
            color: isOverdue ? Colors.red : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isOverdue ? Colors.red : Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(width: 16),
        ],
        if (task.estimateHours != null && task.estimateHours! > 0) ...[
          Icon(
            Icons.access_time,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '${task.estimateHours!.toStringAsFixed(1)}h',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const Spacer(),
        ],
        if (assignees.isEmpty) const Spacer(),
        
        // Assignee avatars
        if (assignees.isNotEmpty)
          Row(
            children: [
              ...assignees.take(3).map((user) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: user.role == UserRoleAdapter.admin
                      ? Colors.orange.shade100
                      : Colors.blue.shade100,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: user.role == UserRoleAdapter.admin
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
              )).toList(),
              if (assignees.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Theme.of(context).colorScheme.outline,
                    child: Text(
                      '+${assignees.length - 3}',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: task.subtaskIds.take(3).map((label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
          ),
        ),
      )).toList(),
    );
  }
}