import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/admindash/task_helpers.dart';
import 'package:flutter/material.dart';

class TaskFilterBottomSheet extends StatefulWidget {
  final String? selectedProjectId;
  final int? selectedStatus;
  final int? selectedPriority;
  final String? selectedAssigneeId;
  final List<ProjectModel> projects;
  final List<UserModel> users;
  final Function(String?, int?, int?, String?) onFiltersChanged;

  const TaskFilterBottomSheet({
    Key? key,
    required this.selectedProjectId,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.selectedAssigneeId,
    required this.projects,
    required this.users,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<TaskFilterBottomSheet> createState() => _TaskFilterBottomSheetState();
}

class _TaskFilterBottomSheetState extends State<TaskFilterBottomSheet> {
  String? _tempProjectId;
  int? _tempStatus;
  int? _tempPriority;
  String? _tempAssigneeId;

  @override
  void initState() {
    super.initState();
    _tempProjectId = widget.selectedProjectId;
    _tempStatus = widget.selectedStatus;
    _tempPriority = widget.selectedPriority;
    _tempAssigneeId = widget.selectedAssigneeId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildProjectFilter(context),
          const SizedBox(height: 16),
          _buildStatusFilter(context),
          const SizedBox(height: 16),
          _buildPriorityFilter(context),
          const SizedBox(height: 16),
          _buildAssigneeFilter(context),
          const SizedBox(height: 32),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Filter Tasks',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            setState(() {
              _tempProjectId = null;
              _tempStatus = null;
              _tempPriority = null;
              _tempAssigneeId = null;
            });
          },
          child: const Text('Clear All'),
        ),
      ],
    );
  }

  Widget _buildProjectFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _tempProjectId,
          decoration: InputDecoration(
            hintText: 'All Projects',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Projects')),
            ...widget.projects.map((project) => DropdownMenuItem(
              value: project.id,
              child: Text(project.name),
            )).toList(),
          ],
          onChanged: (value) => setState(() => _tempProjectId = value),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _tempStatus,
          decoration: InputDecoration(
            hintText: 'All Statuses',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Statuses')),
            ...TaskStatus.values.map((status) => DropdownMenuItem(
              value: status.index,
              child: Text(TaskHelpers.getStatusDisplayName(status)),
            )).toList(),
          ],
          onChanged: (value) => setState(() => _tempStatus = value),
        ),
      ],
    );
  }

  Widget _buildPriorityFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _tempPriority,
          decoration: InputDecoration(
            hintText: 'All Priorities',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Priorities')),
            ...TaskPriority.values.map((priority) => DropdownMenuItem(
              value: priority.index,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: TaskHelpers.getPriorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(TaskHelpers.getPriorityDisplayName(priority)),
                ],
              ),
            )).toList(),
          ],
          onChanged: (value) => setState(() => _tempPriority = value),
        ),
      ],
    );
  }

  Widget _buildAssigneeFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Assignee', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _tempAssigneeId,
          decoration: InputDecoration(
            hintText: 'All Assignees',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Assignees')),
            ...widget.users.map((user) => DropdownMenuItem(
              value: user.id,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: user.role == UserRoleAdapter.admin
                        ? Colors.orange.shade100
                        : Colors.blue.shade100,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 10,
                        color: user.role == UserRoleAdapter.admin
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(user.name),
                ],
              ),
            )).toList(),
          ],
          onChanged: (value) => setState(() => _tempAssigneeId = value),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onFiltersChanged(
                _tempProjectId,
                _tempStatus,
                _tempPriority,
                _tempAssigneeId,
              );
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}