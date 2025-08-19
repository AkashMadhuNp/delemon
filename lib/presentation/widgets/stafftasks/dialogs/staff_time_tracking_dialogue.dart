import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:flutter/material.dart';

class TimeTrackingDialog extends StatelessWidget {
  final Task task;
  final TaskService taskService;
  final VoidCallback onTimeUpdate;

  const TimeTrackingDialog({
    super.key,
    required this.task,
    required this.taskService,
    required this.onTimeUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController hoursController = TextEditingController();
    final bool isBeingTracked = taskService.isTaskBeingTracked(task.id);
    final double? currentTrackedTime = taskService.getCurrentTrackedTime(task.id);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.access_time, color: Colors.blue),
          SizedBox(width: 8),
          Text('Time Tracking'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Task: ${task.title}', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Current time spent: ${task.timeSpentHours.toStringAsFixed(2)} hours'),
          if (task.estimateHours > 0)
            Text('Estimated: ${task.estimateHours.toStringAsFixed(2)} hours'),
          SizedBox(height: 16),
          
          if (isBeingTracked) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Currently tracking time', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (currentTrackedTime != null)
                    Text('Current session: ${currentTrackedTime.toStringAsFixed(2)} hours'),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          
          TextField(
            controller: hoursController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Add hours',
              hintText: 'Enter hours (e.g., 1.5)',
              border: OutlineInputBorder(),
              suffixText: 'hours',
            ),
          ),
        ],
      ),
      actions: [
        if (isBeingTracked) ...[
          TextButton(
            onPressed: () {
              final elapsed = taskService.stopTimeTracking(task.id);
              if (elapsed != null) {
                taskService.updateTaskTimeSpent(context, task.id, elapsed);
                onTimeUpdate();
              }
              Navigator.pop(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stop, size: 16),
                SizedBox(width: 4),
                Text('Stop Tracking'),
              ],
            ),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              taskService.startTimeTracking(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⏱️ Time tracking started for ${task.title}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow, size: 16),
                SizedBox(width: 4),
                Text('Start Tracking'),
              ],
            ),
          ),
        ],
        TextButton(
          onPressed: () {
            final hours = double.tryParse(hoursController.text);
            if (hours != null && hours > 0) {
              taskService.updateTaskTimeSpent(context, task.id, hours);
              onTimeUpdate();
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a valid number of hours'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: Text('Add Time'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}