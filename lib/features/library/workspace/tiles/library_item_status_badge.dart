import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:flutter/material.dart';

/// An item's status on a card or cover: its copy's Collection Status, else
/// its loan or wish-list state.
class LibraryItemStatusBadge extends StatelessWidget {
  const LibraryItemStatusBadge(
      {super.key,
      required this.item,
      required this.selected,
      required this.style,
      this.width = 25,
      this.height = 23});

  final LibraryProjectionView item;
  final bool selected;
  final LibraryCollectionStatusMarkStyle style;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final source = item.source;
    final entry = source.libraryEntrySummary;
    if (source.loans.isEmpty && entry != null) {
      // The entry's own Collection Status, in its fixed colour.
      return LibraryCollectionStatusMark(
        collectionStatus:
            libraryCollectionStatusFromValue(entry.collectionStatus),
        style: style,
        onSelection: selected,
        width: width,
        height: height,
        radius: 5,
      );
    }
    final (IconData, Color, String)? status = source.loans.isNotEmpty
        ? (Icons.schedule_rounded, Colors.amber.shade700, 'On Loan')
        : source.isWishlisted
            ? (Icons.bookmark_outline_rounded, Colors.orange, 'Wishlist')
            : null;
    if (status == null) return const SizedBox.shrink();
    final (icon, color, label) = status;
    return Tooltip(
      message: label,
      child: Container(
        width: 21,
        height: 21,
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(Colors.black.withValues(alpha: 0.35), color)
              : color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}
