import 'package:flutter/material.dart';

/// The phone grid keeps manual Add below the issue covers, across the width.
class LibraryAddMobileCoverGrid extends StatelessWidget {
  const LibraryAddMobileCoverGrid({
    super.key,
    required this.width,
    required this.count,
    required this.coverAspectRatio,
    required this.minimumWidth,
    required this.margin,
    required this.itemBuilder,
    this.onAddManually,
  });

  final double width;
  final int count;
  final double coverAspectRatio;
  final double minimumWidth;
  final double margin;
  final Widget Function(int index, double coverHeight) itemBuilder;
  final VoidCallback? onAddManually;

  @override
  Widget build(BuildContext context) {
    final columns =
        ((width - 2 * margin) / minimumWidth).floor().clamp(1, 1 << 20);
    final coverHeight =
        ((width - 2 * margin) / columns - 4 * margin) * coverAspectRatio;
    return CustomScrollView(
      key: const ValueKey('library-add-cover-grid'),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(margin),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: coverHeight + 88,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.all(margin),
                child: itemBuilder(index, coverHeight),
              ),
              childCount: count,
            ),
          ),
        ),
        if (onAddManually != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: OutlinedButton.icon(
                key: const ValueKey('library-add-cover-not-found'),
                onPressed: onAddManually,
                icon: const Icon(Icons.add),
                label: const Text('Not found? Add it manually'),
              ),
            ),
          ),
      ],
    );
  }
}
