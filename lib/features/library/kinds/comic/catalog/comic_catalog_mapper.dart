import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

class ComicCatalogMapper {
  const ComicCatalogMapper._();

  static ComicCatalogItem mapDtoToComic(CatalogItemDto dto) {
    final payload = dto.toSyncPayload();
    final pub = (payload['publishing'] as Map?) ?? payload;

    final creators = (payload['creators'] as List?)
            ?.map((c) => (c is Map ? c['name'] : c)?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        const [];
    final characters =
        (payload['characters'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final storyArcs =
        (payload['story_arcs'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final genres =
        (payload['genres'] as List?)?.map((e) => e.toString()).toList() ??
            const [];
    final coverDate = payload['cover_date'] != null
        ? DateTime.tryParse(payload['cover_date'].toString())
        : null;
    final itemNumber =
        (payload['item_number'] ?? payload['itemNumber'])?.toString();

    final work = ComicWorkMetadata(
      title: dto.title,
      issueNumber: itemNumber,
      synopsis: dto.synopsis,
      coverDate: coverDate,
      creators: creators,
      characters: characters,
      storyArcs: storyArcs,
      genres: genres,
    );

    final publishing = ComicPublishingMetadata(
      pageCount:
          pub['page_count'] is num ? (pub['page_count'] as num).toInt() : null,
      coverPriceCents: pub['cover_price_cents'] is num
          ? (pub['cover_price_cents'] as num).toInt()
          : null,
      currency: pub['currency']?.toString(),
      publisher:
          (payload['publisher'] ?? pub['original_publisher'])?.toString(),
      imprint: pub['imprint']?.toString(),
      subtitle: pub['subtitle']?.toString(),
    );

    final releases = dto.editions.map((edition) {
      return ComicRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        imprint: pub['imprint']?.toString(),
        isbn: edition.isbn,
        upc: edition.upc,
        releaseDate: edition.releaseDate,
      );
    }).toList();

    return ComicCatalogItem(
      id: dto.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }

  static ComicCatalogItem mapMetadataToComic(
    ComicCatalogMetadata metadata, {
    required String id,
  }) {
    final work = ComicWorkMetadata(
      title: metadata.title,
      issueNumber: metadata.issueNumber,
      synopsis: metadata.synopsis,
      coverDate: metadata.coverDate,
      series: metadata.series,
      creators: metadata.creators
          .map((creator) => creator['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
      characters: metadata.characters,
      storyArcs: metadata.storyArcs,
      genres: metadata.genres,
    );

    final publishing = ComicPublishingMetadata(
      pageCount: metadata.pageCount,
      coverPriceCents: metadata.publishing?.coverPriceCents,
      currency: metadata.publishing?.currency,
      publisher: metadata.publisher,
      imprint: metadata.imprint,
      subtitle: metadata.publishing?.subtitle,
    );

    return ComicCatalogItem(
      id: id,
      work: work,
      publishing: publishing,
      releases: metadata.releases,
    );
  }
}
