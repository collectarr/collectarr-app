import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/workspace/config/library_shelf_style.dart';

import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'library_reveal.dart';
import 'library_shelf_backdrop.dart';

class LibraryShelfView<T> extends ConsumerStatefulWidget {
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
    this.fallbackCoverAspectRatio = 2 / 3,
    this.backgroundColor,
    this.emptyBuilder,
    this.bookHorizontalPadding = 1.0,
    this.itemSpacing = 0,
  });

  final List<T> items;
  final LibraryProjectionView Function(T item) entryOf;
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
  final double fallbackCoverAspectRatio;
  final Color? backgroundColor;
  final WidgetBuilder? emptyBuilder;
  final double bookHorizontalPadding;
  final double itemSpacing;

  @override
  ConsumerState<LibraryShelfView<T>> createState() =>
      _LibraryShelfViewState<T>();
}

class _LibraryShelfViewState<T> extends ConsumerState<LibraryShelfView<T>>
    with LibraryRevealListener {
  final _scrollController = ScrollController();
  ({int booksPerShelf, double pitch})? _layout;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void revealItem(String itemId) {
    final layout = _layout;
    if (layout == null) return;
    final index = widget.items
        .indexWhere((item) => widget.entryOf(item).target.id == itemId);
    if (index < 0) return;
    revealScrollExtent(
      _scrollController,
      leading: (index ~/ layout.booksPerShelf) * layout.pitch,
      extent: layout.pitch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final emptyBuilder = widget.emptyBuilder;
    final backgroundColor = widget.backgroundColor;
    final bookWidth = widget.bookWidth;
    final shelfHeight = widget.shelfHeight;
    final itemSpacing = widget.itemSpacing;
    final style = ref.watch(libraryShelfStyleProvider).value ??
        LibraryShelfStyle.woodLight;
    if (items.isEmpty && emptyBuilder != null) {
      final empty = emptyBuilder(context);
      return ColoredBox(
          color: backgroundColor ?? style.background, child: empty);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const shelfOverhang = 8.0;
        final bookHorizontalPadding = widget.bookHorizontalPadding;
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
        // When the shelf is narrower than the requested cover width, the
        // row's actual cover width shrinks. Scale the row height by the same
        // factor so square Music covers (and portrait covers for other kinds)
        // keep their configured aspect ratio instead of being stretched.
        final effectiveShelfHeight = bookWidth <= 0
            ? shelfHeight
            : shelfHeight * (effectiveBookWidth / bookWidth);
        final booksPerShelf = ((availableShelfWidth + itemSpacing) /
                (effectiveBookVisualWidth + itemSpacing))
            .floor()
            .clamp(1, 100);
        final shelves = <List<T>>[];
        for (var i = 0; i < items.length; i += booksPerShelf) {
          shelves.add(items.sublist(
            i,
            (i + booksPerShelf).clamp(0, items.length),
          ));
        }
        _layout = (
          booksPerShelf: booksPerShelf,
          pitch: effectiveShelfHeight + 20,
        );
        final listView = ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: shelves.length,
          itemBuilder: (context, shelfIndex) {
            return _ShelfRow(
              books: shelves[shelfIndex],
              entryOf: widget.entryOf,
              isActive: widget.isActive,
              isSelected: widget.isSelected,
              selectionEnabled: widget.selectionEnabled,
              onTap: widget.onTap,
              onToggleSelectionItem: widget.onToggleSelectionItem,
              onDoubleTap: widget.onDoubleTap,
              onSecondaryTapUp: widget.onSecondaryTapUp,
              accent: widget.accent,
              shelfHeight: effectiveShelfHeight,
              bookWidth: effectiveBookWidth,
              style: style,
              itemSpacing: itemSpacing,
              fallbackCoverAspectRatio: widget.fallbackCoverAspectRatio,
            );
          },
        );
        return LibraryShelfBackdrop(
          style: style,
          shelfPitch: effectiveShelfHeight + 20,
          color: backgroundColor ?? style.background,
          child: listView,
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
    required this.itemSpacing,
    required this.style,
    required this.fallbackCoverAspectRatio,
  });

  final List<T> books;
  final LibraryProjectionView Function(T item) entryOf;
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
  final double itemSpacing;
  final LibraryShelfStyle style;
  final double fallbackCoverAspectRatio;

  @override
  Widget build(BuildContext context) {
    const shelfThickness = 8.0;
    const shelfShadow = 12.0;
    const shelfOverhang = 8.0;
    final shelfColor = style.plank;
    final shelfHighlight = style.highlight;
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
                color: shelfHighlight,
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
              spacing: itemSpacing,
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
      label: entry.dto.primaryLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: SizedBox(
          width: bookW,
          height: bookHeight,
          child: LibraryCoverTile(
            item: entry,
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
            fallbackCoverAspectRatio: fallbackCoverAspectRatio,
            selectedColor: palette.utilityAction,
            accentColor: accent,
            selectionColor: accent,
            mutedTextColor: palette.textMuted,
          ),
        ),
      ),
    );
  }
}
