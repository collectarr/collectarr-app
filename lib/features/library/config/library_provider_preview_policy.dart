/// Decides which provider representation the Add host should prefer when it
/// turns a search hit into an editable candidate.
enum LibraryProviderPreviewSource {
  cachedPreview,
  typedCandidate,
}

final class LibraryProviderPreviewPolicy {
  const LibraryProviderPreviewPolicy({
    this.preferredSource = LibraryProviderPreviewSource.cachedPreview,
  });

  final LibraryProviderPreviewSource preferredSource;

  bool get prefersTypedCandidate =>
      preferredSource == LibraryProviderPreviewSource.typedCandidate;
}
