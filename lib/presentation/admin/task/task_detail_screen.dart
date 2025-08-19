import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/utils/task_utils.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/presentation/admin/task/task_edit_screen.dart';
import 'package:delemon/presentation/widgets/taskDetail/loading_error_widget.dart';
import 'package:delemon/presentation/widgets/taskDetail/task_asignee.dart';
import 'package:delemon/presentation/widgets/taskDetail/task_date_widgets.dart';
import 'package:delemon/presentation/widgets/taskDetail/task_info_card.dart';
import 'package:delemon/presentation/widgets/taskDetail/task_labels_widgets.dart';
import 'package:delemon/presentation/widgets/taskDetail/task_status_priority.dart';
import 'package:delemon/presentation/widgets/taskDetail/task_time_tracking_widget.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  final ProjectService _projectService = ProjectService();

  TaskModel? _task;
  ProjectModel? _project;
  List<UserModel> _assignees = [];
  UserModel? _creator;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final task = await _taskService.getTask(widget.taskId);
      if (task == null) {
        setState(() {
          _errorMessage = 'Task not found';
          _isLoading = false;
        });
        return;
      }

      final futures = await Future.wait([
        _projectService.getProject(task.projectId),
        TaskUtils.loadAssignees(task.assigneeIds, _taskService),
        TaskUtils.loadCreator(task.createdBy, _taskService),
      ]);

      setState(() {
        _task = task;
        _project = futures[0] as ProjectModel?;
        _assignees = futures[1] as List<UserModel>;
        _creator = futures[2] as UserModel?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load task details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_task?.title ?? 'Task Details'),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditTask(),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _showDeleteDialog();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Task'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: LoadingErrorWidget(
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _loadTaskDetails,
        child: RefreshIndicator(
          onRefresh: _loadTaskDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTaskDetails(),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDetails() {
    if (_task == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TaskStatusPriorityWidget(task: _task!),
        ),
        if (_task!.description.isNotEmpty)
          TaskInfoCard(
            title: 'Description',
            icon: Icons.description,
            child: Text(_task!.description),
          ),
        if (_project != null)
          TaskInfoCard(
            title: 'Project',
            icon: Icons.folder,
            child: Text(_project!.name),
          ),
        TaskInfoCard(
          title: 'Assignees',
          icon: Icons.people,
          child: TaskAssigneesWidget(assignees: _assignees),
        ),
        TaskInfoCard(
          title: 'Timeline',
          icon: Icons.calendar_today,
          child: TaskDatesWidget(task: _task!),
        ),
        TaskInfoCard(
          title: 'Time Tracking',
          icon: Icons.access_time,
          child: TaskTimeTrackingWidget(task: _task!),
        ),
        TaskInfoCard(
          title: 'Labels',
          icon: Icons.label,
          child: TaskLabelsWidget(labels: _task!.subtaskIds),
        ),
        TaskInfoCard(
          title: 'Task Information',
          icon: Icons.info,
          child: _buildTaskInfo(),
        ),
      ],
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_creator != null)
          Text('Created by: ${_creator!.name}'),
        const SizedBox(height: 4),
        Text('Created: ${TaskUtils.formatDateTime(_task!.createdAt)}'),
        const SizedBox(height: 4),
        Text('Updated: ${TaskUtils.formatDateTime(_task!.updatedAt)}'),
      ],
    );
  }

  Future<void> _navigateToEditTask() async {
    if (_task == null) return;

    final result = await Navigator.push<TaskModel?>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditPage(
          taskId: _task!.id,
          initialTask: _task, 
        ),
      ),
    );

    if (result != null) {
      _loadTaskDetails();
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${_task?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteTask(),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask() async {
    Navigator.pop(context);
    try {
      await _taskService.deleteTask(context, _task!.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}