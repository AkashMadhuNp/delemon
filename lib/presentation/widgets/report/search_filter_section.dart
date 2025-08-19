import 'package:delemon/domain/entities/report_model.dart';
import 'package:flutter/material.dart';

class SearchFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedProject;
  final List<ProjectReport> projectReports;
  final Function(String) onSearchChanged;
  final Function(String?) onProjectSelected;
  final VoidCallback onClearSearch;

  const SearchFilterSection({
    Key? key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedProject,
    required this.projectReports,
    required this.onSearchChanged,
    required this.onProjectSelected,
    required this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBar(theme),
          SizedBox(height: 16),
          _buildProjectSelector(theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search projects...',
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: onClearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildProjectSelector(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProject,
          hint: Text('Select project for detailed view'),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('All Projects Overview'),
            ),
            ...projectReports.map((project) => DropdownMenuItem<String>(
              value: project.id,
              child: Text('${project.name} ${project.archived ? "(Archived)" : ""}'),
            )),
          ],
          onChanged: onProjectSelected,
        ),
      ),
    );
  }
}
