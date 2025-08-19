import 'package:delemon/presentation/blocs/stafftask/bloc/staftask_bloc.dart';
import 'package:delemon/presentation/blocs/stafftask/bloc/staftask_event.dart';
import 'package:delemon/presentation/blocs/stafftask/bloc/staftask_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/auth_service.dart';
import 'package:delemon/domain/entities/task.dart';
import 'package:delemon/presentation/widgets/stafftasks/dialogs/staff_time_tracking_dialogue.dart';
import 'package:delemon/presentation/widgets/stafftasks/dialogs/task_status_dialogue.dart';
import 'package:delemon/presentation/widgets/stafftasks/staff_task_banne.dart';
import 'package:delemon/presentation/widgets/stafftasks/staff_task_empty_state.dart';
import 'package:delemon/presentation/widgets/stafftasks/staff_task_search_bar.dart';
import 'package:delemon/presentation/widgets/stafftasks/task_card.dart';
import 'package:delemon/presentation/widgets/stafftasks/task_filter_row.dart';

class StaffTaskPage extends StatelessWidget {
  const StaffTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffTaskBloc(
        taskService: TaskService(),
        projectService: ProjectService(),
        authService: AuthService(),
        context: context,
      )..add(LoadStaffTasks()),
      child: const StaffTaskView(),
    );
  }
}

class StaffTaskView extends StatefulWidget {
  const StaffTaskView({super.key});

  @override
  State<StaffTaskView> createState() => _StaffTaskViewState();
}

class _StaffTaskViewState extends State<StaffTaskView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<StaffTaskBloc>().add(FilterByTab(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTaskStatusDialog(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => TaskStatusDialog(
        task: task,
        onStatusUpdate: (newStatus) {
          context.read<StaffTaskBloc>().add(UpdateTaskStatus(task, newStatus));
        },
      ),
    );
  }

  void _showTimeTrackingDialog(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => TimeTrackingDialog(
        task: task,
        taskService: TaskService(),
        onTimeUpdate: () {
          context.read<StaffTaskBloc>().add(RefreshStaffTasks());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffTaskBloc, StaffTaskState>(
      listener: (context, state) {
        if (state.status == StaffTaskStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Unknown error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('My Tasks${state.currentUser != null ? ' - ${state.currentUser!.name}' : ''}'),
            actions: [
              if (state.allTasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: ${state.totalTimeSpent.toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<StaffTaskBloc>().add(RefreshStaffTasks()),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: 'All (${state.getTaskCountForTab(0)})'),
                Tab(text: 'To Do (${state.getTaskCountForTab(1)})'),
                Tab(text: 'In Progress (${state.getTaskCountForTab(2)})'),
                Tab(text: 'In Review (${state.getTaskCountForTab(3)})'),
                Tab(text: 'Completed (${state.getTaskCountForTab(4)})'),
                Tab(text: 'Overdue (${state.getTaskCountForTab(5)})'),
              ],
            ),
          ),
          body: state.status == StaffTaskStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TaskSearchBar(
                      onSearchChanged: (value) {
                        context.read<StaffTaskBloc>().add(SearchTasks(value));
                      },
                    ),
                    TaskFilterRow(
                      selectedPriority: state.selectedPriority,
                      sortBy: state.sortBy,
                      onPriorityChanged: (priority) {
                        context.read<StaffTaskBloc>().add(FilterByPriority(priority));
                      },
                      onSortChanged: (sortBy) {
                        context.read<StaffTaskBloc>().add(SortTasks(sortBy));
                      },
                    ),
                    const TaskInstructionBanner(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: List.generate(6, (index) {
                          if (state.filteredTasks.isEmpty) {
                            return const TaskEmptyState();
                          }
                          
                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<StaffTaskBloc>().add(RefreshStaffTasks());
                            },
                            child: ListView.builder(
                              itemCount: state.filteredTasks.length,
                              itemBuilder: (context, taskIndex) {
                                final task = state.filteredTasks[taskIndex].toEntity();
                                return TaskCard(
                                  task: task,
                                  project: state.projects[task.projectId],
                                  taskService: TaskService(),
                                  onTap: () => _showTaskStatusDialog(task),
                                  onLongPress: () => _showTimeTrackingDialog(task),
                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}