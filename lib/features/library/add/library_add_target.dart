enum LibraryAddTarget { owned, wishlist, track }

extension LibraryAddTargetLabels on LibraryAddTarget {
  String get destinationLabel {
    return switch (this) {
      LibraryAddTarget.owned => 'Collection',
      LibraryAddTarget.wishlist => 'Wishlist',
      LibraryAddTarget.track => 'Tracking',
    };
  }

  String get actionLabel {
    return switch (this) {
      LibraryAddTarget.owned => 'Add as owned',
      LibraryAddTarget.wishlist => 'Add to wishlist',
      LibraryAddTarget.track => 'Track item',
    };
  }
}
