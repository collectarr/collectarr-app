import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_derived_data.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_kind_transport_codec.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_definition_contributor.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_serial_authority_contributors.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_media.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';

final class BookCatalogTransportCodec
    implements
        CatalogKindTransportCodec<BookMedia>,
        CatalogSharedCachePrimaryStore {
  const BookCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  BookMedia decode(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is BookMedia) return metadata;
    return BookMedia.fromJson(catalogTransportPayloadFor(item));
  }

  @override
  Future<void> upsert(LocalDatabase db, BookMedia item) {
    return CatalogItemCacheRepository(db).upsert(_projection(item));
  }

  @override
  CatalogDisplaySummary summarize(BookMedia item) => CatalogDisplaySummary.root(
        kind: kind,
        id: item.id.value,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.coverImageUrl,
      );

  @override
  BookWorkspaceCatalogData workspaceData(CatalogItemDto item) =>
      BookWorkspaceCatalogData.fromTransport(item);

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
      metadata: [
        for (final item in await listTransport(db)) _catalogMetadata(item),
      ],
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
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataForMetadata(_catalogMetadata(item)),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  @override
  Future<void> captureDerivedDataTyped(
    PickListRepository pickLists,
    SerialAuthorityRepository serialAuthority,
    BookMedia item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataForMetadata(
        BookCatalogMetadata.fromJson(item.toJson()),
      ),
      pickLists: pickLists,
      serialAuthority: serialAuthority,
    );
  }

  CatalogKindDerivedData? _derivedDataForMetadata(BookCatalogMetadata item) =>
      catalogDerivedDataFor(
        kind: kind,
        metadata: item,
        pickListContributors: defaultPickListDefinitionContributors,
        serialAuthorityContributors: collectarrSerialAuthorityContributors,
      );

  @override
  Future<void> upsertTransport(LocalDatabase db, CatalogItemDto item) {
    return CatalogItemCacheRepository(db).upsert(item);
  }

  @override
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) =>
      CatalogItemCacheRepository(db).findAll(kind: kind);

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final items = await listTransport(db);
    return [
      for (final item in items)
        CatalogDisplaySummary.root(
          kind: kind,
          id: item.id,
          primaryLabel: item.resolvedDisplayTitle,
          imageUrl: item.displayCoverUrl,
        ),
    ];
  }

  BookCatalogMetadata _catalogMetadata(CatalogItemDto item) {
    final metadata = item.kindMetadata;
    if (metadata is BookCatalogMetadata) return metadata;
    return BookCatalogMetadata.fromJson(catalogTransportPayloadFor(item));
  }
}

int? _replacementValueFromPayload(CatalogItemDto item) {
  final direct = item.payload['cover_price_cents'];
  if (direct is num) return direct.toInt();
  final publishing = item.payload['publishing'];
  final nested = publishing is Map ? publishing['cover_price_cents'] : null;
  return nested is num ? nested.toInt() : null;
}

CatalogItemDto _projection(BookMedia item) {
  final payload = Map<String, dynamic>.from(item.rawPayload);
  payload['id'] ??= item.id.value;
  payload['kind'] ??= 'book';
  payload['title'] ??= item.title;
  final projection = CatalogItemDto.fromJson(payload);
  return projection.withKindMetadata(BookMedia.fromJson(projection.payload));
}
