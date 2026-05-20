import 'package:flutter/material.dart';

class GenericToolbarCounts {
  const GenericToolbarCounts({
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

enum GenericQuickView {
  owned,
  wishlist,
  missingCovers,
  missingMetadata,
}

extension GenericQuickViewUi on GenericQuickView {
  String get label {
    return switch (this) {
      GenericQuickView.owned => 'Owned',
      GenericQuickView.wishlist => 'Wishlist',
      GenericQuickView.missingCovers => 'Missing covers',
      GenericQuickView.missingMetadata => 'Missing metadata',
    };
  }

  IconData get icon {
    return switch (this) {
      GenericQuickView.owned => Icons.check_box,
      GenericQuickView.wishlist => Icons.star,
      GenericQuickView.missingCovers => Icons.image_not_supported_outlined,
      GenericQuickView.missingMetadata => Icons.manage_search,
    };
  }
}
