import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Page chrome for collection management tools opened from the library menu.
class LibraryManagementPage extends StatelessWidget {
  const LibraryManagementPage({
    super.key,
    required this.title,
    this.icon,
    required this.accent,
    required this.child,
    this.bottomBar,
    this.svgAsset,
  }) : assert(icon != null || svgAsset != null);

  final String title;
  final IconData? icon;
  final Color accent;
  final Widget child;
  final Widget? bottomBar;
  final String? svgAsset;

  @override
  Widget build(BuildContext context) => Theme(
        data: libraryAccentTheme(context, accent),
        child: Builder(builder: (context) {
          return Scaffold(
            backgroundColor: appManagementCanvasColor(context),
            appBar: AppPageHeader(
                title: Text(title), icon: icon, svgAsset: svgAsset),
            body: AppManagementContent(child: child),
            bottomNavigationBar: bottomBar == null
                ? null
                : AppManagementContent(child: bottomBar!),
          );
        }),
      );
}
