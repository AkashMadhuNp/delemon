import 'package:flutter/material.dart';

class TaskInstructionBanner extends StatelessWidget {
  const TaskInstructionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap to change status • Long press for time tracking',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
