import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Future<void> Function()? onPressedAsync; 
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressedAsync,
    this.onPressed,
    this.isLoading = false,
  }) : assert(
         (onPressedAsync != null) ^ (onPressed != null),
         'Either onPressedAsync or onPressed must be provided, but not both',
       );

  const CustomButton.async({
    super.key,
    required this.label,
    required this.onPressedAsync,
    this.isLoading = false,
  }) : onPressed = null;

  const CustomButton.sync({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : onPressedAsync = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
        ),
        onPressed: isLoading 
            ? null 
            : () async {
                if (onPressedAsync != null) {
                  await onPressedAsync!();
                } else if (onPressed != null) {
                  onPressed!();
                }
              },
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}