import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.offWhite,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              backgroundColor: AppTheme.white,
              foregroundColor: AppTheme.darkGray,
              elevation: 0,
              centerTitle: true,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                  : null,
              actions: actions,
            )
          : null,
      drawer: drawer,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: color ?? AppTheme.white,
        elevation: elevation ?? 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
