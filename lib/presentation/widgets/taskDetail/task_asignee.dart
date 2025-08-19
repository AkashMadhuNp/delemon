import 'package:flutter/material.dart';
import 'package:delemon/data/models/user_model.dart';

class TaskAssigneesWidget extends StatelessWidget {
  final List<UserModel> assignees;

  const TaskAssigneesWidget({
    super.key,
    required this.assignees,
  });

  @override
  Widget build(BuildContext context) {
    if (assignees.isEmpty) {
      return const Text(
        'No assignees',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: assignees.map((user) {
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          label: Text(user.name),
        );
      }).toList(),
    );
  }
}
