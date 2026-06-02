import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
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
    const shelfThickness = 8.0;
    const shelfShadow = 12.0;
    const shelfOverhang = 8.0;
    final palette = appPalette(context);
    final panelColor = palette.panel;
    final shelfColor = HSLColor.fromColor(panelColor).withLightness(0.18).toColor();
    final shelfHighlight = HSLColor.fromColor(panelColor).withLightness(0.24).toColor();
    return SizedBox(
      height: shelfHeight + shelfThickness + shelfShadow,
      child: Stack(
        children: [
          // Shelf plank with wood-like gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: shelfShadow,
            height: shelfThickness,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [shelfHighlight, shelfColor, shelfColor],
                  stops: const [0.0, 0.3, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // Shelf front lip
          Positioned(
            left: 0,
            right: 0,
            bottom: shelfShadow + shelfThickness - 1,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.divider.withValues(alpha: 0.72),
              ),
            ),
          ),
          // Books
          Positioned(
            left: shelfOverhang,
            right: shelfOverhang,
            bottom: shelfThickness + shelfShadow,
            height: shelfHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final book in books) _buildBook(context, book),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBook(BuildContext context, T item) {
    final entry = entryOf(item);
    final selected = isSelected(item);
    final coverUrl = entry.displayCoverUrl;
    final bookHeight = shelfHeight - 8;
    final bookW = bookWidth - 8;
    final palette = appPalette(context);
    return Semantics(
      button: true,
      label: entry.resolvedTitle,
      child: GestureDetector(
        onTap: () => onTap(item),
        onDoubleTap: () => onDoubleTap(item),
        onSecondaryTapUp: onSecondaryTapUp != null
            ? (d) => onSecondaryTapUp!(item, d)
            : null,
        child: Tooltip(
        message: entry.resolvedTitle,
        waitDuration: const Duration(milliseconds: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: bookW,
                height: bookHeight,
                transformAlignment: Alignment.bottomCenter,
                transform: selected
                    ? (Matrix4.identity()..setTranslationRaw(0.0, -6.0, 0.0))
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    topRight: Radius.circular(3),
                  ),
                  border: selected
                      ? Border.all(color: accent, width: 2)
                      : null,
                  boxShadow: [
                    // Main drop shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: selected ? 0.7 : 0.45),
                      blurRadius: selected ? 10 : 5,
                      offset: Offset(selected ? 3 : 2, selected ? 4 : 2),
                    ),
                    // Subtle inner glow on left (spine highlight)
                    BoxShadow(
                      color: palette.surfaceSubtle.withValues(alpha: 0.46),
                      blurRadius: 1,
                      offset: const Offset(-1, 0),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover or fallback
                    if (coverUrl != null)
                      LibraryCoverImage(
                        title: entry.resolvedTitle,
                        imageUrl: coverUrl,
                        fit: BoxFit.cover,
                      )
                    else
                      Container(
                        color: palette.panel,
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
                    // Spine edge gradient (left side)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top edge highlight
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              palette.surfaceSubtle.withValues(alpha: 0.82),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
