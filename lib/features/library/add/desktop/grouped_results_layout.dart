import 'package:collectarr_app/features/library/add/contracts/result_policy.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:flutter/material.dart';

/// Desktop grouped results retain both panes and their divider, which can be
/// dragged to resize the group list.
class LibraryAddDesktopGroupedResultsLayout extends StatelessWidget {
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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => _row(
            context,
            listWidth.clamp(
                0.0,
                (constraints.maxWidth - LibraryAddResultGrouping.minListWidth)
                    .clamp(0.0, double.infinity))),
      );

  Widget _row(BuildContext context, double width) => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: width, child: groupList),
          MouseRegion(
            cursor: onResize == null
                ? MouseCursor.defer
                : SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              key: const ValueKey('library-add-results-divider'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: onResize == null
                  ? null
                  : (details) => onResize!(width + details.delta.dx),
              child: ColoredBox(
                color: libraryAddPaneDivider(context),
                child: SizedBox(
                  width: 6,
                  child: onResize == null
                      ? null
                      : const Center(child: _DividerGrip()),
                ),
              ),
            ),
          ),
          Expanded(child: variantList),
        ],
      );
}

/// The dots that mark the divider as draggable.
class _DividerGrip extends StatelessWidget {
  const _DividerGrip();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              width: 2,
              height: 2,
              margin: const EdgeInsets.symmetric(vertical: 1.5),
              color: Colors.white,
            ),
        ],
      );
}
