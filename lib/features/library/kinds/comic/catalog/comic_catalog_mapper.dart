import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

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

  static ComicCatalogItem mapWorkspaceEntryToComic(LibraryWorkspaceEntry entry) {
    final pub = entry.publishing;

    final work = ComicWorkMetadata(
      title: entry.title,
      issueNumber: entry.itemNumber,
      synopsis: entry.synopsis,
      coverDate: entry.coverDate,
      creators: (entry.creators?.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList() ?? const []),
      characters: entry.characters ?? const [],
      storyArcs: entry.storyArcs ?? const [],
      genres: entry.genres ?? const [],
    );

    final publishing = ComicPublishingMetadata(
      pageCount: pub?.pageCount,
      coverPriceCents: pub?.coverPriceCents,
      currency: entry.currency,
      publisher: entry.publisher,
      imprint: pub?.imprint,
    );

    final releases = entry.editions.map((edition) {
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
      id: entry.id,
      work: work,
      publishing: publishing,
      releases: releases,
    );
  }
}
