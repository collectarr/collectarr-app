import 'package:flutter/foundation.dart';

@immutable
class LibraryUiPolicy {
  const LibraryUiPolicy({
    this.coverAspectRatio = 1 / 1.53,
    this.wideDialog = false,
  });

  /// Cover width / height; portrait covers are below 1.
  final double coverAspectRatio;
  final bool wideDialog;
}
