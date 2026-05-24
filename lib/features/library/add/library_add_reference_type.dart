enum LibraryAddReferenceType { media, release, bundleRelease }

extension LibraryAddReferenceTypeLabels on LibraryAddReferenceType {
  String labelForKind(String kind) {
    final normalizedKind = kind.trim().toLowerCase();
    return switch (this) {
      LibraryAddReferenceType.media =>
        normalizedKind == 'music' ? 'Album' : 'Media',
      LibraryAddReferenceType.release => 'Edition',
      LibraryAddReferenceType.bundleRelease => 'Bundle',
    };
  }

  String helperLabelForKind(String kind) {
    final normalizedKind = kind.trim().toLowerCase();
    return switch (this) {
      LibraryAddReferenceType.media => normalizedKind == 'music'
          ? 'Track or save the album itself.'
          : 'Track or save the canonical item itself.',
      LibraryAddReferenceType.release => normalizedKind == 'music'
          ? 'Attach ownership to an album edition. Pick a physical release only if you want one exact format or pressing.'
          : 'Attach ownership to a specific edition. Pick a physical release only if you want one exact variant.',
      LibraryAddReferenceType.bundleRelease => 'Attach ownership to a bundle that contains this item',
    };
  }
}