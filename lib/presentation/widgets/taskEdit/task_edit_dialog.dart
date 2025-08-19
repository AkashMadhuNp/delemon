import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/admindash/custom_task_form.dart';
import 'package:flutter/material.dart';

class TaskEditDialog extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTaskUpdated;
  final Function(String) onError;

  const TaskEditDialog({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onError,
  });

  static void show({
    required BuildContext context,
    required TaskModel task,
    required VoidCallback onTaskUpdated,
    required Function(String) onError,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: TaskEditDialog(
            task: task,
            onTaskUpdated: onTaskUpdated,
            onError: onError,
          ),
        ),
      ),
    );
  }

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimateHoursController = TextEditingController();
  final _taskService = TaskService();
  
  String? _selectedProjectId;
  TaskStatus _selectedStatus = TaskStatus.todo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedStartDate;
  DateTime? _selectedDueDate;
  List<String> _taskLabels = [];
  List<String> _assigneeIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    final task = widget.task;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _estimateHoursController.text = task.estimateHours?.toString() ?? '';
    
    _selectedProjectId = task.projectId;
    _selectedStatus = TaskStatus.values[task.status];
    _selectedPriority = TaskPriority.values[task.priority];
    _selectedStartDate = task.startDate;
    _selectedDueDate = task.dueDate;
    _taskLabels = List<String>.from(task.subtaskIds);
    _assigneeIds = List<String>.from(task.assigneeIds);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimateHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            TaskFormFields(
              titleController: _titleController,
              descriptionController: _descriptionController,
              estimateHoursController: _estimateHoursController,
              selectedProjectId: _selectedProjectId,
              selectedStatus: _selectedStatus,
              selectedPriority: _selectedPriority,
              selectedStartDate: _selectedStartDate,
              selectedDueDate: _selectedDueDate,
              taskLabels: _taskLabels,
              assigneeIds: _assigneeIds,
              onProjectChanged: (projectId) => setState(() => _selectedProjectId = projectId),
              onStatusChanged: (status) => setState(() => _selectedStatus = status),
              onPriorityChanged: (priority) => setState(() => _selectedPriority = priority),
              onStartDateChanged: (date) => setState(() => _selectedStartDate = date),
              onDueDateChanged: (date) => setState(() => _selectedDueDate = date),
              onLabelsChanged: (labels) => setState(() => _taskLabels = labels),
              onAssigneesChanged: (assignees) => setState(() => _assigneeIds = assignees),
            ),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Edit Task", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                widget.task.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _isLoading ? null : _handleUpdate,
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text("Updating..."),
                    ],
                  )
                : const Text(
                    "Update Task",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      widget.onError("Please select a project");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedTask = TaskModel(
        id: widget.task.id,
        projectId: _selectedProjectId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus.index,
        priority: _selectedPriority.index,
        startDate: _selectedStartDate,
        dueDate: _selectedDueDate,
        estimateHours: double.tryParse(_estimateHoursController.text) ?? 0.0,
        timeSpentHours: widget.task.timeSpentHours,
        assigneeIds: _assigneeIds,
        createdAt: widget.task.createdAt,
        updatedAt: DateTime.now(),
        createdBy: widget.task.createdBy, subtaskIds: [],
      );

      await _taskService.updateTask(context, updatedTask);
      
      if (mounted) {
        Navigator.pop(context);
        widget.onTaskUpdated();
      }
    } catch (e) {
      if (mounted) {
        widget.onError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
