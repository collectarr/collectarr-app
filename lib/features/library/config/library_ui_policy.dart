import 'package:flutter/foundation.dart';

@immutable
class LibraryUiPolicy {
  const LibraryUiPolicy({
    this.coverAspectRatio = 1.53,
    this.wideDialog = false,
  });

  final double coverAspectRatio;
  final bool wideDialog;
}
