import 'package:flutter/material.dart';

class TaskLabelsWidget extends StatelessWidget {
  final List<String> labels;

  const TaskLabelsWidget({
    super.key,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const Text(
        'No labels',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: labels.map((label) {
        return Chip(
          label: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
