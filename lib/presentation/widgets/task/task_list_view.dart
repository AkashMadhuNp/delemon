import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/presentation/widgets/task/task_card.dart';
import 'package:flutter/material.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<ProjectModel> projects;
  final List<UserModel> users;
  final Future<void> Function() onRefresh;
  final Function(TaskModel) onTaskTap;
  final Function(String, TaskModel) onTaskAction;

  const TaskListView({
    Key? key,
    required this.tasks,
    required this.projects,
    required this.users,
    required this.onRefresh,
    required this.onTaskTap,
    required this.onTaskAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            projects: projects,
            users: users,
            onTap: () => onTaskTap(task),
            onAction: (action) => onTaskAction(action, task),
          );
        },
      ),
    );
  }
}