import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibrarySectionPanel extends StatelessWidget {
  const LibrarySectionPanel({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.density = LibraryDensity.comfortable,
  });

  final Widget child;
  final Widget? title;
  final String? subtitle;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedPadding = padding ??
        EdgeInsets.all(density == LibraryDensity.comfortable ? 12 : 10);
    final resolvedMargin = margin ??
        const EdgeInsets.only(bottom: kLibrarySectionGap);
    return Container(
      margin: resolvedMargin,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.panelRaised,
        border: Border.all(color: borderColor ?? palette.divider),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || subtitle != null) ...[
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ) ??
                  const TextStyle(fontWeight: FontWeight.w800),
              child: title ?? const SizedBox.shrink(),
            ),
            if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: kLibrarySectionTitleGap),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: kLibrarySectionBodyGap),
          ],
          child,
        ],
      ),
    );
  }
}
