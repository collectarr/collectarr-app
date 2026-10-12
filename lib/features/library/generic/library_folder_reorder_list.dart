import 'package:collectarr_app/ui/app_motion.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';

import 'library_folder_reorder_row.dart';

/// Sortable rows with an insertion placeholder and a short return to the slot.
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

class _LibraryFolderReorderListState extends State<LibraryFolderReorderList>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _viewportKey = GlobalKey();
  final _rowKeys = <int, GlobalKey>{};
  int? _dragIndex;
  var _insertIndex = 0;
  var _dragExtent = 0.0;
  Offset? _feedbackOffset;
  Timer? _scrollTimer;
  late final _dropController = AnimationController(
    vsync: this,
    duration: appReorderReturnDuration,
  );
  OverlayEntry? _dropOverlay;
  var _returning = false;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _dropOverlay?.remove();
    _dropOverlay?.dispose();
    _dropController.dispose();
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
    if (_dragIndex == null || _returning) return;
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

  Future<void> _finish(DraggableDetails details, double width) async {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _feedbackOffset = null;
    final from = _dragIndex;
    final to = _insertIndex;
    if (from == null) return;
    final box =
        _rowKeys[from]?.currentContext?.findRenderObject() as RenderBox?;
    final animate = LibraryAccentScope.of(context).animationsEnabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && box != null && box.attached) {
      final overlay = Overlay.of(context, rootOverlay: true);
      final overlayBox = overlay.context.findRenderObject()! as RenderBox;
      final start = overlayBox.globalToLocal(details.offset);
      final end = overlayBox.globalToLocal(box.localToGlobal(Offset.zero));
      final row = InheritedTheme.captureAll(
          context,
          SizedBox(
            width: width,
            child: LibraryFolderReorderRow.dragProxy(
              widget.itemBuilder(context, from),
              from,
              const AlwaysStoppedAnimation(1),
            ),
          ));
      setState(() => _returning = true);
      _dropOverlay = OverlayEntry(
          builder: (_) => AnimatedBuilder(
                animation: _dropController,
                child: IgnorePointer(child: row),
                builder: (_, child) {
                  final offset = Offset.lerp(start, end,
                      Curves.easeOutQuad.transform(_dropController.value))!;
                  return Positioned(
                      left: offset.dx, top: offset.dy, child: child!);
                },
              ));
      overlay.insert(_dropOverlay!);
      try {
        await _dropController.forward(from: 0).orCancel;
      } on TickerCanceled {
        return;
      }
      if (!mounted) return;
      _dropOverlay!.remove();
      _dropOverlay!.dispose();
      _dropOverlay = null;
      _returning = false;
    }
    if (!mounted) return;
    setState(() => _dragIndex = null);
    if (from != to && from < widget.itemCount && to < widget.itemCount) {
      widget.onReorder(from, to);
    }
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
                      maxSimultaneousDrags: !_returning &&
                              (dragIndex == null || dragIndex == index)
                          ? 1
                          : 0,
                      onDragStarted: () => _start(index),
                      onDragEnd: (details) => _finish(details, width),
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
