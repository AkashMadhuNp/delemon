import 'package:delemon/core/colors/color.dart';
import 'package:delemon/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class DateChip extends StatelessWidget {
  final DateTime createdAt;

  const DateChip({
    super.key,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = (isDark ? AppColors.darkSubText : AppColors.lightSubText);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormatter.formatRelative(createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
