import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/features/library/ui/library_surface.dart';
import 'package:flutter/material.dart';

class LibraryPanelChrome extends StatelessWidget {
  const LibraryPanelChrome({
    super.key,
    required this.header,
    required this.body,
    this.footer,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.bodyPadding,
    this.density = LibraryDensity.comfortable,
  });

  final Widget header;
  final Widget body;
  final Widget? footer;
  final double? maxWidth;
  final double? maxHeight;
  final Color? backgroundColor;
  final EdgeInsets? bodyPadding;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    return LibraryDensityScope(
      density: density,
      child: LibrarySurface(
        header: header,
        body: body,
        footer: footer,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        backgroundColor: backgroundColor,
        bodyPadding: bodyPadding ?? libraryPanelInsets(density),
        density: density,
      ),
    );
  }
}
