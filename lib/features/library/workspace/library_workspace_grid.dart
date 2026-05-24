import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
);

typedef LibraryGridItemId<T> = String Function(T item);

class LibraryWorkspaceGrid<T> extends StatefulWidget {
  const LibraryWorkspaceGrid({
    required this.items,
    required this.itemBuilder,
    required this.emptyBuilder,
    required this.maxCrossAxisExtent,
    required this.mainAxisExtent,
    this.selectionEnabled = false,
    this.selectedIds = const {},
    this.itemIdOf,
    this.onSelectionChanged,
    this.shrinkWrap = false,
    this.scrollable = true,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.padding = const EdgeInsets.all(10),
    this.backgroundColor = kAppGridCanvas,
    super.key,
  });

  final List<T> items;
  final LibraryGridItemBuilder<T> itemBuilder;
  final WidgetBuilder emptyBuilder;
  final double maxCrossAxisExtent;
  final double mainAxisExtent;
  final bool selectionEnabled;
  final Set<String> selectedIds;
  final LibraryGridItemId<T>? itemIdOf;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final bool shrinkWrap;
  final bool scrollable;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  State<LibraryWorkspaceGrid<T>> createState() => _LibraryWorkspaceGridState<T>();
}

class _LibraryWorkspaceGridState<T> extends State<LibraryWorkspaceGrid<T>> {
  final _scrollController = ScrollController();
  Rect? _selectionRect;
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyBuilder(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = widget.padding.resolve(Directionality.of(context));
        final gridWidth = constraints.maxWidth - padding.left - padding.right;
        final crossAxisCount = ((gridWidth + widget.crossAxisSpacing) /
                (widget.maxCrossAxisExtent + widget.crossAxisSpacing))
            .ceil()
            .clamp(1, widget.items.length);
        final tileWidth =
            (gridWidth - ((crossAxisCount - 1) * widget.crossAxisSpacing)) /
                crossAxisCount;
        final grid = GridView.builder(
          controller: widget.scrollable ? _scrollController : null,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.scrollable
              ? null
              : const NeverScrollableScrollPhysics(),
          padding: widget.padding,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: widget.maxCrossAxisExtent,
            mainAxisExtent: widget.mainAxisExtent,
            crossAxisSpacing: widget.crossAxisSpacing,
            mainAxisSpacing: widget.mainAxisSpacing,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, index) => widget.itemBuilder(
            context,
            widget.items[index],
          ),
        );
        if (!widget.selectionEnabled ||
            widget.itemIdOf == null ||
            widget.onSelectionChanged == null) {
          return ColoredBox(color: widget.backgroundColor, child: grid);
        }
        return ColoredBox(
          color: widget.backgroundColor,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              setState(() {
                _dragStart = details.localPosition;
                _selectionRect = Rect.fromPoints(
                  details.localPosition,
                  details.localPosition,
                );
              });
            },
            onPanUpdate: (details) {
              final start = _dragStart;
              if (start == null) {
                return;
              }
              final rect = Rect.fromPoints(start, details.localPosition);
              setState(() => _selectionRect = rect);
              widget.onSelectionChanged!(
                _selectedIdsForRect(
                  rect,
                  padding: padding,
                  crossAxisCount: crossAxisCount,
                  tileWidth: tileWidth,
                ),
              );
            },
            onPanEnd: (_) => setState(() {
              _dragStart = null;
              _selectionRect = null;
            }),
            child: Stack(
              fit: StackFit.expand,
              children: [
                grid,
                if (_selectionRect != null)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _SelectionRectPainter(_selectionRect!),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Set<String> _selectedIdsForRect(
    Rect rect, {
    required EdgeInsets padding,
    required int crossAxisCount,
    required double tileWidth,
  }) {
    final selected = <String>{};
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    for (var index = 0; index < widget.items.length; index++) {
      final row = index ~/ crossAxisCount;
      final column = index % crossAxisCount;
      final left = padding.left +
          (column * (tileWidth + widget.crossAxisSpacing));
      final top = padding.top +
          (row * (widget.mainAxisExtent + widget.mainAxisSpacing)) -
          scrollOffset;
      final tileRect = Rect.fromLTWH(
        left,
        top,
        tileWidth,
        widget.mainAxisExtent,
      );
      if (tileRect.overlaps(rect)) {
        selected.add(widget.itemIdOf!(widget.items[index]));
      }
    }
    return selected;
  }
}

class _SelectionRectPainter extends CustomPainter {
  const _SelectionRectPainter(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final normalized = Rect.fromLTRB(
      rect.left.clamp(0, size.width),
      rect.top.clamp(0, size.height),
      rect.right.clamp(0, size.width),
      rect.bottom.clamp(0, size.height),
    );
    final fill = Paint()..color = kAppAccent.withValues(alpha: 0.2);
    final stroke = Paint()
      ..color = kAppAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(normalized, fill);
    canvas.drawRect(normalized, stroke);
  }

  @override
  bool shouldRepaint(covariant _SelectionRectPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}
