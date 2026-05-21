import 'package:flutter/material.dart';

class LibraryToolbarCounts {
  const LibraryToolbarCounts({
    this.shown = 0,
    this.total = 0,
    this.owned = 0,
    this.wishlist = 0,
    this.missingCover = 0,
    this.missingMetadata = 0,
    this.totalPricePaidCents = 0,
    this.totalCoverPriceCents = 0,
    this.totalSellPriceCents = 0,
    this.priceCurrency,
  });

  final int shown;
  final int total;
  final int owned;
  final int wishlist;
  final int missingCover;
  final int missingMetadata;
  final int totalPricePaidCents;
  final int totalCoverPriceCents;
  final int totalSellPriceCents;
  final String? priceCurrency;
}

enum LibraryQuickView {
  owned,
  wishlist,
  missingCovers,
  missingMetadata,
  missingGrade,
}

extension LibraryQuickViewUi on LibraryQuickView {
  String get label {
    return switch (this) {
      LibraryQuickView.owned => 'Owned',
      LibraryQuickView.wishlist => 'Wishlist',
      LibraryQuickView.missingCovers => 'Missing covers',
      LibraryQuickView.missingMetadata => 'Missing metadata',
      LibraryQuickView.missingGrade => 'Missing grade',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryQuickView.owned => Icons.check_box,
      LibraryQuickView.wishlist => Icons.star,
      LibraryQuickView.missingCovers => Icons.image_not_supported_outlined,
      LibraryQuickView.missingMetadata => Icons.manage_search,
      LibraryQuickView.missingGrade => Icons.workspace_premium_outlined,
    };
  }

  /// Whether this quick view only applies to types that have grades.
  bool get requiresGrades {
    return this == LibraryQuickView.missingGrade;
  }
}
