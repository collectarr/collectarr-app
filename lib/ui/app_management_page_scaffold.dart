import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared page chrome; each tool still owns scrolling and its content layout.
class AppManagementPageScaffold extends StatelessWidget {
  const AppManagementPageScaffold(
      {super.key,
      required this.icon,
      required this.title,
      required this.child,
      this.leading,
      this.actions,
      this.padding = const EdgeInsets.all(12)});
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: appManagementCanvasColor(context),
      appBar: AppPageHeader(
          icon: icon, title: Text(title), leading: leading, actions: actions),
      body: AppManagementContent(
          maxWidth: 960, child: Padding(padding: padding, child: child)));
}
