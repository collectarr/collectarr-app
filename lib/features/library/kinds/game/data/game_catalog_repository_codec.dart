import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';

final class GameCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const GameCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.game;

  @override
  Future<int> countCatalogValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) async {
    return countCatalogProjectionValues(
      await list(db),
      fields: _catalogFieldsFor(semanticName),
      normalizedValue: normalizedValue,
    );
  }

  @override
  int? replacementValueCents(CatalogItemDto item) =>
      _replacementValueFromPayload(item);

  @override
  Object? typedMetadataFromDto(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is GameMedia) return metadata;
    return metadata is Map ? GameMedia.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return GameRepository(db).updateMedia(
      GameMedia.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await GameRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final media = await GameRepository(db).search();
    return [
      for (final item in media)
        CatalogDisplaySummary.work(
          kind: kind,
          id: item.id.value,
          title: item.title,
        ),
    ];
  }
}

Iterable<String> _catalogFieldsFor(String semanticName) =>
    switch (semanticName) {
      'publisher' => const ['publisher'],
      'imprint' => const ['imprint'],
      'language' => const ['language'],
      'country' => const ['country'],
      'age_rating' => const ['age_rating'],
      'series_group' => const ['series_group'],
      'physical_format' || 'format' => const [
          'physical_format',
          'physical_format_label'
        ],
      _ => const <String>[],
    };

int? _replacementValueFromPayload(CatalogItemDto item) {
  final direct = item.payload['cover_price_cents'];
  if (direct is num) return direct.toInt();
  final publishing = item.payload['publishing'];
  final nested = publishing is Map ? publishing['cover_price_cents'] : null;
  return nested is num ? nested.toInt() : null;
}

CatalogItemDto _projection(GameMedia item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'game';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(GameMedia.fromJson(projection.payload));
}
