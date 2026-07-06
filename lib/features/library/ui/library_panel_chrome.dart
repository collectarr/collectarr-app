import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
    final palette = appPalette(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: Padding(
            padding: bodyPadding ?? libraryPanelInsets(density),
            child: body,
          ),
        ),
        if (footer != null) footer!,
      ],
    );

    return DecoratedBox(
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
        child: content,
      ),
    );
  }
}
