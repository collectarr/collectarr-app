/// Kind-neutral link projection used by detail and inspector presentation.
/// URL semantics remain owned by the kind.
final class LibraryWorkspaceLinkSummary {
  const LibraryWorkspaceLinkSummary({
    required this.url,
    this.label,
    this.source,
    this.isTrailer = true,
    this.isAutomatic = true,
  });

  final String url;
  final String? label;
  final String? source;
  final bool isTrailer;
  final bool isAutomatic;

  String get displayLabel => label?.trim().isNotEmpty == true ? label! : url;
}
