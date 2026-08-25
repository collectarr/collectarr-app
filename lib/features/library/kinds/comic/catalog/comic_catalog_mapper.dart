import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';

class ComicCatalogMapper {
  const ComicCatalogMapper._();

  static ComicCatalogItem mapDtoToComic(CatalogItemDto dto) {
    final pub = dto.publishing;

    final work = ComicWorkMetadata(
      title: dto.title,
      issueNumber: dto.itemNumber,
      synopsis: dto.synopsis,
      coverDate: dto.coverDate,
      creators: (dto.creators
              ?.map((c) => c['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          const []),
      characters: dto.characters ?? const [],
      storyArcs: dto.storyArcs ?? const [],
      genres: dto.genres ?? const [],
    );

    final publishing = ComicPublishingMetadata(
      pageCount: pub?.pageCount,
      coverPriceCents: pub?.coverPriceCents,
      currency: pub?.currency,
      publisher: dto.publisher,
      imprint: pub?.imprint,
      subtitle: pub?.subtitle,
    );

    final releases = dto.editions.map((edition) {
      return ComicRelease(
        id: edition.id,
        title: edition.title,
        publisher: edition.publisher,
        imprint: pub?.imprint,
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
