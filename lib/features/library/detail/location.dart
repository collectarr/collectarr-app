import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';

/// Stable identity: catalog and local entry IDs have distinct namespaces.
class LibraryDetailLocation {
  const LibraryDetailLocation(this.target);
  final LibraryTargetRef target;
  Uri toUri() => Uri(path: '/detail', queryParameters: {
        'kind': target.kind.apiValue,
        'target': target is EntryTargetRef ? 'entry' : 'catalog',
        'id': target.id
      });
  static LibraryDetailLocation? fromUri(Uri uri) {
    final kind = catalogMediaKindFromApiValue(uri.queryParameters['kind']);
    final id = uri.queryParameters['id'];
    if (kind.isUnknown || id == null || id.trim().isEmpty || id != id.trim()) {
      return null;
    }
    return switch (uri.queryParameters['target']) {
      'entry' => LibraryDetailLocation(
          EntryTargetRef(LibraryEntryRef(kind: kind, id: LibraryEntryId(id)))),
      'catalog' => LibraryDetailLocation(
          CatalogTargetRef(CatalogItemRef(kind: kind, id: id))),
      _ => null,
    };
  }
}
