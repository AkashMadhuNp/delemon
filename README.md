📌 TaskFlow Mini

A Flutter task management app (mini version of Asana/Jira) built with Clean Architecture + BLoC + Hive.
This project is part of the Delemon Flutter Assignment - a comprehensive task management solution that demonstrates modern Flutter development practices with Clean Architecture principles.

✨ Features
🔄 Core Workflow
Splash Screen → Login/Signup → Role-Based Dashboard

Dashboard
👨‍💼 Admin Dashboard

📊 Dashboard Overview

Quick summary of active projects & tasks
Real-time metrics and progress tracking


📁 Project Management

Full CRUD operations (Create, Read, Delete, Archive)
Smart search and filtering (All | Active | Archived)
Intuitive swipe-to-delete functionality


✅ Task Management

Complete task lifecycle management
Detailed task view with rich information
Staff assignment with priority and deadline setting
Status tracking and updates


👥 Staff Management

View all registered team members


📈 Reports & Analytics

Export comprehensive CSV reports
Visual status workflow with progress indicators
Key metrics: completion rates, overdue tasks, team performance

performance



👷 Staff Dashboard

📋 Project Access
View all assigned projects
Project-specific task filtering

⚡ Task Updates
Quick status updates for assigned tasks
Time tracking functionality
Progress reporting

📊 Personal Reports
Individual performance metrics
Export and share capabilities



Theme Support
🌞 Light Mode: Clean, professional interface
🌙 Dark Mode: Eye-friendly dark theme
🎨 Primary Color: #0EA5E9 (Sky Blue)

expansion

🛠️ Tech Stack
Category                             Technology           Purpose
Framework                            Flutter 3.8+         Cross-platform development
State Management                     BLoC (flutter_bloc)  Predictable state management 
Equality                             Equatable            Value equality for BLoC states/events
Navigation                           go_router            Declarative routing
Database                             HiveLightweight      local persistence
Internationalization                 IntlDate             formatting and localization
DataExport                           CSV + Share          PlusReport generation and sharing
Animations                           LottieRich           animations for empty/error states



📱 User Roles & Permissions
Admin Role

Full system access
Project and task management
Staff management and assignment
System-wide reports and analytics

Staff Role

Access to assigned projects only
Task status updates and time tracking


📈 Performance Considerations

Hive Database: Optimized for fast local storage
BLoC Pattern: Efficient state management with minimal rebuilds
Lazy Loading: On-demand data loading for large datasets
Memory Management: Proper disposal of resources and streams

⚠️ Known Limitations

Backend: Currently uses local storage only (Hive database)
Authentication: Simplified role-based auth without real server validation
Offline Support: Limited offline functionality
Report Filtering: Basic filtering options available
Real-time Updates: No real-time synchronization between devices


🙏 Acknowledgments

Delemon: For providing the assignment opportunity
Flutter Team: For the amazing framework
BLoC Library: For excellent state management
Hive: For efficient local storage

📧 Contact
For questions or support, please reach out:

Project Maintainer: Akash Madhu N P
Discussions: 002akashakz@gmail.com










