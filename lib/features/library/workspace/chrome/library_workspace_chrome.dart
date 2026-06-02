import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../layout/library_pane_widths.dart';
import '../layout/library_resizable_pane.dart';
import '../config/library_workspace_config.dart';

export 'library_workspace_actions.dart';
export 'library_workspace_controls.dart';
export 'library_workspace_menus.dart';
export 'library_workspace_search.dart';
export '../config/library_workspace_tokens.dart';

class LibraryDetailsAwareLayout extends StatelessWidget {
  const LibraryDetailsAwareLayout({
    super.key,
    required this.content,
    required this.detailsLayout,
    required this.inspector,
    this.frameInspector = true,
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
  final bool frameInspector;
  final double rightWidth;
  final double bottomHeight;
  final ValueChanged<double>? onRightWidthChanged;
  final ValueChanged<double>? onBottomHeightChanged;
  final double maxRightWidth;
  final double maxBottomHeight;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final accentDivider = accentColor.withValues(alpha: 0.3);
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
    final inspectorPane = frameInspector
        ? _LibraryDetailsPaneFrame(
            accentColor: accentColor,
            child: inspector,
          )
        : inspector;
    return switch (detailsLayout) {
      LibraryDetailsLayout.right => Row(
          children: [
            Expanded(child: content),
            if (onRightWidthChanged == null)
              const VerticalDivider(width: 1)
            else
              LibraryResizableDivider(
                color: accentDivider,
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
                child: inspectorPane,
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
                color: accentDivider,
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
                child: inspectorPane,
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
    final accentDivider = accentColor.withValues(alpha: 0.3);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accentColor.withValues(alpha: 0.028),
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
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.alphaBlend(
                    accentColor.withValues(alpha: 0.12),
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
                Icon(Icons.info_outline, size: 13, color: accentColor),
                const SizedBox(width: 5),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
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
