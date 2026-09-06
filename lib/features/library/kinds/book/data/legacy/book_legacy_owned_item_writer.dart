import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/legacy/book_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Book-owned compatibility writer. Book owns the legacy-to-typed mapping.
final class BookLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  BookLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = BookOwnedRepository(database);

  final BookOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(BookOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
