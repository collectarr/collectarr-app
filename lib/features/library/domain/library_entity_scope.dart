/// Structural level represented by a library entity reference.
///
/// Every library kind has the same entity topology. A kind may populate a
/// level from Core/provider data or require it to be created explicitly, but
/// the relationship itself is always Work -> Release -> Copy.
enum LibraryEntityScope {
  work('work'),
  release('release'),
  copy('copy');

  const LibraryEntityScope(this.apiValue);

  final String apiValue;

  static LibraryEntityScope fromApiValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'work' => LibraryEntityScope.work,
      'release' || 'edition' => LibraryEntityScope.release,
      'copy' => LibraryEntityScope.copy,
      _ => throw FormatException('Unsupported provider entity scope: $value'),
    };
  }
}
