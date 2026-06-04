import 'dart:math' as math;

import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryShelfView<T> extends StatelessWidget {
  const LibraryShelfView({
    super.key,
    required this.items,
    required this.entryOf,
    required this.isActive,
    required this.isSelected,
    required this.selectionEnabled,
    required this.onTap,
    required this.onToggleSelectionItem,
    required this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.accent,
    this.shelfHeight = 200.0,
    this.bookWidth = 120.0,
    this.emptyBuilder,
  });

  final List<T> items;
  final LibraryWorkspaceEntry Function(T item) entryOf;
  final bool Function(T item) isActive;
  final bool Function(T item) isSelected;
  final bool selectionEnabled;
  final void Function(T item) onTap;
  final void Function(T item) onToggleSelectionItem;
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
        const shelfOverhang = 8.0;
        const bookHorizontalPadding = 1.0;
        const bookInnerInset = 8.0;
        final availableShelfWidth =
            math.max(1.0, constraints.maxWidth - (shelfOverhang * 2));
        final requestedBookVisualWidth = math.max(
            1.0, bookWidth - bookInnerInset + (bookHorizontalPadding * 2));
        final effectiveBookVisualWidth =
            math.min(requestedBookVisualWidth, availableShelfWidth);
        final effectiveBookWidth = effectiveBookVisualWidth +
            bookInnerInset -
            (bookHorizontalPadding * 2);
        final booksPerShelf = (availableShelfWidth / effectiveBookVisualWidth)
            .floor()
            .clamp(1, 100);
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
              isActive: isActive,
              isSelected: isSelected,
              selectionEnabled: selectionEnabled,
              onTap: onTap,
              onToggleSelectionItem: onToggleSelectionItem,
              onDoubleTap: onDoubleTap,
              onSecondaryTapUp: onSecondaryTapUp,
              accent: accent,
              shelfHeight: shelfHeight,
              bookWidth: effectiveBookWidth,
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
    required this.isActive,
    required this.isSelected,
    required this.selectionEnabled,
    required this.onTap,
    required this.onToggleSelectionItem,
    required this.onDoubleTap,
    this.onSecondaryTapUp,
    required this.accent,
    required this.shelfHeight,
    required this.bookWidth,
  });

  final List<T> books;
  final LibraryWorkspaceEntry Function(T item) entryOf;
  final bool Function(T item) isActive;
  final bool Function(T item) isSelected;
  final bool selectionEnabled;
  final void Function(T item) onTap;
  final void Function(T item) onToggleSelectionItem;
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
    final shelfColor =
        HSLColor.fromColor(panelColor).withLightness(0.18).toColor();
    final shelfHighlight =
        HSLColor.fromColor(panelColor).withLightness(0.24).toColor();
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
    final active = isActive(item);
    final selected = isSelected(item);
    final bookHeight = shelfHeight - 8;
    final bookW = bookWidth - 8;
    final palette = appPalette(context);
    return Semantics(
      button: true,
      label: entry.resolvedTitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: SizedBox(
          width: bookW,
          height: bookHeight,
          child: LibraryCoverTile(
            entry: entry,
            active: active,
            selected: selected,
            selectionMode: selectionEnabled,
            onTap: () => onTap(item),
            onSelectionToggleTap: () => onToggleSelectionItem(item),
            onDoubleTap: () => onDoubleTap(item),
            onSecondaryTapUp: onSecondaryTapUp != null
                ? (d) => onSecondaryTapUp!(item, d)
                : null,
            coverSize: bookW,
            selectedColor: palette.selection,
            accentColor: accent,
            selectionColor: accent,
            mutedTextColor: palette.textMuted,
          ),
        ),
      ),
    );
  }
}
