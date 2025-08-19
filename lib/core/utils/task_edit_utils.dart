import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/presentation/admin/task/task_edit_screen.dart';

class TaskChangeDetector {
  bool hasChanges({
    required TaskModel original,
    required TaskEditFormData current,
  }) {
    return original.title != current.titleController.text.trim() ||
           original.description != current.descriptionController.text.trim() ||
           original.projectId != current.selectedProjectId ||
           original.status != current.selectedStatus.index ||
           original.priority != current.selectedPriority.index ||
           original.startDate != current.selectedStartDate ||
           original.dueDate != current.selectedDueDate ||
           (original.estimateHours ?? 0.0) != _parseEstimate(current.estimateHoursController.text) ||
           !_listsEqual(original.subtaskIds, current.subtaskIds) || 
           !_listsEqual(original.assigneeIds, current.assigneeIds);
  }

  double _parseEstimate(String text) {
    return double.tryParse(text.trim()) ?? 0.0;
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return false;
    }
    return true;
  }

  
}
