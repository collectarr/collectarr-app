import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryShelfView<T> extends StatelessWidget {
  const LibraryShelfView({
    super.key,
    required this.items,
    required this.entryOf,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.accent,
    this.shelfHeight = 200.0,
    this.bookWidth = 120.0,
    this.emptyBuilder,
  });

  final List<T> items;
  final LibraryWorkspaceEntry Function(T item) entryOf;
  final bool Function(T item) isSelected;
  final void Function(T item) onTap;
  final void Function(T item) onDoubleTap;
  final void Function(T item, TapUpDetails details)? onSecondaryTapUp;
  final Color accent;
  final double shelfHeight;
  final double bookWidth;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && emptyBuilder != null) {
      return emptyBuilder!(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final booksPerShelf =
            (constraints.maxWidth / bookWidth).floor().clamp(1, 100);
        final shelves = <List<T>>[];
        for (var i = 0; i < items.length; i += booksPerShelf) {
          shelves.add(items.sublist(
            i,
            (i + booksPerShelf).clamp(0, items.length),
          ));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: shelves.length,
          itemBuilder: (context, shelfIndex) {
            return _ShelfRow(
              books: shelves[shelfIndex],
              entryOf: entryOf,
              isSelected: isSelected,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onSecondaryTapUp: onSecondaryTapUp,
              accent: accent,
              shelfHeight: shelfHeight,
              bookWidth: bookWidth,
            );
          },
        );
      },
    );
  }
}

class _ShelfRow<T> extends StatelessWidget {
  const _ShelfRow({
    required this.books,
    required this.entryOf,
    required this.isSelected,
    required this.onTap,
    required this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.accent,
    required this.shelfHeight,
    required this.bookWidth,
  });

  final List<T> books;
  final LibraryWorkspaceEntry Function(T item) entryOf;
  final bool Function(T item) isSelected;
  final void Function(T item) onTap;
  final void Function(T item) onDoubleTap;
  final void Function(T item, TapUpDetails details)? onSecondaryTapUp;
  final Color accent;
  final double shelfHeight;
  final double bookWidth;

  @override
  Widget build(BuildContext context) {
    const shelfThickness = 6.0;
    const shelfShadow = 10.0;
    final shelfColor = HSLColor.fromColor(kAppPanel).withLightness(0.18).toColor();
    return SizedBox(
      height: shelfHeight + shelfThickness + shelfShadow,
      child: Stack(
        children: [
          // Shelf plank
          Positioned(
            left: 0,
            right: 0,
            bottom: shelfShadow,
            height: shelfThickness,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: shelfColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Books
          Positioned(
            left: 12,
            right: 12,
            bottom: shelfThickness + shelfShadow,
            height: shelfHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final book in books) _buildBook(book),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBook(T item) {
    final entry = entryOf(item);
    final selected = isSelected(item);
    final coverUrl = entry.displayCoverUrl;
    final bookHeight = shelfHeight - 8;
    final bookW = bookWidth - 8;
    return GestureDetector(
      onTap: () => onTap(item),
      onDoubleTap: () => onDoubleTap(item),
      onSecondaryTapUp: onSecondaryTapUp != null
          ? (d) => onSecondaryTapUp!(item, d)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: bookW,
              height: bookHeight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
                border: selected
                    ? Border.all(color: accent, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: coverUrl != null
                  ? LibraryCoverImage(
                      title: entry.resolvedTitle,
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: kAppPanelRaised,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        entry.resolvedTitle,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
