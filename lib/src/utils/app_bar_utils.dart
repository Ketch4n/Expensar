import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 4.0,
    this.centerTitle = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.inversePrimary,
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
