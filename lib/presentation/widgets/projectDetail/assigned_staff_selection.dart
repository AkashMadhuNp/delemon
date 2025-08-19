import 'package:delemon/data/models/task_model.dart';
import 'package:delemon/data/models/user_model.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:flutter/material.dart';

class AssignedStaffSection extends StatelessWidget {
  final List<UserModel> assignedStaff;
  final List<TaskModel> projectTasks;
  final bool isDark;

  const AssignedStaffSection({
    super.key,
    required this.assignedStaff,
    required this.projectTasks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: isDark ? Colors.indigo.shade300 : Colors.indigo,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Assigned Staff (${assignedStaff.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (assignedStaff.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 48,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No staff assigned to this project',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(assignedStaff.map((staff) => _buildStaffItem(staff))),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffItem(UserModel staff) {
    final staffTasks = projectTasks.where((task) => task.assigneeIds.contains(staff.id)).toList();
    final completedTasks = staffTasks.where((task) => task.status == TaskStatus.done.index).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDark ? Colors.indigo.shade700 : Colors.indigo.shade100,
            child: Text(
              staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.indigo.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  staff.email,
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completedTasks/${staffTasks.length} tasks',
              style: TextStyle(
                color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
