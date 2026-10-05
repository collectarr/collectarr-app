import 'package:collectarr_app/core/models/catalog_media_kind.dart';

/// Marker for kind-owned data carried opaquely through mixed workspace rows.
abstract interface class LibraryWorkspaceKindData {
  CatalogMediaKind get kind;
  String get displayLabel;
}
