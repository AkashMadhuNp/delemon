import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/admindash/task_helpers.dart';
import 'package:flutter/material.dart';

class TaskFilterChips extends StatelessWidget {
  final String? selectedProjectId;
  final int? selectedStatus;
  final int? selectedPriority;
  final String? selectedAssigneeId;
  final List<ProjectModel> projects;
  final List<UserModel> users;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final Function(String?, int?, int?, String?) onFilterChanged;

  const TaskFilterChips({
    Key? key,
    required this.selectedProjectId,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.selectedAssigneeId,
    required this.projects,
    required this.users,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = [];

    if (selectedProjectId != null) {
      final project = projects.firstWhere((p) => p.id == selectedProjectId);
      chips.add(_buildFilterChip(
        context,
        'Project: ${project.name}',
        () => onFilterChanged(null, selectedStatus, selectedPriority, selectedAssigneeId),
      ));
    }

    if (selectedStatus != null) {
      chips.add(_buildFilterChip(
        context,
        'Status: ${TaskHelpers.getStatusDisplayName(TaskStatus.values[selectedStatus!])}',
        () => onFilterChanged(selectedProjectId, null, selectedPriority, selectedAssigneeId),
      ));
    }

    if (selectedPriority != null) {
      chips.add(_buildFilterChip(
        context,
        'Priority: ${TaskHelpers.getPriorityDisplayName(TaskPriority.values[selectedPriority!])}',
        () => onFilterChanged(selectedProjectId, selectedStatus, null, selectedAssigneeId),
      ));
    }

    if (selectedAssigneeId != null) {
      final user = users.firstWhere((u) => u.id == selectedAssigneeId);
      chips.add(_buildFilterChip(
        context,
        'Assignee: ${user.name}',
        () => onFilterChanged(selectedProjectId, selectedStatus, selectedPriority, null),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: chips,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}