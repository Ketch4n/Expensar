import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable screen header with back button and title.
class AppHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const AppHeader({super.key, required this.title, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (showBackButton && canPop)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () => Navigator.pop(context),
              color: context.textPrimary,
            ),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading.copyWith(color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
