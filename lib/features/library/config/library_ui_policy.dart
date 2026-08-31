import 'package:flutter/foundation.dart';

@immutable
class LibraryUiPolicy {
  const LibraryUiPolicy({
    this.coverAspectRatio = 1.53,
    this.wideDialog = false,
    this.prefersSquareCovers = false,
    this.canScanCover = true,
    this.supportsOwnedItemImages = true,
  });

  const LibraryUiPolicy.squareCovers({
    this.wideDialog = false,
    this.canScanCover = true,
    this.supportsOwnedItemImages = true,
  })  : coverAspectRatio = 1.0,
        prefersSquareCovers = true;

  final double coverAspectRatio;
  final bool wideDialog;
  final bool prefersSquareCovers;
  final bool canScanCover;
  final bool supportsOwnedItemImages;
}
