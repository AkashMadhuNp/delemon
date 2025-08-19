import 'package:delemon/presentation/widgets/overview_card.dart';
import 'package:flutter/material.dart';
import 'package:delemon/core/colors/color.dart';
import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/core/service/task_service.dart';
import 'package:delemon/core/service/auth_service.dart';

class DashboardOverviewPage extends StatefulWidget {
  const DashboardOverviewPage({super.key});

  @override
  State<DashboardOverviewPage> createState() => _DashboardOverviewPageState();
}

class _DashboardOverviewPageState extends State<DashboardOverviewPage> {
  final ProjectService _projectService = ProjectService();
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

  int activeProjectsCount = 0;
  int totalTasksCount = 0;
  int staffMembersCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final results = await Future.wait([
        _projectService.getProjectsCount(archived: false), 
        _authService.getAllUsers(),
        _taskService.fetchTasks(),
      ]);

      final activeProjects = results[0] as int;
      final allUsers = results[1] as List;
      final allTasks = results[2] as List;

      final staffMembers = allUsers.where((user) => 
        user.role.toString().contains('staff')).length;

      setState(() {
        activeProjectsCount = activeProjects;
        totalTasksCount = allTasks.length;
        staffMembersCount = staffMembers;
        isLoading = false;
      });

    } catch (e) {
      print("❌ Error loading dashboard data: $e");
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load dashboard data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final crossAxisCount = size.width < 360
        ? 1
        : size.width < 600
            ? 2
            : 3;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard Overview',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : _refreshData,
                  icon: isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isLoading)
              Expanded(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: List.generate(3, (index) => 
                    const _LoadingCard()
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      OverviewCard(
                        title: "Active Projects",
                        value: activeProjectsCount.toString(),
                        icon: Icons.folder_open,
                        color: AppColors.primary,
                      ),
                      OverviewCard(
                        title: "Total Tasks",
                        value: totalTasksCount.toString(),
                        icon: Icons.task_alt,
                        color: Colors.green,
                      ),
                      OverviewCard(
                        title: "Staff Members",
                        value: staffMembersCount.toString(),
                        icon: Icons.people,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}