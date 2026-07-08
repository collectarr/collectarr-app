import 'package:collectarr_app/features/library/add/library_add_shared.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddShell extends StatelessWidget {
  const LibraryAddShell({
    super.key,
    required this.accent,
    required this.width,
    required this.height,
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
    required this.onResizeWidth,
    required this.onResizeHeight,
    required this.header,
    required this.body,
    this.footer,
  });

  final Color accent;
  final double width;
  final double height;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final ValueChanged<double> onResizeWidth;
  final ValueChanged<double> onResizeHeight;
  final Widget header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Theme(
      data: buildLibraryAddDialogTheme(accent, palette),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 720 ? 10 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width.clamp(minWidth, maxWidth),
            maxHeight: height.clamp(minHeight, maxHeight),
          ),
          child: _ResizableDialogShell(
            accent: accent,
            onResizeWidth: onResizeWidth,
            onResizeHeight: onResizeHeight,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(child: body),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A decorated dialog shell with resize handles on the right and bottom edges.
class _ResizableDialogShell extends StatelessWidget {
  const _ResizableDialogShell({
    required this.accent,
    required this.onResizeWidth,
    required this.onResizeHeight,
    required this.child,
  });

  final Color accent;
  final ValueChanged<double> onResizeWidth;
  final ValueChanged<double> onResizeHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: palette.panel,
            border: Border.all(color: palette.divider),
            boxShadow: const [
              BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
        // Right edge resize handle.
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) => onResizeWidth(d.delta.dx * 2),
              child: const SizedBox(width: 6),
            ),
          ),
        ),
        // Bottom edge resize handle.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) => onResizeHeight(d.delta.dy * 2),
              child: const SizedBox(height: 6),
            ),
          ),
        ),
        // Bottom-right corner resize handle.
        Positioned(
          right: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeDownRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) {
                onResizeWidth(d.delta.dx * 2);
                onResizeHeight(d.delta.dy * 2);
              },
              child: const SizedBox(width: 12, height: 12),
            ),
          ),
        ),
      ],
    );
  }
}

