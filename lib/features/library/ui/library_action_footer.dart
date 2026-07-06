import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    final palette = appPalette(context);
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: kLibraryPanelHorizontalPadding,
          vertical: density == LibraryDensity.comfortable ? 6 : 4,
        );
    return Container(
      width: double.infinity,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.toolbar,
        border: Border(top: BorderSide(color: borderColor ?? palette.divider)),
      ),
      child: child,
    );
  }
}
