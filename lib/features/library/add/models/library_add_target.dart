enum LibraryAddTarget { entry, wishlist, track }

extension LibraryAddTargetLabels on LibraryAddTarget {
  String get destinationLabel {
    return switch (this) {
      LibraryAddTarget.entry => 'Collection',
      LibraryAddTarget.wishlist => 'Wishlist',
      LibraryAddTarget.track => 'Tracking',
    };
  }

  String get actionLabel {
    return switch (this) {
      LibraryAddTarget.entry => 'Add as entry',
      LibraryAddTarget.wishlist => 'Add to wishlist',
      LibraryAddTarget.track => 'Track item',
    };
  }
}
