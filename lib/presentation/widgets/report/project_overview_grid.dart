import 'package:delemon/domain/entities/report_model.dart';
import 'package:delemon/presentation/widgets/report/empty_search_state.dart';
import 'package:delemon/presentation/widgets/report/project_card.dart';
import 'package:flutter/material.dart';

class ProjectOverviewGrid extends StatelessWidget {
  final List<ProjectReport> projects;
  final AnimationController animationController;
  final ThemeData theme;

  const ProjectOverviewGrid({
    Key? key,
    required this.projects,
    required this.animationController,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return EmptySearchState();
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects Overview (${projects.length} active)',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.8 : 1.2,
            ),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return ProjectCard(
                project: projects[index],
                animationController: animationController,
                theme: theme,
              );
            },
          ),
        ],
      ),
    );
  }
}
