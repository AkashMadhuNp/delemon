import 'package:delemon/core/colors/color.dart';
import 'package:flutter/material.dart';

class ProjectCardActions extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final VoidCallback onDelete;

  const ProjectCardActions({
    super.key,
    required this.fadeAnimation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: _ActionButton(
            animation: fadeAnimation,
            color: Theme.of(context).colorScheme.onSurface,
            icon: Icons.delete_rounded,
            label: 'Delete',
            onTap: onDelete,
            isLeft: false,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLeft;

  const _ActionButton({
    required this.animation,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Container(
          width: 70,
          height: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? const Radius.circular(16) : Radius.zero,
              bottomLeft: isLeft ? const Radius.circular(16) : Radius.zero,
              topRight: !isLeft ? const Radius.circular(16) : Radius.zero,
              bottomRight: !isLeft ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: isLeft ? const Radius.circular(16) : Radius.zero,
                bottomLeft: isLeft ? const Radius.circular(16) : Radius.zero,
                topRight: !isLeft ? const Radius.circular(16) : Radius.zero,
                bottomRight: !isLeft ? const Radius.circular(16) : Radius.zero,
              ),
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.red, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

