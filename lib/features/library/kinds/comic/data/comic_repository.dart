import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';

final class ComicRepository
    implements ReadRepository<ComicMediaId, ComicMedia> {
  ComicRepository(this._db);

  final LocalDatabase _db;

  CatalogItemCacheRepository get _catalog => CatalogItemCacheRepository(_db);

  @override
  Future<ComicMedia?> findById(ComicMediaId id) => getMedia(id);

  Future<ComicMedia?> getMedia(ComicMediaId id) async {
    final item = await _catalog.find(
      CatalogItemRef(kind: CatalogMediaKind.comic, id: id.value),
    );
    return item == null
        ? null
        : ComicMedia.fromJson(catalogTransportPayloadFor(item));
  }

  Future<List<ComicMedia>> search([String query = '']) async {
    final normalizedQuery = query.trim().toLowerCase();
    final media = [
      for (final item in await _catalog.findAll(kind: CatalogMediaKind.comic))
        ComicMedia.fromJson(catalogTransportPayloadFor(item)),
    ];
    final results = normalizedQuery.isEmpty
        ? media
        : media.where((item) {
            return item.title.toLowerCase().contains(normalizedQuery) ||
                (item.sortTitle?.toLowerCase().contains(normalizedQuery) ??
                    false) ||
                (item.seriesTitle?.toLowerCase().contains(normalizedQuery) ??
                    false) ||
                (item.issueNumber?.toLowerCase().contains(normalizedQuery) ??
                    false);
          }).toList(growable: false);
    results.sort((left, right) {
      final sortTitle = (left.sortTitle ?? '').compareTo(right.sortTitle ?? '');
      if (sortTitle != 0) return sortTitle;
      final title = left.title.compareTo(right.title);
      if (title != 0) return title;
      return (left.id?.value ?? '').compareTo(right.id?.value ?? '');
    });
    return results;
  }

  Future<List<ComicRelease>> releasesFor(ComicMediaId mediaId) async {
    final media = await getMedia(mediaId);
    final releases = media?.releases.toList() ?? <ComicRelease>[];
    releases.sort((left, right) {
      final date = (left.releaseDate ?? DateTime(0))
          .compareTo(right.releaseDate ?? DateTime(0));
      if (date != 0) return date;
      final title = left.title.compareTo(right.title);
      return title != 0 ? title : left.id.compareTo(right.id);
    });
    return releases;
  }

  Future<ComicRelease?> getRelease(
    ComicMediaId mediaId,
    ComicReleaseId releaseId,
  ) async {
    for (final release in await releasesFor(mediaId)) {
      if (release.typedId == releaseId) return release;
    }
    return null;
  }

  Future<void> updateMedia(ComicMedia media) async {
    final id = media.id?.value.trim();
    if (id == null || id.isEmpty) {
      throw StateError('Cannot update Comic Catalog Item without an id');
    }
    final item = CatalogItemDto.fromJson({
      ...media.toJson(),
      'id': id,
      'kind': CatalogMediaKind.comic.apiValue,
    }).withKindMetadata(media);
    await _catalog.upsert(item);
  }

  Future<void> updateRelease(
    ComicMediaId mediaId,
    ComicRelease release,
  ) async {
    final media = await getMedia(mediaId);
    if (media == null) {
      throw StateError('Cannot update contained Comic details without an item');
    }
    final releases = media.releases.toList();
    final index = releases.indexWhere((entry) => entry.id == release.id);
    if (index < 0) {
      releases.add(release);
    } else {
      releases[index] = release;
    }
    await updateMedia(media.copyWith(releases: releases));
  }
}
