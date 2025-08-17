import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Tasks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(child: Text('Tasks management')),
    );
  }
}
