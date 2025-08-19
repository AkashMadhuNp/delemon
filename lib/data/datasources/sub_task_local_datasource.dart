import 'package:delemon/data/models/subtask_model.dart';
import 'package:hive/hive.dart';

class SubtaskLocalDatasource {
  static const String _boxName = "subtaskBox";

  Future<Box<SubtaskModel>> _openBox() async {
    return await Hive.openBox<SubtaskModel>(_boxName);
  }

  Future<void> createSubtask(SubtaskModel subtask) async {
    final box = await _openBox();
    await box.put(subtask.id, subtask);
  }

  Future<List<SubtaskModel>> getAllSubtasks() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<List<SubtaskModel>> getSubtasksByTaskId(String taskId) async {
    final box = await _openBox();
    return box.values
        .where((subtask) => subtask.taskId == taskId)
        .toList()
        ..sort((a, b) => a.order.compareTo(b.order)); 
  }

  Future<List<SubtaskModel>> getSubtasksByIds(List<String> subtaskIds) async {
    final box = await _openBox();
    return subtaskIds
        .map((id) => box.get(id))
        .where((subtask) => subtask != null)
        .cast<SubtaskModel>()
        .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<SubtaskModel?> getSubtaskById(String subtaskId) async {
    final box = await _openBox();
    return box.get(subtaskId);
  }

  Future<void> updateSubtask(SubtaskModel subtask) async {
    final box = await _openBox();
    await box.put(subtask.id, subtask);
  }

  Future<void> deleteSubtask(String subtaskId) async {
    final box = await _openBox();
    await box.delete(subtaskId);
  }

  Future<void> deleteSubtasksByTaskId(String taskId) async {
    final box = await _openBox();
    final subtasksToDelete = box.values
        .where((subtask) => subtask.taskId == taskId)
        .map((subtask) => subtask.id)
        .toList();
    
    for (final id in subtasksToDelete) {
      await box.delete(id);
    }
  }

  Future<List<SubtaskModel>> getCompletedSubtasks() async {
    final box = await _openBox();
    return box.values
        .where((subtask) => subtask.isCompleted)
        .toList();
  }

  Future<List<SubtaskModel>> getPendingSubtasks() async {
    final box = await _openBox();
    return box.values
        .where((subtask) => !subtask.isCompleted)
        .toList();
  }

  

  Future<void> toggleSubtaskCompletion(String subtaskId) async {
    final box = await _openBox();
    final subtask = box.get(subtaskId);
    if (subtask != null) {
      await box.put(subtaskId, subtask.toggleCompleted());
    }
  }

  Future<void> reorderSubtasks(String taskId, List<String> newOrder) async {
    final box = await _openBox();
    
    for (int i = 0; i < newOrder.length; i++) {
      final subtask = box.get(newOrder[i]);
      if (subtask != null && subtask.taskId == taskId) {
        await box.put(
          newOrder[i], 
          subtask.copyWith(order: i, updatedAt: DateTime.now())
        );
      }
    }
  }

  Future<void> clearAllSubtasks() async {
    final box = await _openBox();
    await box.clear();
  }

  Future<void> closeBox() async {
    final box = await _openBox();
    await box.close();
  }

  // Helper method to get subtask completion statistics for a task
  Future<Map<String, int>> getTaskSubtaskStats(String taskId) async {
    final subtasks = await getSubtasksByTaskId(taskId);
    final total = subtasks.length;
    final completed = subtasks.where((s) => s.isCompleted).length;
    
    return {
      'total': total,
      'completed': completed,
      'pending': total - completed,
    };
  }
}
