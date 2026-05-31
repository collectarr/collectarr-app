import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'library_pane_widths.dart';
import 'library_resizable_pane.dart';
import 'library_workspace_config.dart';

export 'library_workspace_actions.dart';
export 'library_workspace_controls.dart';
export 'library_workspace_menus.dart';
export 'library_workspace_search.dart';
export 'library_workspace_tokens.dart';

class LibraryDetailsAwareLayout extends StatelessWidget {
  const LibraryDetailsAwareLayout({
    super.key,
    required this.content,
    required this.detailsLayout,
    required this.inspector,
    this.rightWidth = 340,
    this.bottomHeight = kLibraryDetailsDefaultHeight,
    this.onRightWidthChanged,
    this.onBottomHeightChanged,
    this.maxRightWidth = kLibraryDetailsMaxWidth,
    this.maxBottomHeight = kLibraryPaneStoredMaxWidth,
    this.accentColor = kAppAccent,
  });

  final Widget content;
  final LibraryDetailsLayout detailsLayout;
  final Widget inspector;
  final double rightWidth;
  final double bottomHeight;
  final ValueChanged<double>? onRightWidthChanged;
  final ValueChanged<double>? onBottomHeightChanged;
  final double maxRightWidth;
  final double maxBottomHeight;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveRightWidth = clampLibraryPaneWidth(
      rightWidth,
      minWidth: kLibraryDetailsMinWidth,
      maxWidth: maxRightWidth,
    );
    final effectiveBottomHeight = clampLibraryPaneHeight(
      bottomHeight,
      minHeight: kLibraryDetailsMinHeight,
      maxHeight: maxBottomHeight,
    );
    return switch (detailsLayout) {
      LibraryDetailsLayout.right => Row(
          children: [
            Expanded(child: content),
            if (onRightWidthChanged == null)
              const VerticalDivider(width: 1)
            else
              LibraryResizableDivider(
                onDragDelta: (delta) => onRightWidthChanged!(
                  clampLibraryPaneWidth(
                    effectiveRightWidth - delta,
                    minWidth: kLibraryDetailsMinWidth,
                    maxWidth: maxRightWidth,
                  ),
                ),
              ),
            SizedBox(
              width: effectiveRightWidth,
              child: _LibraryDetailsPaneFrame(
                accentColor: accentColor,
                child: inspector,
              ),
            ),
          ],
        ),
      LibraryDetailsLayout.bottom => Column(
          children: [
            Expanded(child: content),
            if (onBottomHeightChanged == null)
              const Divider(height: 1)
            else
              LibraryResizableDivider(
                axis: Axis.vertical,
                onDragDelta: (delta) => onBottomHeightChanged!(
                  clampLibraryPaneHeight(
                    effectiveBottomHeight - delta,
                    minHeight: kLibraryDetailsMinHeight,
                    maxHeight: maxBottomHeight,
                  ),
                ),
              ),
            SizedBox(
              height: effectiveBottomHeight,
              child: _LibraryDetailsPaneFrame(
                accentColor: accentColor,
                child: inspector,
              ),
            ),
          ],
        ),
      LibraryDetailsLayout.hidden => content,
    };
  }
}

class _LibraryDetailsPaneFrame extends StatelessWidget {
  const _LibraryDetailsPaneFrame({
    required this.child,
    required this.accentColor,
  });

  final Widget child;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final accentDivider = accentColor.withValues(alpha: 0.34);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.035),
          palette.panel,
        ),
        border: Border(
          left: BorderSide(color: accentDivider),
          top: BorderSide(color: accentDivider),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.alphaBlend(
                    accentColor.withValues(alpha: 0.16),
                    palette.surface,
                  ),
                  palette.surface,
                ],
              ),
              border: Border(
                bottom: BorderSide(color: accentDivider),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
