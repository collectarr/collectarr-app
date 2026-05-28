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
            SizedBox(width: effectiveRightWidth, child: inspector),
          ],
        ),
      LibraryDetailsLayout.bottom => Column(
          children: [
            Expanded(child: content),
            const Divider(height: 1),
            SizedBox(height: bottomHeight, child: inspector),
          ],
        ),
      LibraryDetailsLayout.hidden => content,
    };
  }
}
