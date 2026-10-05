import 'dart:async';

import 'package:flutter/material.dart';

import 'library_folder_reorder_row.dart';

/// Sortable rows with a visible insertion placeholder and no drop animation.
class LibraryFolderReorderList extends StatefulWidget {
  const LibraryFolderReorderList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onReorder,
    required this.placeholderColor,
    this.padding = EdgeInsets.zero,
    this.rowSpacing = 4,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Color placeholderColor;
  final EdgeInsets padding;
  final double rowSpacing;

  @override
  State<LibraryFolderReorderList> createState() =>
      _LibraryFolderReorderListState();
}

class _LibraryFolderReorderListState extends State<LibraryFolderReorderList> {
  final _scrollController = ScrollController();
  final _viewportKey = GlobalKey();
  final _rowKeys = <int, GlobalKey>{};
  int? _dragIndex;
  var _insertIndex = 0;
  var _dragExtent = 0.0;
  Offset? _feedbackOffset;
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _start(int index) {
    final box =
        _rowKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    setState(() {
      _dragExtent = box.size.height;
      _dragIndex = index;
      _insertIndex = index;
    });
  }

  void _move(DragTargetDetails<int> details) {
    if (_dragIndex == null) return;
    _feedbackOffset = details.offset;
    _updateInsertion();
    _scrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
      final offset = _feedbackOffset;
      if (box == null || offset == null || !_scrollController.hasClients) {
        return;
      }
      final localY = box.globalToLocal(offset).dy + _dragExtent / 2;
      final delta = localY < 32
          ? -8.0
          : localY > box.size.height - 32
              ? 8.0
              : 0.0;
      if (delta == 0) return;
      final position = _scrollController.position;
      final next = (position.pixels + delta)
          .clamp(position.minScrollExtent, position.maxScrollExtent);
      if (next != position.pixels) {
        _scrollController.jumpTo(next);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _dragIndex != null) _updateInsertion();
        });
      }
    });
  }

  void _updateInsertion() {
    final offset = _feedbackOffset;
    if (offset == null) return;
    final centerY = offset.dy + _dragExtent / 2;
    var next = 0;
    for (var index = 0; index < widget.itemCount; index++) {
      if (index == _dragIndex) continue;
      final box =
          _rowKeys[index]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;
      if (centerY > box.localToGlobal(Offset(0, box.size.height / 2)).dy) {
        next++;
      }
    }
    if (next != _insertIndex) setState(() => _insertIndex = next);
  }

  void _finish() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _feedbackOffset = null;
    final from = _dragIndex;
    final to = _insertIndex;
    if (from == null) return;
    setState(() => _dragIndex = null);
    if (from != to) widget.onReorder(from, to);
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final indices = List.generate(widget.itemCount, (index) => index);
        final dragIndex = _dragIndex;
        if (dragIndex != null) {
          indices.remove(dragIndex);
          indices.insert(_insertIndex, dragIndex);
        }
        final width = constraints.maxWidth - widget.padding.horizontal;
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data == _dragIndex,
          onMove: _move,
          onLeave: (_) {
            _scrollTimer?.cancel();
            _scrollTimer = null;
          },
          builder: (context, candidates, rejected) => ListView(
            key: _viewportKey,
            controller: _scrollController,
            padding: widget.padding,
            clipBehavior: Clip.none,
            children: [
              for (final index in indices)
                SizedBox(
                  key: _rowKeys.putIfAbsent(index, GlobalKey.new),
                  child: Builder(builder: (context) {
                    final row = widget.itemBuilder(context, index);
                    return Draggable<int>(
                      data: index,
                      maxSimultaneousDrags:
                          dragIndex == null || dragIndex == index ? 1 : 0,
                      onDragStarted: () => _start(index),
                      onDragEnd: (_) => _finish(),
                      feedback: InheritedTheme.captureAll(
                        context,
                        SizedBox(
                          width: width,
                          child: LibraryFolderReorderRow.dragProxy(
                            row,
                            index,
                            const AlwaysStoppedAnimation(1),
                          ),
                        ),
                      ),
                      childWhenDragging: SizedBox(
                        height: _dragExtent,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: widget.rowSpacing),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: widget.placeholderColor,
                              border:
                                  Border.all(color: widget.placeholderColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      child: row,
                    );
                  }),
                ),
            ],
          ),
        );
      });
}
