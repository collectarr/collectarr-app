import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/actions/import_export_actions.dart';

/// Kind-owned export contribution consumed by a generic preview host.
///
/// The host supplies mixed Shelf rows and receives only structural export
/// artifacts. Format parsing and domain mapping stay inside the owning kind.
abstract interface class LibraryExportPreviewContributor {
  CatalogMediaKind get kind;

  List<ExportPreviewArtifact> build(Iterable<ShelfEntry> entries);
}
