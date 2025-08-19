import 'package:delemon/presentation/widgets/overview_card.dart';
import 'package:flutter/material.dart';
import 'package:delemon/core/colors/color.dart';

class DashboardOverviewPage extends StatelessWidget {
  const DashboardOverviewPage({super.key});

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
            Text(
              'Dashboard Overview',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: const [
                  OverviewCard(
                    title: "Active Projects",
                    value: "12",
                    icon: Icons.folder_open,
                    color: AppColors.primary,
                  ),
                  OverviewCard(
                    title: "Total Tasks",
                    value: "89",
                    icon: Icons.task_alt,
                    color: Colors.green,
                  ),
                  OverviewCard(
                    title: "Staff Members",
                    value: "8",
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                  OverviewCard(
                    title: "Reports",
                    value: "24",
                    icon: Icons.analytics,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

