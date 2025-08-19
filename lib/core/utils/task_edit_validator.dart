import 'package:delemon/presentation/admin/task/task_edit_screen.dart';


class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});
}

class TaskEditValidator {
  ValidationResult validate(TaskEditFormData formData) {
    final title = formData.titleController.text.trim();
    if (title.isEmpty) {
      return const ValidationResult(
        isValid: false, 
        errorMessage: 'Task title is required'
      );
    }
    
    if (title.length < 3) {
      return const ValidationResult(
        isValid: false, 
        errorMessage: 'Title must be at least 3 characters long'
      );
    }

    if (title.length > 100) {
      return const ValidationResult(
        isValid: false, 
        errorMessage: 'Title must not exceed 100 characters'
      );
    }

    if (formData.selectedProjectId == null) {
      return const ValidationResult(
        isValid: false, 
        errorMessage: 'Please select a project'
      );
    }

    final description = formData.descriptionController.text.trim();
    if (description.length > 500) {
      return const ValidationResult(
        isValid: false, 
        errorMessage: 'Description must not exceed 500 characters'
      );
    }

    final estimateText = formData.estimateHoursController.text.trim();
    if (estimateText.isNotEmpty) {
      final estimate = double.tryParse(estimateText);
      if (estimate == null) {
        return const ValidationResult(
          isValid: false, 
          errorMessage: 'Please enter a valid number for estimated hours'
        );
      }
      
      if (estimate < 0) {
        return const ValidationResult(
          isValid: false, 
          errorMessage: 'Estimated hours cannot be negative'
        );
      }

      if (estimate > 1000) {
        return const ValidationResult(
          isValid: false, 
          errorMessage: 'Estimated hours cannot exceed 1000'
        );
      }
    }

    if (formData.selectedStartDate != null && 
        formData.selectedDueDate != null &&
        formData.selectedStartDate!.isAfter(formData.selectedDueDate!)) {
      return const ValidationResult(
        isValid: false, 
        errorMessage: 'Start date cannot be after due date'
      );
    }

    return const ValidationResult(isValid: true);
  }
}
