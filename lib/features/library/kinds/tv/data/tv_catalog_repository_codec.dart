import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_codec_support.dart';
import 'package:collectarr_app/features/catalog/catalog_kind_repository_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';

final class TvCatalogRepositoryCodec implements CatalogKindRepositoryCodec {
  const TvCatalogRepositoryCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

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
    if (metadata is TvSeries) return metadata;
    return metadata is Map ? TvSeries.fromJson(item.payload) : null;
  }

  @override
  CatalogItemDto withTypedMetadata(CatalogItemDto item) =>
      switch (typedMetadataFromDto(item)) {
        final metadata? => item.withKindMetadata(metadata),
        _ => item,
      };

  @override
  Future<void> upsert(LocalDatabase db, CatalogItemDto item) {
    return TvRepository(db).updateSeries(
      TvSeries.fromJson(catalogPayloadFor(item)),
    );
  }

  @override
  Future<List<CatalogItemDto>> list(LocalDatabase db) async {
    final media = await TvRepository(db).search();
    return [
      for (final item in media) _projection(item),
    ];
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final series = await TvRepository(db).search();
    return [
      for (final item in series)
        CatalogDisplaySummary.work(
          kind: kind,
          id: item.id,
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

CatalogItemDto _projection(TvSeries item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id;
  payload['kind'] ??= 'tv';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(TvSeries.fromJson(projection.payload));
}
