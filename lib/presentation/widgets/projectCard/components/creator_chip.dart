import 'package:delemon/core/colors/color.dart';
import 'package:flutter/material.dart';

class CreatorChip extends StatelessWidget {
  final String createdBy;

  const CreatorChip({
    super.key,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            createdBy,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
