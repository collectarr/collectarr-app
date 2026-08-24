import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:flutter/foundation.dart';

@immutable
final class MusicCatalog {
  const MusicCatalog({
    required this.identity,
    required this.title,
    this.artist,
    this.originalReleaseDate,
    this.recordingDate,
    this.studio,
    this.isLive = false,
    this.genres = const [],
    this.credits = const [],
    this.releases = const [],
    this.synopsis,
    this.coverImageUrl,
    this.thumbnailImageUrl,
  });

  final LibraryItemIdentity identity;
  final String title;
  final String? artist;
  final DateTime? originalReleaseDate;
  final DateTime? recordingDate;
  final String? studio;
  final bool isLive;
  final List<String> genres;
  final List<MusicCredit> credits;
  final List<MusicReleaseMetadata> releases;
  final String? synopsis;
  final String? coverImageUrl;
  final String? thumbnailImageUrl;

  String get id => identity.id;
  CatalogMediaKind get mediaKind => CatalogMediaKind.music;
  String? get displayCoverUrl => thumbnailImageUrl ?? coverImageUrl;

  factory MusicCatalog.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['ref_id'] ?? '').toString();
    final identity = LibraryItemIdentity(
      id: id,
      mediaKind: CatalogMediaKind.music,
    );

    final rawReleases = (json['releases'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(MusicReleaseMetadata.fromJson)
            .toList(growable: false) ??
        const <MusicReleaseMetadata>[];

    final rawCredits = (json['credits'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(MusicCredit.fromJson)
            .toList(growable: false) ??
        const <MusicCredit>[];

    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return MusicCatalog(
      identity: identity,
      title: (json['title'] as String?) ?? '',
      artist: json['artist'] as String?,
      originalReleaseDate: parseDate(json['original_release_date']),
      recordingDate: parseDate(json['recording_date']),
      studio: json['studio'] as String?,
      isLive: json['is_live'] as bool? ?? false,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      credits: rawCredits,
      releases: rawReleases,
      synopsis: (json['synopsis'] ?? json['description']) as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      thumbnailImageUrl: json['thumbnail_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'music',
        'title': title,
        if (artist != null) 'artist': artist,
        if (originalReleaseDate != null)
          'original_release_date': originalReleaseDate!.toIso8601String(),
        if (recordingDate != null)
          'recording_date': recordingDate!.toIso8601String(),
        if (studio != null) 'studio': studio,
        if (isLive) 'is_live': true,
        if (genres.isNotEmpty) 'genres': genres,
        if (credits.isNotEmpty)
          'credits': credits.map((e) => e.toJson()).toList(),
        if (releases.isNotEmpty)
          'releases': releases.map((e) => e.toJson()).toList(),
        if (synopsis != null) 'synopsis': synopsis,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
      };

  CatalogItemEnvelopeDto toEnvelope() {
    return CatalogItemEnvelopeDto(
      ref: CatalogEntityRef(
        id: id,
        kind: 'music',
        entityType: CatalogEntityType.work,
      ),
      kind: CatalogMediaKind.music,
      common: CatalogCommonDto(
        title: title,
        displayTitle: title,
        synopsis: synopsis,
        coverImageUrl: coverImageUrl,
        thumbnailImageUrl: thumbnailImageUrl,
        releaseDate: originalReleaseDate,
        releaseYear: originalReleaseDate?.year,
      ),
      kindPayload: toJson(),
    );
  }
}

@immutable
final class MusicEntry {
  const MusicEntry({
    required this.catalog,
    this.ownedDetails,
    this.trackingEntry,
    this.wishlistItem,
    this.customFields = const {},
  });

  final MusicCatalog catalog;
  final MusicOwnedDetails? ownedDetails;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final Map<String, dynamic> customFields;

  String get id => catalog.id;
  String get title => catalog.title;
  bool get isOwned => ownedDetails != null;
  bool get isWishlisted => wishlistItem != null;

  factory MusicEntry.fromShelf(ShelfEntry shelf) {
    final catalog = shelf.catalogItem != null
        ? MusicCatalog.fromJson(shelf.catalogItem!.toSyncPayload())
        : MusicCatalog(
            identity: LibraryItemIdentity(
              id: shelf.itemId,
              mediaKind: CatalogMediaKind.music,
            ),
            title: shelf.catalogItem?.title ?? shelf.itemId,
          );

    return MusicEntry(
      catalog: catalog,
      ownedDetails: shelf.ownedItem?.musicDetails,
      trackingEntry: shelf.trackingEntry,
      wishlistItem: shelf.wishlistItem,
      customFields: const {},
    );
  }
}
