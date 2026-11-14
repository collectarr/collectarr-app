import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:collectarr_app/features/library/workspace/layout/resizable_pane.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';

/// Desktop grouped results retain both panes and their divider, which can be
/// dragged to resize the group list. The divider is the library panes' own:
/// it takes the kind accent while dragged and stays under the pointer.
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
  /// The shown width when the drag began and the pointer's travel since, so
  /// dragging past a limit and back does not move the divider until the
  /// pointer returns to it.
  double _dragStartWidth = 0;
  double _dragTravel = 0;

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
              LibraryResizableDivider(
                key: const ValueKey('library-add-results-divider'),
                color: libraryAddPaneDivider(context),
                accentColor: LibraryAccentScope.accentOf(context),
                onDragStart: () {
                  _dragStartWidth = width;
                  _dragTravel = 0;
                },
                onDragDelta: (delta) {
                  _dragTravel += delta;
                  onResize((_dragStartWidth + _dragTravel).clamp(
                      LibraryAddResultGrouping.minListWidth
                          .clamp(0.0, maxWidth),
                      maxWidth));
                },
              ),
            Expanded(child: widget.variantList),
          ],
        );
      });
}
