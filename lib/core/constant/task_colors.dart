import 'package:flutter/material.dart';

class TaskStatus {
  static const int notStarted = 0;
  static const int inProgress = 1;
  static const int completed = 2;
  static const int cancelled = 3;
  static const int blocked = 4; // If admin side uses this
  
  static String getStatusText(int status) {
    switch (status) {
      case notStarted: return 'Not Started';
      case inProgress: return 'In Progress';
      case completed: return 'Completed';
      case cancelled: return 'Cancelled';
      case blocked: return 'Blocked';
      default: return 'Unknown';
    }
  }
  
  static Color getStatusColor(int status) {
    switch (status) {
      case notStarted: return Colors.grey;
      case inProgress: return Colors.blue;
      case completed: return Colors.green;
      case cancelled: return Colors.red;
      case blocked: return Colors.orange;
      default: return Colors.grey;
    }
  }
}

class TaskPriority {
  static const int low = 0;
  static const int medium = 1;
  static const int high = 2;
  static const int critical = 3;
  
  static String getPriorityText(int priority) {
    switch (priority) {
      case low: return 'Low';
      case medium: return 'Medium';
      case high: return 'High';
      case critical: return 'Critical';
      default: return 'Unknown';
    }
  }
  
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case low: return Colors.green;
      case medium: return Colors.orange;
      case high: return Colors.red;
      case critical: return Colors.purple;
      default: return Colors.grey;
    }
  }
}