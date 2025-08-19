import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/utils/task_change_detetctor.dart';
import 'package:delemon/core/utils/task_edit_validator.dart';
import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/taskEdit/task_edit_appbar.dart';
import 'package:delemon/presentation/widgets/taskEdit/task_edit_form.dart';
import 'package:delemon/presentation/widgets/taskEdit/task_edit_loading_state.dart';
import 'package:delemon/presentation/widgets/taskEdit/unsaved_change_dialogue.dart';
import 'package:flutter/material.dart';


class TaskEditPage extends StatefulWidget {
  final String taskId;
  final TaskModel? initialTask;

  const TaskEditPage({
    super.key,
    required this.taskId,
    this.initialTask,
  });

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  final TaskService _taskService = TaskService();
  final TaskEditValidator _validator = TaskEditValidator();
  final TaskChangeDetector _changeDetector = TaskChangeDetector();

  TaskModel? _originalTask;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;

  final _formData = TaskEditFormData();

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      TaskModel? task = widget.initialTask ?? await _taskService.getTask(widget.taskId);

      if (task == null) {
        setState(() {
          _errorMessage = 'Task not found';
          _isLoading = false;
        });
        return;
      }

      _originalTask = task;
      _formData.populateFromTask(task);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load task: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasUnsavedChanges) {
          await _handleBackPress();
        }
      },
      child: Scaffold(
        appBar: TaskEditAppBar(
          isSaving: _isSaving,
          canSave: !_isLoading && _originalTask != null,
          onSave: _handleSave,
        ),
        body: LoadingStateWidget(
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onRetry: _loadTaskData,
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_originalTask == null) return const SizedBox();

    return TaskEditForm(
      formData: _formData,
      onChanged: _handleFormChange,
      onSave: _handleSave,
      isSaving: _isSaving,
    );
  }

  void _handleFormChange() {
    if (_originalTask == null) return;

    final hasChanges = _changeDetector.hasChanges(
      original: _originalTask!,
      current: _formData,
    );

    if (hasChanges != _hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = hasChanges);
    }
  }

  Future<void> _handleSave() async {
    final validation = _validator.validate(_formData);
    if (!validation.isValid) {
      _showSnackBar(validation.errorMessage!, Colors.red);
      return;
    }

    if (!_hasUnsavedChanges) {
      _showSnackBar("No changes to save", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedTask = _formData.toTaskModel(_originalTask!);
      await _taskService.updateTask(context, updatedTask);
      
      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        Navigator.pop(context, updatedTask);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to update task: $e", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleBackPress() async {
    final shouldLeave = await UnsavedChangesDialog.show(
      context: context,
      title: 'Unsaved Changes',
      content: 'You have unsaved changes. Are you sure you want to leave?',
    );

    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}

class TaskEditFormData {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final estimateHoursController = TextEditingController();
  
  String? selectedProjectId;
  TaskStatus selectedStatus = TaskStatus.todo;
  TaskPriority selectedPriority = TaskPriority.medium;
  DateTime? selectedStartDate;
  DateTime? selectedDueDate;
  List<String> subtaskIds = [];  // Changed from taskLabels to subtaskIds
  List<String> assigneeIds = [];

  void populateFromTask(TaskModel task) {
    titleController.text = task.title;
    descriptionController.text = task.description;
    estimateHoursController.text = task.estimateHours?.toString() ?? '';
    
    selectedProjectId = task.projectId;
    selectedStatus = TaskStatus.values[task.status];
    selectedPriority = TaskPriority.values[task.priority];
    selectedStartDate = task.startDate;
    selectedDueDate = task.dueDate;
    subtaskIds = List<String>.from(task.subtaskIds);  // Changed from task.labels to task.subtaskIds
    assigneeIds = List<String>.from(task.assigneeIds);
  }

  TaskModel toTaskModel(TaskModel originalTask) {
    return TaskModel(
      id: originalTask.id,
      projectId: selectedProjectId!,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: selectedStatus.index,
      priority: selectedPriority.index,
      startDate: selectedStartDate,
      dueDate: selectedDueDate,
      estimateHours: double.tryParse(estimateHoursController.text) ?? 0.0,
      timeSpentHours: originalTask.timeSpentHours,
      subtaskIds: subtaskIds,  // Changed from labels to subtaskIds
      assigneeIds: assigneeIds,
      createdAt: originalTask.createdAt,
      updatedAt: DateTime.now(),
      createdBy: originalTask.createdBy,
    );
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    estimateHoursController.dispose();
  }
}