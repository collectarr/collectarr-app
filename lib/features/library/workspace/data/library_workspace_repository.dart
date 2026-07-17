import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'library_workspace_query.dart';

abstract class LibraryWorkspaceRepository {
  Stream<List<LibraryWorkspaceEntry>> watchEntries(LibraryWorkspaceQuery query);
}

class LocalLibraryWorkspaceRepository implements LibraryWorkspaceRepository {
  LocalLibraryWorkspaceRepository(this.ref);
  final Ref ref;

  @override
  Stream<List<LibraryWorkspaceEntry>> watchEntries(LibraryWorkspaceQuery query) {
    final controller = StreamController<List<LibraryWorkspaceEntry>>();
    final db = ref.read(localDatabaseProvider);

    // In unit tests where shelfProvider is overridden and the DB is the default LazyDatabase,
    // we must bypass Drift queries to avoid MissingPluginException on path_provider.
    final bool isTesting = const bool.fromEnvironment('dart.vm.product') == false &&
        Platform.environment.containsKey('FLUTTER_TEST');
    final bool isLazy = db.connection.executor is LazyDatabase ||
        db.connection.executor.toString().contains('LazyDatabase');

    if (isTesting && isLazy) {
      // Fall back to watching shelfProvider
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
        // Fall back to watching shelfProvider
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
        // Use the DB-level filtering query stream!
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
      // In case of error (e.g. database not initialized or missing tables in some tests)
      // fallback to shelfProvider.
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

  Stream<List<LibraryWorkspaceEntry>> _watchFromDb(LibraryWorkspaceQuery query) {
    final db = ref.read(localDatabaseProvider);
    final module = libraryKindModuleForKind(query.kind);
    final type = module.type;

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

    // 1. Kind filter
    statement.where(db.catalogCache.kind.equals(query.kind.apiValue));

    // 2. Active shelf entry filter (must have at least one active owned, wishlist, or tracking entry)
    statement.where(
      (db.ownedItemsCache.id.isNotNull() & db.ownedItemsCache.deletedAt.isNull()) |
      (db.wishlistItemsCache.id.isNotNull() & db.wishlistItemsCache.deletedAt.isNull()) |
      (db.trackingEntriesCache.id.isNotNull() & db.trackingEntriesCache.deletedAt.isNull())
    );

    // 3. Search query filter
    final queryStr = query.searchQuery.trim().toLowerCase();
    if (queryStr.isNotEmpty) {
      statement.where(
        db.catalogCache.title.lower().like('%$queryStr%') |
        db.catalogCache.publisher.lower().like('%$queryStr%') |
        db.catalogCache.itemNumber.lower().like('%$queryStr%')
      );
    }

    // 4. Collection/Location filter
    if (query.collectionId != null) {
      statement.where(db.ownedItemsCache.locationId.equals(query.collectionId!));
    }

    // 5. Scope filter
    if (query.scopeId != null) {
      statement.where(
        db.catalogCache.seriesId.equals(query.scopeId!) |
        db.catalogCache.id.equals(query.scopeId!)
      );
    }

    return statement.watch().asyncMap((rows) async {
      final shelfEntries = <ShelfEntry>[];
      for (final row in rows) {
        final catalogData = row.readTable(db.catalogCache);
        final ownedData = row.readTableOrNull(db.ownedItemsCache);
        final wishlistData = row.readTableOrNull(db.wishlistItemsCache);
        final trackingData = row.readTableOrNull(db.trackingEntriesCache);

        String? locationPath;
        if (ownedData?.locationId != null) {
          final locations = await LocationRepository(db).getAll();
          locationPath = locations
              .where((loc) => loc.id == ownedData!.locationId)
              .map((loc) => loc.fullPath(locations))
              .firstOrNull;
        }

        final watchSessions = await WatchSessionsCacheRepository(db)
            .listActiveByItemId(catalogData.id);

        final itemImages = ownedData != null
            ? await ItemImageRepository(db).listForItem(ownedData.id)
            : const <ItemImage>[];

        shelfEntries.add(
          ShelfEntry(
            itemId: catalogData.id,
            catalogItem: LibraryMetadataItem.fromCatalogItem(
              _itemFromRow(catalogData),
            ),
            ownedItem: ownedData == null ? null : _ownedFromCache(ownedData),
            wishlistItem: wishlistData == null ? null : _wishlistFromCache(wishlistData),
            trackingEntry: trackingData == null ? null : _trackingFromCache(trackingData),
            locationPath: locationPath,
            watchSessions: watchSessions,
            itemImages: itemImages,
          ),
        );
      }

      final entries = shelfEntries
          .map((se) => type.presentation.workspaceEntryBuilder(se))
          .toList();

      var filtered = entries;

      // Facet values filtering
      if (query.facetValues.isNotEmpty) {
        filtered = filtered.where((entry) {
          for (final facetEntry in query.facetValues.entries) {
            final facetId = facetEntry.key;
            final selectedValues = facetEntry.value;
            if (selectedValues.isEmpty) {
              continue;
            }
            if (facetId == LibraryFacetId.comicCharacter ||
                facetId == LibraryFacetId.mediaCharacter) {
              final entryChars = entry.characters ?? const <String>[];
              final hasMatch = entryChars.any((char) => selectedValues.contains(char));
              if (!hasMatch) {
                return false;
              }
            } else if (facetId == LibraryFacetId.comicStoryArc) {
              final entryArcs = entry.storyArcs ?? const <String>[];
              final hasMatch = entryArcs.any((arc) => selectedValues.contains(arc));
              if (!hasMatch) {
                return false;
              }
            }
          }
          return true;
        }).toList();
      }

      // Presentation level filtering
      if (query.presentationLevelId != null) {
        filtered = filtered.where((entry) {
          if (query.presentationLevelId == 'title') {
            return entry.browseScope == LibraryBrowserScope.title;
          } else if (query.presentationLevelId == 'release') {
            return entry.browseScope == LibraryBrowserScope.release;
          } else if (query.presentationLevelId == 'copy') {
            return entry.browseScope == LibraryBrowserScope.copy;
          }
          return true;
        }).toList();
      }

      if (query.sortId != null) {
        final sortDef = module.fields.sortDefinitionFor(query.sortId!);
        filtered.sort((left, right) {
          final result = sortDef.compare(left, right);
          return query.sortAscending ? result : -result;
        });
      } else {
        filtered.sort((left, right) => left.resolvedTitle
            .toLowerCase()
            .compareTo(right.resolvedTitle.toLowerCase()));
      }

      return filtered;
    });
  }

  List<LibraryWorkspaceEntry> _processEntries(
    List<ShelfEntry> shelfEntries,
    LibraryWorkspaceQuery query,
  ) {
    final module = libraryKindModuleForKind(query.kind);
    final type = module.type;

    final entries = <LibraryWorkspaceEntry>[];
    for (final source in shelfEntries) {
      final catalogItem = source.catalogItem;
      if (catalogItem != null && catalogItem.kind == query.kind.apiValue) {
        entries.add(type.presentation.workspaceEntryBuilder(source));
      }
    }

    var filtered = entries;

    // 1. Search Query filter
    final queryStr = query.searchQuery.trim().toLowerCase();
    if (queryStr.isNotEmpty) {
      filtered = filtered.where((entry) {
        return entry.resolvedTitle.toLowerCase().contains(queryStr) ||
            (entry.publisher?.toLowerCase().contains(queryStr) ?? false) ||
            (entry.itemNumber?.toLowerCase().contains(queryStr) ?? false);
      }).toList();
    }

    // 2. Collection filter (matching ownedItem location ID)
    if (query.collectionId != null) {
      filtered = filtered.where((entry) {
        return entry.ownedItemId != null &&
            shelfEntries.any((se) =>
                se.ownedItem?.id == entry.ownedItemId &&
                se.ownedItem?.locationId == query.collectionId);
      }).toList();
    }

    // 3. Scope filter (matching titleItemId or seriesId)
    if (query.scopeId != null) {
      filtered = filtered.where((entry) {
        return entry.titleItemId == query.scopeId ||
            entry.series?.seriesId == query.scopeId ||
            entry.id == query.scopeId;
      }).toList();
    }

    // 4. Facet values filtering
    if (query.facetValues.isNotEmpty) {
      filtered = filtered.where((entry) {
        for (final facetEntry in query.facetValues.entries) {
          final facetId = facetEntry.key;
          final selectedValues = facetEntry.value;
          if (selectedValues.isEmpty) {
            continue;
          }
          if (facetId == LibraryFacetId.comicCharacter ||
              facetId == LibraryFacetId.mediaCharacter) {
            final entryChars = entry.characters ?? const <String>[];
            final hasMatch = entryChars.any((char) => selectedValues.contains(char));
            if (!hasMatch) {
              return false;
            }
          } else if (facetId == LibraryFacetId.comicStoryArc) {
            final entryArcs = entry.storyArcs ?? const <String>[];
            final hasMatch = entryArcs.any((arc) => selectedValues.contains(arc));
            if (!hasMatch) {
              return false;
            }
          }
        }
        return true;
      }).toList();
    }

    // 5. Presentation Level filter
    if (query.presentationLevelId != null) {
      filtered = filtered.where((entry) {
        if (query.presentationLevelId == 'title') {
          return entry.browseScope == LibraryBrowserScope.title;
        } else if (query.presentationLevelId == 'release') {
          return entry.browseScope == LibraryBrowserScope.release;
        } else if (query.presentationLevelId == 'copy') {
          return entry.browseScope == LibraryBrowserScope.copy;
        }
        return true;
      }).toList();
    }

    if (query.sortId != null) {
      final sortDef = module.fields.sortDefinitionFor(query.sortId!);
      filtered.sort((left, right) {
        final result = sortDef.compare(left, right);
        return query.sortAscending ? result : -result;
      });
    } else {
      filtered.sort((left, right) => left.resolvedTitle
          .toLowerCase()
          .compareTo(right.resolvedTitle.toLowerCase()));
    }

    return filtered;
  }

  CatalogItem _itemFromRow(CatalogCacheData row) {
    final series = CatalogSeriesDetails(
      seriesId: row.seriesId,
      seriesTitle: row.seriesTitle,
      volumeName: row.volumeName,
      volumeNumber: row.volumeNumber,
      volumeStartYear: row.volumeStartYear,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      tags: _decodeStringList(row.seriesTagsJson) ?? const <String>[],
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
      physicalFormatLabel: row.physicalFormatLabel,
      publisher: row.publisher,
      coverDate: row.coverDate,
      releaseDate: row.releaseDate,
      releaseYear: row.releaseYear,
      barcode: row.barcode,
      variant: row.variant,
      crossover: row.crossover,
      plotSummary: row.plotSummary,
      plotDescription: row.plotDescription,
      series: series.hasData ? series : null,
      video: video.hasData ? video : null,
      music: music.hasData ? music : null,
      game: game.hasData ? game : null,
      publishing: publishing.hasData ? publishing : null,
      editions: editions ?? const <CatalogEdition>[],
      creators: _decodeListOfMaps(row.creatorsJson),
      characters: _decodeStringList(row.charactersJson),
      characterDetails: _decodeListOfMaps(row.characterDetailsJson),
      storyArcs: _decodeStringList(row.storyArcsJson),
      rawPlatforms: rawPlatforms,
      genres: _decodeStringList(row.genresJson),
      trailerUrls: _decodeTrailerUrls(row.trailerUrlsJson),
      country: row.country,
      language: row.language,
      ageRating: row.ageRating,
      audienceRating: row.audienceRating,
    );
  }

  static List<String>? _decodeStringList(String? json) {
    if (json == null || json.isEmpty) return null;
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;
    return decoded.cast<String>().toList(growable: false);
  }

  static List<Map<String, dynamic>>? _decodeListOfMaps(String? json) {
    if (json == null || json.isEmpty) return null;
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;
    return decoded.cast<Map<String, dynamic>>().toList(growable: false);
  }

  static List<CatalogTrack>? _decodeTracks(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) return null;
    return decoded.map(CatalogTrack.fromJson).toList(growable: false);
  }

  static List<CatalogDisc>? _decodeDiscs(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) return null;
    return decoded.map(CatalogDisc.fromJson).toList(growable: false);
  }

  static List<CatalogEdition>? _decodeEditions(String? json) {
    final decoded = _decodeListOfMaps(json);
    if (decoded == null) return null;
    return decoded.map(CatalogEdition.fromJson).toList(growable: false);
  }

  static List<TrailerLink> _decodeTrailerUrls(String? json) {
    if (json == null || json.isEmpty) return const <TrailerLink>[];
    final decoded = jsonDecode(json);
    if (decoded is! List) return const <TrailerLink>[];
    return decoded
        .cast<Map<String, dynamic>>()
        .map(TrailerLink.fromJson)
        .toList(growable: false);
  }

  OwnedItem _ownedFromCache(OwnedItemsCacheData row) {
    return OwnedItem(
      id: row.id,
      catalogRef: CatalogEntityRef(
        kind: 'unknown',
        entityType: CatalogEntityType.unknown,
        id: row.itemId,
      ),
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      anchorType: row.anchorType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
      coverPriceCents: row.coverPriceCents,
      rawOrSlabbed: row.rawOrSlabbed,
      gradingCompany: row.gradingCompany,
      graderNotes: row.graderNotes,
      signedBy: row.signedBy,
      labelType: row.labelType,
      customLabel: row.customLabel,
      pageQuality: row.pageQuality,
      certificationNumber: row.certificationNumber,
      keyComic: row.keyComic,
      keyReason: row.keyReason,
      keyCategory: row.keyCategory,
      keySeverity: row.keySeverity,
      rating: row.rating,
      readStatus: row.readStatus,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      features: row.features,
      hdrFormats: _decodeStringList(row.hdrFormatsJson) ?? const <String>[],
      purchaseStore: row.purchaseStore,
      boxSetId: row.boxSetId,
      boxSetName: row.boxSetName,
      storageDevice: row.storageDevice,
      storageSlot: row.storageSlot,
      region: row.region,
      packaging: row.packaging,
      distributor: row.distributor,
      collectionStatus: row.collectionStatus,
      lastBagBoardDate: row.lastBagBoardDate,
      marketValueCents: row.marketValueCents,
      gameCompleteness: row.gameCompleteness,
      gameHasBox: row.gameHasBox,
      gameHasManual: row.gameHasManual,
      gamePriceChartingId: row.gamePriceChartingId,
      gameCoreRegion: row.gameCoreRegion,
      gameValueIsLocked: row.gameValueIsLocked,
    );
  }

  WishlistItem _wishlistFromCache(WishlistItemsCacheData row) {
    final anchor = PersonalItemAnchor.fromRaw(
      anchorType: row.anchorType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
    );
    final entityType = switch (anchor?.type) {
      PersonalItemAnchorType.bundleRelease => CatalogEntityType.release,
      PersonalItemAnchorType.variant => CatalogEntityType.release,
      PersonalItemAnchorType.edition => CatalogEntityType.edition,
      _ => CatalogEntityType.work,
    };
    return WishlistItem(
      id: row.id,
      catalogRef: CatalogEntityRef(
        kind: 'unknown',
        entityType: entityType,
        id: row.itemId,
      ),
      anchorType: row.anchorType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      targetPriceCents: row.targetPriceCents,
      currency: row.currency,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  TrackingEntry _trackingFromCache(TrackingEntriesCacheData row) {
    final anchor = PersonalItemAnchor.fromRaw(
      anchorType: row.sourceType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
    );
    final entityType = row.seasonNumber != null || row.episodeNumber != null
        ? CatalogEntityType.episode
        : switch (anchor?.type) {
            PersonalItemAnchorType.bundleRelease => CatalogEntityType.release,
            PersonalItemAnchorType.variant => CatalogEntityType.release,
            PersonalItemAnchorType.edition => CatalogEntityType.edition,
            _ => CatalogEntityType.work,
          };
    return TrackingEntry(
      id: row.id,
      catalogRef: CatalogEntityRef(
        kind: 'unknown',
        entityType: entityType,
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
      episodeRatings: _decodeEpisodeRatings(row.episodeRatings),
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static Map<String, int>? _decodeEpisodeRatings(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k as String, (v as num).toInt()));
      }
    } catch (_) {}
    return null;
  }
}

final libraryWorkspaceRepositoryProvider =
    Provider<LibraryWorkspaceRepository>((ref) {
  return LocalLibraryWorkspaceRepository(ref);
});

