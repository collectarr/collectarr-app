import 'package:collectarr_app/core/models/catalog_entity_ref.dart';

/// Structural catalog data carried by a mixed Shelf source.
///
/// The source deliberately exposes only values needed to identify and render
/// a workspace entry. Each kind owns the concrete implementation and keeps
/// its media/release graph behind this boundary.
abstract interface class LibraryWorkspaceCatalogData {
  CatalogEntityRef get ref;
  CatalogMediaKind get kind;
  String get title;
  DateTime? get releaseDate;
  String? get coverImageUrl;
  String? get thumbnailImageUrl;
}

/// Optional descriptive text for catalog kinds that model it.
abstract interface class LibraryWorkspaceCatalogSynopsisData {
  String? get synopsis;
}

String? libraryWorkspaceCatalogSynopsis(
  LibraryWorkspaceCatalogData? data,
) {
  if (data is! LibraryWorkspaceCatalogSynopsisData) return null;
  return (data as LibraryWorkspaceCatalogSynopsisData).synopsis;
}
