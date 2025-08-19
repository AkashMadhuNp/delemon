import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/task_service.dart'; 
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/admindash/custom_task_form.dart';
import 'package:flutter/material.dart';

class TaskCreationDialog extends StatefulWidget {
  final VoidCallback onTaskCreated;
  final Function(String) onError;

  const TaskCreationDialog({
    super.key,
    required this.onTaskCreated,
    required this.onError,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onTaskCreated,
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
          child: TaskCreationDialog(
            onTaskCreated: onTaskCreated,
            onError: onError,
          ),
        ),
      ),
    );
  }

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimateHoursController = TextEditingController();
  final _projectService = ProjectService();
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
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Create New Task", style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isLoading ? null : () => Navigator.pop(context), 
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _isLoading ? null : _handleSave, 
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
                  Text(
                    "Creating Task...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : const Text(
                "Create Task",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      widget.onError("Please select a project");
      return;
    }

    setState(() => _isLoading = true); 

    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: _selectedProjectId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus.index,
      priority: _selectedPriority.index,
      startDate: _selectedStartDate,
      dueDate: _selectedDueDate,
      estimateHours: double.tryParse(_estimateHoursController.text) ?? 0.0,
      timeSpentHours: 0.0,
      assigneeIds: _assigneeIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: '', 
      subtaskIds: [], 
    );

    try {
      await _taskService.createTask(context, newTask);
      _clearFields();
      if (mounted) {
        Navigator.pop(context);
        widget.onTaskCreated();
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

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    _estimateHoursController.clear();
    _assigneeIds.clear();
    _taskLabels.clear();
    setState(() {
      _selectedProjectId = null;
      _selectedStatus = TaskStatus.todo;
      _selectedPriority = TaskPriority.medium;
      _selectedStartDate = null;
      _selectedDueDate = null;
    });
  }
}