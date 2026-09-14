/// Small release projection for generic workspace hosts.
///
/// The owning kind decides what a release means and how its concrete domain
/// graph is projected. Generic workspace widgets only render these values;
/// they never reconstruct a catalog edition or inspect semantic payloads.
final class LibraryWorkspaceReleaseSummary {
  const LibraryWorkspaceReleaseSummary({
    required this.id,
    required this.title,
    this.formatLabel,
    this.releaseDate,
    this.variantCount = 0,
    this.variants = const <LibraryWorkspaceVariantSummary>[],
    this.mediaLabels = const <String>[],
    this.runtimeMinutes,
  });

  final String id;
  final String title;
  final String? formatLabel;
  final DateTime? releaseDate;
  final int variantCount;
  final List<LibraryWorkspaceVariantSummary> variants;
  final List<String> mediaLabels;
  final int? runtimeMinutes;

  int get mediaCount => mediaLabels.length;
}

final class LibraryWorkspaceVariantSummary {
  const LibraryWorkspaceVariantSummary({
    required this.id,
    required this.name,
    this.coverImageUrl,
    this.thumbnailImageUrl,
    this.formatLabel,
    this.sku,
    this.isPrimary = false,
  });

  final String id;
  final String name;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;
  final String? formatLabel;
  final String? sku;
  final bool isPrimary;
}

/// Generic link projection. URL semantics remain owned by the kind.
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
