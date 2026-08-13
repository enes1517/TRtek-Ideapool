import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeStatus { success, error, warning, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeStatus status;

  const StatusBadge({
    super.key,
    required this.text,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case BadgeStatus.success:
        backgroundColor = AppColors.success.withOpacity(0.15);
        textColor = AppColors.success;
        break;
      case BadgeStatus.error:
        backgroundColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
        break;
      case BadgeStatus.warning:
        backgroundColor = AppColors.warning.withOpacity(0.15);
        textColor = AppColors.warning;
        break;
      case BadgeStatus.neutral:
        backgroundColor = AppColors.textSecondary.withOpacity(0.15);
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
