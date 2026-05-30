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
    this.bottomHeight = 310,
    this.onRightWidthChanged,
    this.maxRightWidth = kLibraryDetailsMaxWidth,
  });

  final Widget content;
  final LibraryDetailsLayout detailsLayout;
  final Widget inspector;
  final double rightWidth;
  final double bottomHeight;
  final ValueChanged<double>? onRightWidthChanged;
  final double maxRightWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveRightWidth = clampLibraryPaneWidth(
      rightWidth,
      minWidth: kLibraryDetailsMinWidth,
      maxWidth: maxRightWidth,
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
              child: _LibraryDetailsPaneFrame(child: inspector),
            ),
          ],
        ),
      LibraryDetailsLayout.bottom => Column(
          children: [
            Expanded(child: content),
            const Divider(height: 1),
            SizedBox(
              height: bottomHeight,
              child: _LibraryDetailsPaneFrame(child: inspector),
            ),
          ],
        ),
      LibraryDetailsLayout.hidden => content,
    };
  }
}

class _LibraryDetailsPaneFrame extends StatelessWidget {
  const _LibraryDetailsPaneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(color: palette.divider),
          top: BorderSide(color: palette.divider),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(
                bottom: BorderSide(color: palette.divider),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: palette.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
