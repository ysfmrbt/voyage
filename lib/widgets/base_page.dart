import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../menu/drawer.widget.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'widgets.dart';

/// A base page layout that provides consistent styling and structure for all pages
class BasePage extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showDrawer;
  final bool showBackButton;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;
  final double contentPadding;
  final VoidCallback? onBackPressed;

  const BasePage({
    super.key,
    required this.title,
    required this.body,
    this.showDrawer = true,
    this.showBackButton = false,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.contentPadding = 16.0,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      drawer: showDrawer && !showBackButton ? MyDrawer() : null,
      appBar: AppBar(
        title: AppText.heading(
          title,
          style: TextStyle(
            fontSize: 22,
            letterSpacing: 0.5,
            color: isDarkMode ? AppTheme.textColor : Colors.white,
          ),
        ),
        backgroundColor:
            isDarkMode ? AppTheme.surfaceColor : AppTheme.primaryColor,
        foregroundColor: isDarkMode ? AppTheme.textColor : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppTheme.textColor : Colors.white,
        ),
        elevation: isDarkMode ? 1 : 2,
        shadowColor: AppTheme.shadowColor,
        leading:
            showBackButton
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
                : null,
        automaticallyImplyLeading: true,
        actions: actions,
      ),
      backgroundColor: backgroundColor ?? AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(padding: EdgeInsets.all(contentPadding), child: body),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
