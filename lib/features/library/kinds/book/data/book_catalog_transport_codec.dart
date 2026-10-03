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
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';

final class BookCatalogTransportCodec
    implements CatalogKindTransportCodec<BookCatalogMetadata> {
  const BookCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  BookCatalogMetadata decode(CatalogItemDto item) =>
      BookCatalogMetadata.fromJson(catalogTransportPayloadFor(item));

  @override
  Future<void> upsert(LocalDatabase db, BookCatalogMetadata item) {
    final payload = Map<String, dynamic>.from(item.toJson());
    final id = payload.remove('id')?.toString().trim() ?? '';
    if (id.isEmpty) {
      throw StateError('Cannot cache a Book Catalog Item without an id');
    }
    return CatalogItemCacheRepository(db).upsert(
      CatalogItemDto.raw(
        id: id,
        mediaKind: kind,
        kindData: payload,
      ),
    );
  }

  @override
  CatalogDisplaySummary summarize(BookCatalogMetadata item) =>
      CatalogDisplaySummary.root(
        kind: kind,
        id: item.transportId ?? '',
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
    BookCatalogMetadata item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataForMetadata(item),
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
  Future<List<CatalogItemDto>> listTransport(LocalDatabase db) =>
      CatalogItemCacheRepository(db).findAll(kind: kind);

  @override
  Future<List<CatalogDisplaySummary>> listSummaries(LocalDatabase db) async {
    final items = await listTransport(db);
    return [for (final item in items) summarize(decode(item))];
  }

  BookCatalogMetadata _catalogMetadata(CatalogItemDto item) {
    return decode(item);
  }
}

int? _replacementValueFromPayload(CatalogItemDto item) {
  final value = item.kindData['cover_price_cents'];
  return value is num ? value.toInt() : null;
}
