
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(child: Text('Analytics and reports')),
    );
  }
}