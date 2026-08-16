import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'library_workspace_query.dart';

abstract class LibraryWorkspaceRepository {
  Stream<List<LibraryProjectionRuntime>> watchEntries(
      LibraryWorkspaceQuery query);
}

class LocalLibraryWorkspaceRepository implements LibraryWorkspaceRepository {
  LocalLibraryWorkspaceRepository(this.ref);
  final Ref ref;

  @override
  Stream<List<LibraryProjectionRuntime>> watchEntries(
      LibraryWorkspaceQuery query) {
    final controller = StreamController<List<LibraryProjectionRuntime>>();
    final db = ref.read(localDatabaseProvider);

    final bool isTesting =
        const bool.fromEnvironment('dart.vm.product') == false &&
            Platform.environment.containsKey('FLUTTER_TEST');
    final bool isLazy = db.executor is LazyDatabase ||
        db.executor.toString().contains('LazyDatabase');

    if (isTesting && isLazy) {
      final listener = ref.listen<AsyncValue<ShelfState>>(
        shelfProvider,
        (previous, next) {
          if (next is AsyncData<ShelfState>) {
            controller.add(_processEntries(next.value.entries, query));
          } else if (next is AsyncError<ShelfState>) {
            controller.addError(next.error, next.stackTrace);
          }
        },
        fireImmediately: true,
      );
      controller.onCancel = () {
        listener.close();
      };
      return controller.stream;
    }

    db.select(db.catalogCache).get().then((items) {
      final hasDbItems = items.any((item) => item.kind == query.kind.apiValue);
      if (!hasDbItems) {
        final listener = ref.listen<AsyncValue<ShelfState>>(
          shelfProvider,
          (previous, next) {
            if (next is AsyncData<ShelfState>) {
              controller.add(_processEntries(next.value.entries, query));
            } else if (next is AsyncError<ShelfState>) {
              controller.addError(next.error, next.stackTrace);
            }
          },
          fireImmediately: true,
        );
        controller.onCancel = () {
          listener.close();
        };
      } else {
        final dbSubscription = _watchFromDb(query).listen(
          (entries) {
            controller.add(entries);
          },
          onError: (Object error, StackTrace stackTrace) {
            controller.addError(error, stackTrace);
          },
        );
        controller.onCancel = () {
          dbSubscription.cancel();
        };
      }
    }).catchError((Object error, StackTrace stackTrace) {
      final listener = ref.listen<AsyncValue<ShelfState>>(
        shelfProvider,
        (previous, next) {
          if (next is AsyncData<ShelfState>) {
            controller.add(_processEntries(next.value.entries, query));
          } else if (next is AsyncError<ShelfState>) {
            controller.addError(next.error, next.stackTrace);
          }
        },
        fireImmediately: true,
      );
      controller.onCancel = () {
        listener.close();
      };
    });

    return controller.stream;
  }

  Stream<List<LibraryProjectionRuntime>> _watchFromDb(
      LibraryWorkspaceQuery query) {
    final db = ref.read(localDatabaseProvider);
    final module = libraryKindRuntimeForKind(query.kind);

    final statement = db.select(db.catalogCache).join([
      leftOuterJoin(
        db.ownedItemsCache,
        db.ownedItemsCache.itemId.equalsExp(db.catalogCache.id),
      ),
      leftOuterJoin(
        db.wishlistItemsCache,
        db.wishlistItemsCache.itemId.equalsExp(db.catalogCache.id),
      ),
      leftOuterJoin(
        db.trackingEntriesCache,
        db.trackingEntriesCache.itemId.equalsExp(db.catalogCache.id),
      ),
    ]);

    statement.where(db.catalogCache.kind.equals(query.kind.apiValue));

    if (query.searchQuery.trim().isNotEmpty) {
      final q = '%${query.searchQuery.trim().toLowerCase()}%';
      statement.where(
        db.catalogCache.title.lower().like(q) |
            db.catalogCache.publisher.lower().like(q) |
            db.catalogCache.itemNumber.lower().like(q),
      );
    }

    if (query.collectionId != null) {
      statement
          .where(db.ownedItemsCache.locationId.equals(query.collectionId!));
    }

    if (query.scopeId != null) {
      statement.where(
        db.catalogCache.id.equals(query.scopeId!) |
            db.catalogCache.seriesId.equals(query.scopeId!),
      );
    }

    return statement.watch().map((rows) {
      final shelfEntries = <ShelfEntry>[];
      for (final row in rows) {
        final catalogData = row.readTable(db.catalogCache);
        final ownedData = row.readTableOrNull(db.ownedItemsCache);
        final wishlistData = row.readTableOrNull(db.wishlistItemsCache);
        final trackingData = row.readTableOrNull(db.trackingEntriesCache);

        const String? locationPath = null;

        shelfEntries.add(
          ShelfEntry(
            itemId: catalogData.id,
            catalogItem: LibraryMetadataItem.fromCatalogItem(
              _catalogFromCache(catalogData),
            ),
            ownedItem: ownedData == null ? null : _ownedFromCache(ownedData),
            wishlistItem:
                wishlistData == null ? null : _wishlistFromCache(wishlistData),
            trackingEntry:
                trackingData == null ? null : _trackingFromCache(trackingData),
            locationPath: locationPath,
          ),
        );
      }

      final items = shelfEntries.map((se) {
        final node = LibraryTitleNodeRef(titleItemId: se.catalogItem!.id);
        final dto = module.projector.projectTitle(source: se, node: node);
        return LibraryProjectionItem(source: se, node: node, dto: dto);
      }).toList();

      var filtered = items;

      if (query.facetValues.isNotEmpty) {
        filtered = filtered.where((item) {
          for (final facetEntry in query.facetValues.entries) {
            final facetId = facetEntry.key;
            final selectedValues = facetEntry.value;
            if (selectedValues.isEmpty) {
              continue;
            }
            final values =
                module.facets?.getFacetValues?.call(item, facetId) ??
                    const <String>[];
            final hasMatch = values.any((val) => selectedValues.contains(val));
            if (!hasMatch) {
              return false;
            }
          }
          return true;
        }).toList();
      }

      if (query.presentationLevelId != null) {
        filtered = filtered.where((item) {
          if (query.presentationLevelId == 'title') {
            return item.node.scope == LibraryBrowserScope.title;
          } else if (query.presentationLevelId == 'release') {
            return item.node.scope == LibraryBrowserScope.release;
          } else if (query.presentationLevelId == 'copy') {
            return item.node.scope == LibraryBrowserScope.copy;
          }
          return true;
        }).toList();
      }

      filtered.sort((left, right) => left.dto.title
          .toLowerCase()
          .compareTo(right.dto.title.toLowerCase()));

      return filtered;
    });
  }

  List<LibraryProjectionRuntime> _processEntries(
    List<ShelfEntry> shelfEntries,
    LibraryWorkspaceQuery query,
  ) {
    final module = libraryKindRuntimeForKind(query.kind);

    final items = <LibraryProjectionRuntime>[];
    for (final source in shelfEntries) {
      final catalogItem = source.catalogItem;
      if (catalogItem != null && catalogItem.kind == query.kind.apiValue) {
        final node = LibraryTitleNodeRef(titleItemId: catalogItem.id);
        final dto = module.projector.projectTitle(source: source, node: node);
        items.add(LibraryProjectionItem(source: source, node: node, dto: dto));
      }
    }

    var filtered = items;

    final queryStr = query.searchQuery.trim().toLowerCase();
    if (queryStr.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.dto.title.toLowerCase().contains(queryStr) ||
            (item.dto.publisher?.toLowerCase().contains(queryStr) ?? false) ||
            (item.dto.itemNumber?.toLowerCase().contains(queryStr) ?? false);
      }).toList();
    }

    if (query.collectionId != null) {
      filtered = filtered.where((item) {
        return item.source.ownedItem?.locationId == query.collectionId;
      }).toList();
    }

    if (query.scopeId != null) {
      filtered = filtered.where((item) {
        return item.node.titleItemId == query.scopeId ||
            item.dto.seriesTitle == query.scopeId;
      }).toList();
    }

    if (query.facetValues.isNotEmpty) {
      filtered = filtered.where((item) {
        for (final facetEntry in query.facetValues.entries) {
          final facetId = facetEntry.key;
          final selectedValues = facetEntry.value;
          if (selectedValues.isEmpty) {
            continue;
          }
          final values =
              module.facets?.getFacetValues?.call(item, facetId) ??
                  const <String>[];
          final hasMatch = values.any((val) => selectedValues.contains(val));
          if (!hasMatch) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    if (query.presentationLevelId != null) {
      filtered = filtered.where((item) {
        if (query.presentationLevelId == 'title') {
          return item.node.scope == LibraryBrowserScope.title;
        } else if (query.presentationLevelId == 'release') {
          return item.node.scope == LibraryBrowserScope.release;
        } else if (query.presentationLevelId == 'copy') {
          return item.node.scope == LibraryBrowserScope.copy;
        }
        return true;
      }).toList();
    }

    filtered.sort((left, right) =>
        left.dto.title.toLowerCase().compareTo(right.dto.title.toLowerCase()));

    return filtered;
  }

  CatalogItem _catalogFromCache(CatalogCacheData row) {
    final series = CatalogSeriesDetails(
      seriesId: row.seriesId,
      seriesTitle: row.seriesTitle,
      volumeName: row.volumeName,
      volumeNumber: row.volumeNumber?.toString(),
      volumeStartYear: row.volumeStartYear,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      tags: _decodeStringList(row.seriesTagsJson)?.join(', '),
    );
    final video = VideoCatalogDetails(
      runtimeMinutes: row.runtimeMinutes,
      color: row.color,
      nrDiscs: row.nrDiscs,
      screenRatio: row.screenRatio,
      audioTracks: row.audioTracksJson,
      subtitles: row.subtitlesJson,
      layers: row.layers,
    );
    final tracks = _decodeTracks(row.tracksJson);
    final discs = _decodeDiscs(row.discsJson);
    final editions = _decodeEditions(row.editionsJson);
    final rawPlatforms = _decodeStringList(row.platformsJson);
    final music = MusicCatalogDetails(
      trackCount: row.trackCount,
      tracks: tracks ?? const <CatalogTrack>[],
      discs: discs ?? const <CatalogDisc>[],
      catalogNumber: row.catalogNumber,
      releaseStatus: row.releaseStatus,
    );
    final game =
        GameCatalogDetails(platforms: rawPlatforms ?? const <String>[]);
    final publishing = CatalogPublishingDetails(
      pageCount: row.pageCount,
      coverPriceCents: row.coverPriceCents,
      currency: row.catalogCurrency,
      imprint: row.imprint,
      subtitle: row.subtitle,
      seriesGroup: row.seriesGroup,
    );
    return CatalogItem(
      id: row.id,
      kind: row.kind,
      title: row.title,
      displayTitle: row.displayTitle,
      localizedTitle: row.localizedTitle,
      originalTitle: row.originalTitle,
      titleExtension: row.titleExtension,
      searchAliases: _decodeStringList(row.searchAliasesJson),
      sortKey: row.sortKey,
      itemNumber: row.itemNumber,
      synopsis: row.synopsis,
      coverImageUrl: row.coverImageUrl,
      thumbnailImageUrl: row.thumbnailImageUrl,
      coverImageData: row.coverImageData,
      editionTitle: row.editionTitle,
      physicalFormat: row.physicalFormat,
      publisher: row.publisher,
      creators: _decodeListOfMaps(row.creatorsJson),
      characters: _decodeStringList(row.charactersJson),
      characterDetails: _decodeListOfMaps(row.characterDetailsJson),
      storyArcs: _decodeStringList(row.storyArcsJson),
      series: series,
      video: video,
      music: music,
      game: game,
      publishing: publishing,
      editions: editions ?? const <CatalogEdition>[],
    );
  }

  static List<Map<String, dynamic>>? _decodeListOfMaps(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  OwnedItem _ownedFromCache(OwnedItemsCacheData row) {
    return OwnedItem(
      id: row.id,
      catalogRef: CatalogEntityRef(
        kind: 'unknown',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      quantity: row.quantity,
      locationId: row.locationId,
      condition: row.condition,
      personalNotes: row.personalNotes,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      anchorType: row.anchorType,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  WishlistItem _wishlistFromCache(WishlistItemsCacheData row) {
    return WishlistItem(
      id: row.id,
      catalogRef: CatalogEntityRef(
        kind: 'unknown',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      notes: row.notes,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      anchorType: row.anchorType,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TrackingEntry _trackingFromCache(TrackingEntriesCacheData row) {
    return TrackingEntry(
      id: row.id,
      catalogRef: CatalogEntityRef(
        kind: 'unknown',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  List<String>? _decodeStringList(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list.cast<String>();
    } catch (_) {
      return null;
    }
  }

  List<CatalogTrack>? _decodeTracks(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list
          .map((e) => CatalogTrack.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  List<CatalogDisc>? _decodeDiscs(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list
          .map((e) => CatalogDisc.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  List<CatalogEdition>? _decodeEditions(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list
          .map((e) => CatalogEdition.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}

final libraryWorkspaceRepositoryProvider =
    Provider.autoDispose<LibraryWorkspaceRepository>((ref) {
  return LocalLibraryWorkspaceRepository(ref);
});
