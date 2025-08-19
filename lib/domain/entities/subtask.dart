class SubTask{
  final String id;
  final String taskId;
  final String title;
  final String description;
  final bool isCompleted;
  final String assignedTo;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int order;

  SubTask( {
    required this.id, 
    required this.taskId, 
    required this.title, 
    required this.description, 
    required this.isCompleted, 
    required this.assignedTo, 
    required this.updatedAt, 
    required this.createdAt, 
    required this.order

  });
}