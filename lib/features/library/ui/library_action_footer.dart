import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_panel_footer.dart';
import 'package:flutter/material.dart';

class LibraryActionFooter extends StatelessWidget {
  const LibraryActionFooter({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.density = LibraryDensity.comfortable,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsets? padding;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    return LibraryPanelFooter(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: padding,
      density: density,
      child: child,
    );
  }
}
