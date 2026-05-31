import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable screen header with back button and title.
class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary,
          ),
          Expanded(child: Text(title, style: AppTextStyles.heading)),
        ],
      ),
    );
  }
}
