import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_data.dart';

final class MovieCatalogTransportCodec
    implements CatalogKindTransportCodec<MovieCatalogMetadata> {
  const MovieCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.movie;

  @override
  MovieCatalogMetadata decode(CatalogItemDto item) =>
      MovieCatalogMetadata.fromJson(item.kindData);

  @override
  MovieCatalogMetadata decodeKindData(Map<String, dynamic> kindData) =>
      MovieCatalogMetadata.fromJson(kindData);

  @override
  CatalogDisplaySummary summarize(
    String catalogItemId,
    MovieCatalogMetadata item,
  ) =>
      CatalogDisplaySummary.forCatalogItem(
        kind: kind,
        id: catalogItemId,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  MovieWorkspaceData workspaceData(CatalogItemDto item) =>
      MovieWorkspaceData(metadata: decode(item));

  @override
  MovieWorkspaceData workspaceDataFromKindData(
    Map<String, dynamic> kindData,
  ) =>
      MovieWorkspaceData(metadata: MovieCatalogMetadata.fromJson(kindData));

  @override
  Future<Map<String, int>> countCatalogValues(
    LocalDatabase db,
    String listName,
    Iterable<String> normalizedValues,
  ) async {
    final contributor = defaultPickListDefinitionContributors.singleWhere(
      (contributor) => contributor.kind == kind,
    );
    return countPickListCatalogValuesByValue(
      contributor: contributor,
      listName: listName,
      metadata: await listCatalogAndEntryMetadata(db),
      normalizedValues: normalizedValues,
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
    MovieCatalogMetadata item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataFromTyped(item),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  CatalogKindDerivedData? _derivedDataFromTyped(MovieCatalogMetadata item) =>
      catalogDerivedDataFor(
        kind: kind,
        metadata: item,
        pickListContributors: defaultPickListDefinitionContributors,
        serialAuthorityContributors: collectarrSerialAuthorityContributors,
      );

  @override
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) =>
      CatalogItemCacheRepository(db).findAll(kind: kind);

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final items = await listTransport(db);
    return [
      for (final item in items) summarize(item.id, decode(item)),
    ];
  }
}

int? _replacementValueFromPayload(CatalogItemDto item) {
  final value = item.kindData['cover_price_cents'];
  return value is num ? value.toInt() : null;
}
