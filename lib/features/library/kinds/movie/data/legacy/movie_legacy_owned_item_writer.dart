import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/legacy/movie_owned_item_legacy_adapter.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/legacy_owned_item_writer.dart';

/// Movie-owned compatibility writer. Movie owns the legacy-to-typed mapping.
final class MovieLegacyOwnedItemWriter implements LegacyOwnedItemWriter {
  MovieLegacyOwnedItemWriter(LocalDatabase database)
      : _repository = MovieOwnedRepository(database);

  final MovieOwnedRepository _repository;

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  Future<void> upsert(OwnedItem item) {
    return _repository.upsert(MovieOwnedItemLegacyAdapter.fromLegacy(item));
  }
}
