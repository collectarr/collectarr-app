import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/workspace/layout/resizable_pane.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Desktop grouped results retain both panes and their divider, which can be
/// dragged to resize the group list.
class LibraryAddDesktopGroupedResultsLayout extends StatefulWidget {
  const LibraryAddDesktopGroupedResultsLayout({
    super.key,
    required this.groupList,
    required this.variantList,
    this.listWidth = LibraryAddResultGrouping.listWidth,
    this.onResize,
  });

  final Widget groupList;
  final Widget variantList;
  final double listWidth;
  final ValueChanged<double>? onResize;

  @override
  State<LibraryAddDesktopGroupedResultsLayout> createState() =>
      _LibraryAddDesktopGroupedResultsLayoutState();
}

class _LibraryAddDesktopGroupedResultsLayoutState
    extends State<LibraryAddDesktopGroupedResultsLayout> {
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final maxWidth = (c.maxWidth - LibraryAddResultGrouping.minListWidth)
            .clamp(0.0, double.infinity);
        final width = widget.listWidth.clamp(0.0, maxWidth);
        final onResize = widget.onResize;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: width, child: widget.groupList),
            if (onResize == null)
              ColoredBox(
                  color: libraryAddPaneDivider(context),
                  child: const SizedBox(width: 6))
            else
              LibraryAddGroupDivider(
                key: const ValueKey('library-add-results-divider'),
                width: width,
                maxWidth: maxWidth,
                onResize: onResize,
              ),
            Expanded(child: widget.variantList),
          ],
        );
      });
}

/// The drag of the group list's divider, shared by its pieces in the search
/// row and the results so they move and light up as one line, as in the
/// reference.
class LibraryAddGroupDividerDrag extends ChangeNotifier {
  bool _dragging = false;
  bool get dragging => _dragging;

  /// The shown width when the drag began and the pointer's travel since, so
  /// dragging past a limit and back does not move the divider until the
  /// pointer returns to it.
  double _startWidth = 0;
  double _travel = 0;

  void _start(double width) {
    _startWidth = width;
    _travel = 0;
    _dragging = true;
    notifyListeners();
  }

  double _move(double delta) => _startWidth + (_travel += delta);

  void _end() {
    _dragging = false;
    notifyListeners();
  }
}

/// Provides the [LibraryAddGroupDividerDrag] of an Add dialog.
class LibraryAddGroupDividerScope
    extends InheritedNotifier<LibraryAddGroupDividerDrag> {
  const LibraryAddGroupDividerScope(
      {super.key, required super.notifier, required super.child});

  static LibraryAddGroupDividerDrag? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LibraryAddGroupDividerScope>()
      ?.notifier;
}

/// One piece of the group list's divider: the library panes' own, taking the
/// kind accent while any piece is dragged.
class LibraryAddGroupDivider extends StatefulWidget {
  const LibraryAddGroupDivider({
    super.key,
    required this.width,
    required this.onResize,
    this.maxWidth = double.infinity,
    this.showGrip = true,
  });

  /// The group list's shown width.
  final double width;
  final double maxWidth;
  final ValueChanged<double> onResize;
  final bool showGrip;

  @override
  State<LibraryAddGroupDivider> createState() => _LibraryAddGroupDividerState();
}

class _LibraryAddGroupDividerState extends State<LibraryAddGroupDivider> {
  /// Used when no dialog provides a shared drag.
  final _ownDrag = LibraryAddGroupDividerDrag();

  @override
  void dispose() {
    _ownDrag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drag = LibraryAddGroupDividerScope.maybeOf(context) ?? _ownDrag;
    return ListenableBuilder(
      listenable: drag,
      builder: (context, _) => LibraryResizableDivider(
        color: libraryAddPaneDivider(context),
        accentColor: LibraryAccentScope.accentOf(context),
        active: drag.dragging,
        showGrip: widget.showGrip,
        onDragStart: () => drag._start(widget.width),
        onDragEnd: drag._end,
        onDragDelta: (delta) => widget.onResize(drag._move(delta).clamp(
            LibraryAddResultGrouping.minListWidth.clamp(0.0, widget.maxWidth),
            widget.maxWidth)),
      ),
    );
  }
}
