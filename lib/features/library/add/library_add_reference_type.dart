enum LibraryAddReferenceType { media, release, bundleRelease }

extension LibraryAddReferenceTypeLabels on LibraryAddReferenceType {
  String get label {
    return switch (this) {
      LibraryAddReferenceType.media => 'Media',
      LibraryAddReferenceType.release => 'Release',
      LibraryAddReferenceType.bundleRelease => 'Bundle',
    };
  }

  String get helperLabel {
    return switch (this) {
      LibraryAddReferenceType.media => 'Track or save the canonical item itself',
      LibraryAddReferenceType.release => 'Attach ownership to the item\'s main release',
      LibraryAddReferenceType.bundleRelease => 'Attach ownership to a bundle that contains this item',
    };
  }
}