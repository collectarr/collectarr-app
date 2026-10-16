import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shared canvas and centered body for settings and collection tools.
/// Scrolling remains owned by the page so lists and split panes stay bounded.
class AppManagementContent extends StatelessWidget {
  const AppManagementContent(
      {super.key, required this.child, this.maxWidth = 930});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Material(
        color: appManagementCanvasColor(context),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      );
}
