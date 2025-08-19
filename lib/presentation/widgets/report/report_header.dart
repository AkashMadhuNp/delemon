import 'package:flutter/material.dart';

class ReportsHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;

  const ReportsHeader({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        'Reports & Analytics',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
          onPressed: onRefresh,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
