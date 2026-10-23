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
