import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';

final class MusicCatalogTransportCodec
    implements CatalogKindTransportCodec<MusicRelease> {
  const MusicCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.music;

  @override
  MusicRelease decode(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is MusicRelease) return metadata;
    return MusicRelease.fromJson(catalogTransportPayloadFor(item));
  }

  @override
  Future<void> upsert(LocalDatabase db, MusicRelease item) {
    return MusicRepository(db).updateRelease(item);
  }

  @override
  CatalogDisplaySummary summarize(MusicRelease item) =>
      CatalogDisplaySummary.work(
        kind: kind,
        id: item.id.value,
        title: item.title,
      );

  @override
  Future<int> countCatalogValue(
    LocalDatabase db,
    String semanticName,
    String normalizedValue,
  ) async {
    return _countCatalogProjectionValues(
      await listTransport(db),
      fields: _catalogFieldsFor(semanticName),
      normalizedValue: normalizedValue,
    );
  }

  @override
  Future<Map<String, int>> replacementValuesByIds(
    LocalDatabase db,
    Iterable<String> ids,
  ) async {
    final wanted = ids.toSet();
    if (wanted.isEmpty) return const {};
    final result = <String, int>{};
    for (final item in await listTransport(db)) {
      if (!wanted.contains(item.id)) continue;
      final value = _replacementValueFromPayload(item);
      if (value != null) result[item.id] = value;
    }
    return result;
  }

  @override
  Future<void> captureDerivedData(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    CatalogItemDto item,
  ) async {
    await captureDerivedDataTyped(pickLists, serialAuthority, decode(item));
  }

  @override
  Future<void> captureDerivedDataTyped(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    MusicRelease item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataFromTyped(item),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  CatalogKindDerivedData? _derivedDataFromTyped(MusicRelease item) =>
      catalogDerivedDataFor(
        kind: kind,
        metadata: item,
        pickListContributors: defaultPickListDefinitionContributors,
        serialAuthorityContributors: collectarrSerialAuthorityContributors,
      );

  @override
  Future<void> upsertTransport(LocalDatabase db, CatalogItemDto item) {
    return upsert(db, decode(item));
  }

  @override
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) async {
    final releases = await MusicRepository(db).search();
    return [
      for (final item in releases) _projection(item),
    ];
  }

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final releases = await MusicRepository(db).search();
    return [
      for (final item in releases) summarize(item),
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

Future<int> _countCatalogProjectionValues(
  Iterable<CatalogItemDto> items, {
  required Iterable<String> fields,
  required String normalizedValue,
}) async {
  final fieldNames = fields.toSet();
  if (fieldNames.isEmpty || normalizedValue.trim().isEmpty) return 0;
  var count = 0;
  for (final item in items) {
    if (fieldNames.any((field) {
      final value = item.payload[field];
      return value is String &&
          value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ==
              normalizedValue;
    })) {
      count++;
    }
  }
  return count;
}

CatalogItemDto _projection(MusicRelease item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'music';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(MusicRelease.fromJson(projection.payload));
}
