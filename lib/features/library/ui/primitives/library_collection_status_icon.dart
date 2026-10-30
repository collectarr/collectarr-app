import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:flutter/material.dart';

/// Collection status glyph on its status color, shared by filters, cards and
/// Add actions.
class LibraryCollectionStatusIcon extends StatelessWidget {
  const LibraryCollectionStatusIcon(
      {super.key, required this.collectionStatus, this.size = 20});

  final LibraryCollectionStatusScope collectionStatus;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: collectionStatus.color,
            borderRadius: BorderRadius.circular(3)),
        child:
            Icon(collectionStatus.icon, size: size * .62, color: Colors.white),
      );
}

/// Where a status mark sits, which decides how In Collection is drawn.
enum LibraryCollectionStatusMarkStyle {
  /// List rows: a bare blue tick, white on the blue selected row.
  row,

  /// Over a cover (Vertical Cards, Covers, Shelves): a white tick with a dark
  /// outline, readable on any artwork.
  cover,

  /// Beside card text (Horizontal Cards): a blue pill like every other status.
  pill,
}

/// The reference's status mark on list rows and cards: every status but In
/// Collection is its glyph in white on a rounded pill of its colour.
class LibraryCollectionStatusMark extends StatelessWidget {
  const LibraryCollectionStatusMark({
    super.key,
    required this.collectionStatus,
    this.style = LibraryCollectionStatusMarkStyle.row,
    this.onSelection = false,
    this.width = 25,
    this.height = 22,
    this.radius = 4,
  });

  final LibraryCollectionStatusScope collectionStatus;
  final LibraryCollectionStatusMarkStyle style;
  final bool onSelection;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bare =
        collectionStatus == LibraryCollectionStatusScope.inCollection &&
            style != LibraryCollectionStatusMarkStyle.pill;
    final glyph = switch ((bare, style)) {
      (true, LibraryCollectionStatusMarkStyle.cover) => Icon(
          collectionStatus.icon,
          size: height * .8,
          color: Colors.white,
          shadows: _outline),
      (true, _) => Icon(collectionStatus.icon,
          size: 16, color: onSelection ? Colors.white : collectionStatus.color),
      _ => Icon(collectionStatus.icon, size: height * .6, color: Colors.white),
    };
    return Tooltip(
      message: collectionStatus.label,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: bare
            ? null
            : BoxDecoration(
                color: collectionStatus.color,
                borderRadius: BorderRadius.circular(radius)),
        child: glyph,
      ),
    );
  }
}

/// The reference's #3B3B3B outline around the white cover tick.
const _outline = [
  Shadow(color: Color(0xff3b3b3b), offset: Offset(1, 0)),
  Shadow(color: Color(0xff3b3b3b), offset: Offset(-1, 0)),
  Shadow(color: Color(0xff3b3b3b), offset: Offset(0, 1)),
  Shadow(color: Color(0xff3b3b3b), offset: Offset(0, -1)),
];
