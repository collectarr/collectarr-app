/// The semantic level represented by a provider result.
///
/// A provider result is either a collectible work (for example a MusicBrainz
/// release group) or a concrete release/edition.  The scope is part of the
/// contract so callers never have to infer it from payload keys.
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
