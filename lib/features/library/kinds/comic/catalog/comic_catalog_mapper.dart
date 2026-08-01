import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';


class ComicCatalogMapper {
  const ComicCatalogMapper._();

  static ComicCatalogItem mapDtoToComic(CatalogItemDto dto) {
    final pub = dto.publishing;

    final work = ComicWorkMetadata(
      title: dto.title,
      issueNumber: dto.itemNumber,
      synopsis: dto.synopsis,
      coverDate: dto.coverDate,
      creators: (dto.creators?.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList() ?? const []),
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



  static ComicCatalogItem mapMetadataItemToComic(LibraryMetadataItem item) {
    final pub = item.publishing;

    final work = ComicWorkMetadata(
      title: item.title,
      issueNumber: item.itemNumber,
      synopsis: item.synopsis,
      coverDate: item.coverDate,
      series: item.series,
      creators: (item.creators?.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList() ?? const []),
      characters: item.characters ?? const [],
      storyArcs: item.storyArcs ?? const [],
      genres: item.genres ?? const [],
    );

    final publishing = ComicPublishingMetadata(
      pageCount: pub?.pageCount,
      coverPriceCents: pub?.coverPriceCents,
      currency: pub?.currency,
      publisher: item.publisher,
      imprint: pub?.imprint,
      subtitle: pub?.subtitle,
    );

    final releases = item.editions.map((edition) {
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
      id: item.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }
}
