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
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/book/catalog/book_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/book_workspace_catalog_data.dart';

final class BookCatalogTransportCodec
    implements
        CatalogKindTransportCodec<BookCatalogItem>,
        CatalogSharedCachePrimaryStore {
  const BookCatalogTransportCodec();

  @override
  CatalogMediaKind get kind => CatalogMediaKind.book;

  @override
  BookCatalogItem decode(CatalogItemDto item) =>
      BookCatalogMapper.mapMetadataItemToBook(item);

  @override
  Future<void> upsert(LocalDatabase db, BookCatalogItem item) {
    return CatalogItemCacheRepository(db).upsert(_projection(item));
  }

  @override
  CatalogDisplaySummary summarize(BookCatalogItem item) =>
      CatalogDisplaySummary.root(
        kind: kind,
        id: item.id,
        primaryLabel: item.title,
        imageUrl: item.thumbnailImageUrl ?? item.displayCoverUrl,
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
    BookCatalogItem item,
  ) async {
    await captureCatalogKindDerivedData(
      kind: kind,
      derived: _derivedDataForMetadata(item.catalogMetadata),
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
    return [for (final item in items) summarize(decode(item))];
  }

  BookCatalogMetadata _catalogMetadata(CatalogItemDto item) {
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

CatalogItemDto _projection(BookCatalogItem item) {
  final payload = Map<String, dynamic>.from(item.catalogMetadata.toJson())
    ..remove('editions');
  if (item.printings.isNotEmpty) {
    payload['printings'] = [
      for (final printing in item.printings)
        {
          'id': printing.id,
          if (printing.printingNumber != null)
            'printing_number': printing.printingNumber,
          if (printing.title != null) 'title': printing.title,
          if (printing.releaseDate != null)
            'release_date': printing.releaseDate!.toIso8601String(),
          if (printing.publisher != null) 'publisher': printing.publisher,
          if (printing.language != null) 'language': printing.language,
          if (printing.isbn != null) 'isbn': printing.isbn,
        },
    ];
  }
  return CatalogItemDto.raw(
    id: item.id,
    mediaKind: CatalogMediaKind.book,
    kindData: {
      ...payload,
      'title': item.title,
      if (item.coverImageUrl ?? item.displayCoverUrl case final cover?)
        'cover_image_url': cover,
      if (item.thumbnailImageUrl case final thumbnail?)
        'thumbnail_image_url': thumbnail,
      if (item.releaseDate case final date?)
        'release_date': date.toIso8601String(),
    },
  );
}
