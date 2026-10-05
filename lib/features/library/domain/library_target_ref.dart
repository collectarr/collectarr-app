import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';

/// Navigation target for a canonical Catalog Item or an independent local
/// Library Entry. The two identity namespaces are never converted into each
/// other; an entry's optional Core provenance is stored on the entry itself.
sealed class LibraryTargetRef {
  const LibraryTargetRef();

  String get id;
  CatalogMediaKind get kind;
  String get stableKey => switch (this) {
        CatalogTargetRef(:final ref) => 'catalog_item:${ref.key}',
        EntryTargetRef(:final ref) => 'library_entry:${ref.key}',
      };

  LibraryEntryRef? get libraryEntryRef => switch (this) {
        CatalogTargetRef() => null,
        EntryTargetRef(:final ref) => ref,
      };

  CatalogItemRef? get catalogItemRef => switch (this) {
        CatalogTargetRef(:final ref) => ref,
        EntryTargetRef() => null,
      };
}

final class CatalogTargetRef extends LibraryTargetRef {
  const CatalogTargetRef(this.ref);

  final CatalogItemRef ref;

  @override
  String get id => ref.id;

  @override
  CatalogMediaKind get kind => ref.kind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CatalogTargetRef && other.ref == ref;

  @override
  int get hashCode => Object.hash(CatalogTargetRef, ref);
}

final class EntryTargetRef extends LibraryTargetRef {
  const EntryTargetRef(this.ref);

  final LibraryEntryRef ref;

  @override
  String get id => ref.id.value;

  @override
  CatalogMediaKind get kind => ref.kind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EntryTargetRef && other.ref == ref;

  @override
  int get hashCode => Object.hash(EntryTargetRef, ref);
}
