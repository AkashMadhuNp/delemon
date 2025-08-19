import 'package:delemon/presentation/admin/task/task_edit_screen.dart';
import 'package:delemon/presentation/widgets/taskEdit/task_edit_save_button.dart';
import 'package:flutter/material.dart';
import 'package:delemon/presentation/widgets/admindash/custom_task_form.dart';

class TaskEditForm extends StatefulWidget {
  final TaskEditFormData formData;
  final VoidCallback onChanged;
  final VoidCallback onSave;
  final bool isSaving;

  const TaskEditForm({
    super.key,
    required this.formData,
    required this.onChanged,
    required this.onSave,
    required this.isSaving,
  });

  @override
  State<TaskEditForm> createState() => _TaskEditFormState();
}

class _TaskEditFormState extends State<TaskEditForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    widget.formData.titleController.addListener(widget.onChanged);
    widget.formData.descriptionController.addListener(widget.onChanged);
    widget.formData.estimateHoursController.addListener(widget.onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TaskFormFields(
              titleController: widget.formData.titleController,
              descriptionController: widget.formData.descriptionController,
              estimateHoursController: widget.formData.estimateHoursController,
              selectedProjectId: widget.formData.selectedProjectId,
              selectedStatus: widget.formData.selectedStatus,
              selectedPriority: widget.formData.selectedPriority,
              selectedStartDate: widget.formData.selectedStartDate,
              selectedDueDate: widget.formData.selectedDueDate,
              taskLabels: widget.formData.subtaskIds,
              assigneeIds: widget.formData.assigneeIds,
              onProjectChanged: (projectId) {
                setState(() => widget.formData.selectedProjectId = projectId);
                widget.onChanged();
              },
              onStatusChanged: (status) {
                setState(() => widget.formData.selectedStatus = status);
                widget.onChanged();
              },
              onPriorityChanged: (priority) {
                setState(() => widget.formData.selectedPriority = priority);
                widget.onChanged();
              },
              onStartDateChanged: (date) {
                setState(() => widget.formData.selectedStartDate = date);
                widget.onChanged();
              },
              onDueDateChanged: (date) {
                setState(() => widget.formData.selectedDueDate = date);
                widget.onChanged();
              },
              onLabelsChanged: (labels) {
                setState(() => widget.formData.subtaskIds = labels);
                widget.onChanged();
              },
              onAssigneesChanged: (assignees) {
                setState(() => widget.formData.assigneeIds = assignees);
                widget.onChanged();
              },
            ),
            const SizedBox(height: 30),
            TaskEditSaveButton(
              onSave: widget.onSave,
              isSaving: widget.isSaving,
            ),

            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }
}
