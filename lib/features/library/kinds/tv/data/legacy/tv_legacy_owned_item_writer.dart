import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/legacy/tv_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_owned_repository.dart';

/// TV-owned compatibility writer. TV owns the legacy-to-typed mapping.
final class TvLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  TvLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = TvOwnedRepository(database);

  final TvOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(TvOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
