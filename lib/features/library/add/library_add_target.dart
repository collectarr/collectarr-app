enum LibraryAddTarget { owned, wishlist }

extension LibraryAddTargetLabels on LibraryAddTarget {
  String get destinationLabel {
    return switch (this) {
      LibraryAddTarget.owned => 'Collection',
      LibraryAddTarget.wishlist => 'Wishlist',
    };
  }

  String get actionLabel {
    return switch (this) {
      LibraryAddTarget.owned => 'Add as owned',
      LibraryAddTarget.wishlist => 'Add to wishlist',
    };
  }
}
