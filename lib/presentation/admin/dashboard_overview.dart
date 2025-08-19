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

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04, // Responsive padding
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with responsive text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dashboard Overview',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                        fontSize: size.width < 360 ? 20 : null, // Smaller text on very small screens
                      ),
                      overflow: TextOverflow.ellipsis,
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
              SizedBox(height: size.height * 0.02),

              // Responsive Grid Content
              Expanded(
                child: isLoading
                    ? _buildLoadingGrid(size)
                    : _buildDashboardGrid(size),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid(Size size) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: List.generate(3, (index) => const _LoadingCard()),
        );
      },
    );
  }

  Widget _buildDashboardGrid(Size size) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = _getChildAspectRatio(constraints.maxWidth);
        final spacing = _getSpacing(constraints.maxWidth);

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
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
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width < 400) return 1;
    if (width < 700) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  double _getChildAspectRatio(double width) {
    if (width < 400) return 1.8; 
    if (width < 700) return 1.3;
    return 1.2;
  }

  double _getSpacing(double width) {
    if (width < 400) return 8.0;
    if (width < 700) return 12.0;
    return 16.0;
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding and sizing
        final padding = constraints.maxWidth < 150 ? 12.0 : 16.0;
        final iconSize = constraints.maxWidth < 150 ? 32.0 : 40.0;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(padding),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon placeholder
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(iconSize / 2),
                  ),
                ),
                
                SizedBox(height: constraints.maxHeight * 0.08),
                
                // Title placeholder
                Container(
                  width: constraints.maxWidth * 0.8,
                  height: constraints.maxHeight * 0.12,
                  constraints: const BoxConstraints(
                    minHeight: 12,
                    maxHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                
                SizedBox(height: constraints.maxHeight * 0.06),
                
                Container(
                  width: constraints.maxWidth * 0.4,
                  height: constraints.maxHeight * 0.15,
                  constraints: const BoxConstraints(
                    minHeight: 16,
                    maxHeight: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}