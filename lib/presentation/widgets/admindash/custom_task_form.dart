import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/admindash/task_helpers.dart';
import 'package:flutter/material.dart';

class TaskFormFields extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController estimateHoursController;
  final String? selectedProjectId;
  final TaskStatus selectedStatus;
  final TaskPriority selectedPriority;
  final DateTime? selectedStartDate;
  final DateTime? selectedDueDate;
  final List<String> taskLabels;
  final List<String> assigneeIds;
  final Function(String?) onProjectChanged;
  final Function(TaskStatus) onStatusChanged;
  final Function(TaskPriority) onPriorityChanged;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onDueDateChanged;
  final Function(List<String>) onLabelsChanged;
  final Function(List<String>) onAssigneesChanged;

  const TaskFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.estimateHoursController,
    required this.selectedProjectId,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.selectedStartDate,
    required this.selectedDueDate,
    required this.taskLabels,
    required this.assigneeIds,
    required this.onProjectChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onStartDateChanged,
    required this.onDueDateChanged,
    required this.onLabelsChanged,
    required this.onAssigneesChanged,
  });

  @override
  State<TaskFormFields> createState() => _TaskFormFieldsState();
}

class _TaskFormFieldsState extends State<TaskFormFields> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleField(),
        const SizedBox(height: 16),
        _buildProjectField(),
        const SizedBox(height: 16),
        _buildDescriptionField(),
        const SizedBox(height: 16),
        _buildStatusPriorityRow(),
        const SizedBox(height: 16),
        _buildDateRow(context),
        const SizedBox(height: 16),
        _buildEstimateField(),
        const SizedBox(height: 16),
        _buildLabelsSection(context),
        const SizedBox(height: 16),
        _buildAssigneesSection(),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: widget.titleController,
      decoration: InputDecoration(
        labelText: "Task Title *",
        hintText: "Enter task title (3-100 characters)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.title),
      ),
      maxLength: 100,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Task title is required';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters long';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildProjectField() {
    return FutureBuilder<List<ProjectModel>>(
      future: ProjectService().fetchProjects(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final projects = snapshot.data?.where((p) => !p.archived).toList() ?? [];
        
        return DropdownButtonFormField<String>(
          value: widget.selectedProjectId,
          decoration: InputDecoration(
            labelText: "Project *",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.folder),
          ),
          items: projects.map((project) => DropdownMenuItem(
            value: project.id,
            child: Text(project.name),
          )).toList(),
          onChanged: widget.onProjectChanged,
          validator: (value) => value == null ? 'Please select a project' : null,
        );
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: widget.descriptionController,
      decoration: InputDecoration(
        labelText: "Description",
        hintText: "Enter task description",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 3,
      maxLength: 500,
      validator: (value) {
        if (value != null && value.trim().length > 500) {
          return 'Description must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildStatusPriorityRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<TaskStatus>(
            value: widget.selectedStatus,
            decoration: InputDecoration(
              labelText: "Status",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.flag),
            ),
            items: TaskStatus.values.map((status) => DropdownMenuItem(
              value: status,
              child: Text(TaskHelpers.getStatusDisplayName(status)),
            )).toList(),
            onChanged: (value) => value != null ? widget.onStatusChanged(value) : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<TaskPriority>(
            value: widget.selectedPriority,
            decoration: InputDecoration(
              labelText: "Priority",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(
                Icons.priority_high,
                color: TaskHelpers.getPriorityColor(widget.selectedPriority),
              ),
            ),
            items: TaskPriority.values.map((priority) => DropdownMenuItem(
              value: priority,
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
            onChanged: (value) => value != null ? widget.onPriorityChanged(value) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDateField(
          context: context,
          label: "Start Date",
          icon: Icons.calendar_today,
          selectedDate: widget.selectedStartDate,
          onDateSelected: (date) {
            widget.onStartDateChanged(date);
            // If start date is after due date, reset due date
            if (date != null && widget.selectedDueDate != null && date.isAfter(widget.selectedDueDate!)) {
              widget.onDueDateChanged(null);
            }
          },
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildDateField(
          context: context,
          label: "Due Date",
          icon: Icons.event,
          selectedDate: widget.selectedDueDate,
          onDateSelected: widget.onDueDateChanged,
          firstDate: widget.selectedStartDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        )),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return InkWell(
      onTap: () async {
        try {
          // Ensure the initial date is within the valid range
          DateTime initialDate;
          if (selectedDate != null) {
            if (selectedDate.isBefore(firstDate)) {
              initialDate = firstDate;
            } else if (selectedDate.isAfter(lastDate)) {
              initialDate = lastDate;
            } else {
              initialDate = selectedDate;
            }
          } else {
            initialDate = firstDate.isAfter(DateTime.now()) ? firstDate : DateTime.now();
          }

          final date = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          );
          onDateSelected(date);
        } catch (e) {
          print("Error opening date picker: $e");
          // Fallback: just use today as initial date
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: firstDate,
            lastDate: lastDate,
          );
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon),
        ),
        child: Text(
          selectedDate != null
              ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
              : "Select $label",
          style: TextStyle(
            color: selectedDate != null 
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEstimateField() {
    return TextFormField(
      controller: widget.estimateHoursController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Estimated Hours",
        hintText: "Enter estimated hours (e.g., 8.5)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.access_time),
        suffixText: "hrs",
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final hours = double.tryParse(value);
          if (hours == null || hours < 0) {
            return 'Please enter a valid number';
          }
          if (hours > 1000) {
            return 'Estimate cannot exceed 1000 hours';
          }
        }
        return null;
      },
    );
  }

  Widget _buildLabelsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Labels", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddLabelDialog(context),
            ),
          ],
        ),
        if (widget.taskLabels.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.taskLabels.map((label) => Chip(
              label: Text(label),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                final newLabels = List<String>.from(widget.taskLabels)..remove(label);
                widget.onLabelsChanged(newLabels);
              },
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildAssigneesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assignees", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        FutureBuilder<List<UserModel>>(
          future: _taskService.getAllAssignableUsers(), 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text("Loading staff members..."),
                  ],
                ),
              );
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "No staff members available",
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              );
            }

            return Column(
              children: [
                // Multi-select dropdown for assignees
                InkWell(
                  onTap: () => _showAssigneeSelectionDialog(context, users),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.assigneeIds.isEmpty 
                                ? "Tap to select assignees"
                                : "${widget.assigneeIds.length} assignee(s) selected",
                            style: TextStyle(
                              color: widget.assigneeIds.isEmpty 
                                  ? Theme.of(context).hintColor
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                // Show selected assignees as chips
                if (widget.assigneeIds.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.assigneeIds.map((userId) {
                      final user = users.firstWhere(
                        (u) => u.id == userId,
                        orElse: () => UserModel(
                          id: userId, 
                          name: 'Unknown User', 
                          email: '', 
                          password: '', 
                          role: UserRoleAdapter.staff,
                        ),
                      );
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: user.role == UserRoleAdapter.admin 
                              ? Colors.orange.shade100 
                              : Colors.blue.shade100,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: user.role == UserRoleAdapter.admin 
                                  ? Colors.orange.shade700 
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(user.name),
                            if (user.role == UserRoleAdapter.admin) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4, 
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          final newAssignees = List<String>.from(widget.assigneeIds)..remove(userId);
                          widget.onAssigneesChanged(newAssignees);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAssigneeSelectionDialog(BuildContext context, List<UserModel> users) {
    List<String> tempSelectedIds = List<String>.from(widget.assigneeIds);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Select Assignees"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = tempSelectedIds.contains(user.id);
                
                return CheckboxListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    "${user.email} • ${user.role == UserRoleAdapter.admin ? 'Admin' : 'Staff'}",
                  ),
                  secondary: CircleAvatar(
                    backgroundColor: user.role == UserRoleAdapter.admin 
                        ? Colors.orange.shade100 
                        : Colors.blue.shade100,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: user.role == UserRoleAdapter.admin 
                            ? Colors.orange.shade700 
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelectedIds.add(user.id);
                      } else {
                        tempSelectedIds.remove(user.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                widget.onAssigneesChanged(tempSelectedIds);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLabelDialog(BuildContext context) {
    final labelController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Label"),
        content: TextFormField(
          controller: labelController,
          decoration: const InputDecoration(
            labelText: "Label name",
            hintText: "e.g., UI/UX, Backend, Bug",
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final label = labelController.text.trim();
              if (label.isNotEmpty && !widget.taskLabels.contains(label)) {
                final newLabels = List<String>.from(widget.taskLabels)..add(label);
                widget.onLabelsChanged(newLabels);
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}