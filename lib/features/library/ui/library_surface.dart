import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySurface extends StatelessWidget {
  const LibrarySurface({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.bodyPadding,
    this.density = LibraryDensity.comfortable,
    this.expandBody = true,
  });

  final Widget? header;
  final Widget body;
  final Widget? footer;
  final double? maxWidth;
  final double? maxHeight;
  final Color? backgroundColor;
  final EdgeInsets? bodyPadding;
  final LibraryDensity density;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LibraryDensityScope(
      density: density,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? palette.panel,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: palette.divider),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity,
          ),
          child: Column(
            mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) header!,
              if (expandBody)
                Expanded(
                  child: Padding(
                    padding: bodyPadding ?? libraryPanelInsets(density),
                    child: body,
                  ),
                )
              else
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: bodyPadding ?? libraryPanelInsets(density),
                    child: body,
                  ),
                ),
              if (footer != null) footer!,
            ],
          ),
        ),
      ),
    );
  }
}
