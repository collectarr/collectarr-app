import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_disc_storage.dart';
import 'package:drift/drift.dart';

final class MusicLocalMapper {
  const MusicLocalMapper._();

  static MusicReleaseGroupRowsCompanion toReleaseGroupRow(
      MusicReleaseGroup group) {
    _require(group.id.value, 'MusicReleaseGroup');
    return MusicReleaseGroupRowsCompanion.insert(
      id: group.id.value,
      title: group.title,
      sortTitle: Value(group.sortTitle),
      artist: Value(group.artist),
      originalTitle: Value(group.originalTitle),
      synopsis: Value(group.synopsis),
      originalReleaseDate: Value(group.originalReleaseDate),
      recordingDate: Value(group.recordingDate),
      studio: Value(group.studio),
      isLive: Value(group.isLive),
      genresJson: Value(jsonEncode(group.genres)),
      coverImageUrl: Value(group.coverImageUrl),
      coverImageKey: Value(group.coverImageKey),
      externalLinksJson: Value(
        jsonEncode(group.externalLinks.map((link) => link.toJson()).toList()),
      ),
      metadataJson: Value(jsonEncode(group.metadataJson)),
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
  }

  static MusicReleaseGroup fromReleaseGroupRow(
    MusicReleaseGroupRow row, {
    List<MusicRelease> releases = const <MusicRelease>[],
  }) {
    return MusicReleaseGroup(
      id: MusicReleaseGroupId(row.id),
      title: row.title,
      sortTitle: row.sortTitle,
      artist: row.artist,
      originalTitle: row.originalTitle,
      synopsis: row.synopsis,
      originalReleaseDate: row.originalReleaseDate,
      recordingDate: row.recordingDate,
      studio: row.studio,
      isLive: row.isLive,
      genres: _decodeStrings(row.genresJson),
      coverImageUrl: row.coverImageUrl,
      coverImageKey: row.coverImageKey,
      externalLinks: [
        for (final value in _decodeMaps(row.externalLinksJson))
          MusicExternalLink.fromJson(value),
      ],
      releases: releases,
      metadataJson: _decodeMap(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MusicReleaseRowsCompanion toReleaseRow(MusicRelease release) {
    _require(release.id.value, 'MusicRelease');
    _require(release.releaseGroupId.value, 'MusicRelease.releaseGroupId');
    final metadata = {
      ...release.metadataJson,
      if (release.boxSetMembership != null)
        'box_set': release.boxSetMembership!.toJson(),
    };
    return MusicReleaseRowsCompanion.insert(
      id: release.id.value,
      releaseGroupId: release.releaseGroupId.value,
      title: release.title,
      publisher: Value(release.publisher),
      catalogNumber: Value(release.catalogNumber),
      barcode: Value(release.barcode),
      releaseDate: Value(release.releaseDate),
      releaseStatus: Value(release.releaseStatus),
      releaseType: Value(release.releaseType),
      sortTitle: Value(release.sortTitle),
      subtitle: Value(release.subtitle),
      countryCode: Value(release.countryCode),
      language: Value(release.language),
      coverImageUrl: Value(release.coverImageUrl),
      coverImageKey: Value(release.coverImageKey),
      upc: Value(release.upc),
      packaging: Value(release.packaging),
      metadataJson: Value(jsonEncode(metadata)),
      createdAt: release.createdAt,
      updatedAt: release.updatedAt,
    );
  }

  static MusicRelease fromReleaseRow(
    MusicReleaseRow row, {
    List<MusicMedium> mediums = const <MusicMedium>[],
    List<MusicReleaseContribution> contributions =
        const <MusicReleaseContribution>[],
    List<MusicReleaseIdentifier> identifiers = const <MusicReleaseIdentifier>[],
  }) {
    final metadata = _decodeMap(row.metadataJson);
    return MusicRelease(
      id: MusicReleaseId(row.id),
      releaseGroupId: MusicReleaseGroupId(row.releaseGroupId),
      title: row.title,
      publisher: row.publisher,
      catalogNumber: row.catalogNumber,
      barcode: row.barcode,
      releaseDate: row.releaseDate,
      releaseStatus: row.releaseStatus,
      releaseType: row.releaseType,
      sortTitle: row.sortTitle,
      subtitle: row.subtitle,
      countryCode: row.countryCode,
      language: row.language,
      coverImageUrl: row.coverImageUrl,
      coverImageKey: row.coverImageKey,
      upc: row.upc,
      packaging: row.packaging,
      contributions: contributions,
      identifiers: identifiers,
      mediums: mediums,
      boxSetMembership: musicBoxSetMembershipFromJson(metadata),
      metadataJson: metadata,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MusicReleaseContributionsRowsCompanion toContributionRow(
    MusicReleaseContribution contribution,
  ) {
    _require(contribution.id.value, 'MusicReleaseContribution');
    _require(
        contribution.releaseId.value, 'MusicReleaseContribution.releaseId');
    return MusicReleaseContributionsRowsCompanion.insert(
      id: contribution.id.value,
      releaseId: contribution.releaseId.value,
      personId: contribution.personId,
      role: contribution.role,
      roleId: Value(contribution.roleId),
      sequence: Value(contribution.sequence),
      metadataJson: Value(jsonEncode(contribution.metadataJson)),
      createdAt: contribution.createdAt,
      updatedAt: contribution.updatedAt,
    );
  }

  static MusicReleaseContribution fromContributionRow(
    MusicReleaseContributionsRow row,
  ) {
    return MusicReleaseContribution(
      id: MusicReleaseContributionId(row.id),
      releaseId: MusicReleaseId(row.releaseId),
      personId: row.personId,
      role: row.role,
      roleId: row.roleId,
      sequence: row.sequence,
      metadataJson: _decodeMap(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MusicReleaseIdentifiersRowsCompanion toIdentifierRow(
    MusicReleaseIdentifier identifier,
  ) {
    _require(identifier.id.value, 'MusicReleaseIdentifier');
    _require(identifier.releaseId.value, 'MusicReleaseIdentifier.releaseId');
    return MusicReleaseIdentifiersRowsCompanion.insert(
      id: identifier.id.value,
      releaseId: identifier.releaseId.value,
      identifierType: identifier.identifierType,
      value: identifier.value,
      normalizedValue: Value(identifier.normalizedValue),
      isPrimary: Value(identifier.isPrimary),
      sourceProvider: Value(identifier.sourceProvider),
      metadataJson: Value(jsonEncode(identifier.metadataJson)),
      createdAt: identifier.createdAt,
      updatedAt: identifier.updatedAt,
    );
  }

  static MusicReleaseIdentifier fromIdentifierRow(
    MusicReleaseIdentifiersRow row,
  ) {
    return MusicReleaseIdentifier(
      id: MusicReleaseIdentifierId(row.id),
      releaseId: MusicReleaseId(row.releaseId),
      identifierType: row.identifierType,
      value: row.value,
      normalizedValue: row.normalizedValue,
      isPrimary: row.isPrimary,
      sourceProvider: row.sourceProvider,
      metadataJson: _decodeMap(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MusicMediumRowsCompanion toMediumRow(MusicMedium medium) {
    _require(medium.id.value, 'MusicMedium');
    _require(medium.releaseId.value, 'MusicMedium.releaseId');
    return MusicMediumRowsCompanion.insert(
      releaseId: medium.releaseId.value,
      id: medium.id.value,
      mediumNumber: medium.mediumNumber,
      mediumType: Value(medium.mediumType),
      rpm: Value(medium.rpm),
      soundType: Value(medium.soundType),
      spars: Value(medium.spars),
      title: Value(medium.title),
      trackCount: Value(medium.trackCount),
      vinylColor: Value(medium.vinylColor),
      vinylWeight: Value(medium.vinylWeight),
      expectedTrackCount: Value(medium.expectedTrackCount),
      missingTrackCount: Value(medium.missingTrackCount),
      missingTrackPositionsJson:
          Value(jsonEncode(medium.missingTrackPositions)),
      toc: Value(medium.toc),
      cddbId: Value(medium.cddbId),
      leadoutOffset: Value(medium.leadoutOffset),
      bpDiscId: Value(medium.bpDiscId),
      mediaCondition: Value(medium.mediaCondition),
      metadataJson: Value(jsonEncode(medium.metadataJson)),
      createdAt: medium.createdAt,
      updatedAt: medium.updatedAt,
    );
  }

  static MusicMedium fromMediumRow(
    MusicMediumRow row, {
    List<MusicTrack> tracks = const <MusicTrack>[],
  }) {
    return MusicMedium(
      id: MusicMediumId(row.id),
      releaseId: MusicReleaseId(row.releaseId),
      mediumNumber: row.mediumNumber,
      mediumType: row.mediumType,
      rpm: row.rpm,
      soundType: row.soundType,
      spars: row.spars,
      title: row.title,
      trackCount: row.trackCount,
      tracks: tracks,
      vinylColor: row.vinylColor,
      vinylWeight: row.vinylWeight,
      expectedTrackCount: row.expectedTrackCount,
      missingTrackCount: row.missingTrackCount,
      missingTrackPositions: _decodeStrings(row.missingTrackPositionsJson),
      toc: row.toc,
      cddbId: row.cddbId,
      leadoutOffset: row.leadoutOffset,
      bpDiscId: row.bpDiscId,
      mediaCondition: row.mediaCondition,
      metadataJson: _decodeMap(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MusicTrackRowsCompanion toTrackRow(MusicTrack track) {
    _require(track.id.value, 'MusicTrack');
    _require(track.mediumId.value, 'MusicTrack.mediumId');
    return MusicTrackRowsCompanion.insert(
      mediumId: track.mediumId.value,
      id: track.id.value,
      position: track.position,
      title: track.title,
      artist: Value(track.artist),
      composition: Value(track.composition),
      durationMs: Value(track.durationMs),
      offsetMs: Value(track.offsetMs),
      bitrateKbps: Value(track.bitrateKbps),
      fileSizeBytes: Value(track.fileSizeBytes),
      trackHash: Value(track.trackHash),
      instrument: Value(track.instrument),
      isHeader: Value(track.isHeader),
      indentLevel: Value(track.indentLevel),
      parentHeaderId: Value(track.parentHeaderId),
      metadataJson: Value(jsonEncode(track.metadataJson)),
      createdAt: track.createdAt,
      updatedAt: track.updatedAt,
    );
  }

  static MusicTrack fromTrackRow(MusicTrackRow row) {
    return MusicTrack(
      id: MusicTrackId(row.id),
      mediumId: MusicMediumId(row.mediumId),
      position: row.position,
      title: row.title,
      artist: row.artist,
      composition: row.composition,
      durationMs: row.durationMs,
      offsetMs: row.offsetMs,
      bitrateKbps: row.bitrateKbps,
      fileSizeBytes: row.fileSizeBytes,
      trackHash: row.trackHash,
      instrument: row.instrument,
      isHeader: row.isHeader,
      indentLevel: row.indentLevel,
      parentHeaderId: row.parentHeaderId,
      metadataJson: _decodeMap(row.metadataJson),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static MusicOwnedItemsRowsCompanion toOwnedItemRow(MusicOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.music) {
      throw StateError('Cannot persist an invalid MusicOwnedItem');
    }
    item.validateReleaseOwnership();

    final details = item.details;
    return MusicOwnedItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      targetRefJson: Value(_encodeTargetRef(item.targetRef)),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      indexNumber: Value(item.indexNumber),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
      soldAt: Value(item.soldAt),
      sellPriceCents: Value(item.sellPriceCents),
      soldTo: Value(item.soldTo),
      ownerUserId: Value(item.ownerUserId),
      ownerLabel: Value(item.ownerLabel),
      locationId: Value(item.locationId),
      purchaseStore: Value(item.purchaseStore),
      collectionStatus: Value(item.collectionStatus),
      marketValueCents: Value(item.marketValueCents),
      storageDevice: Value(details.storageDevice),
      storageSlot: Value(details.storageSlot),
      signedBy: Value(details.signedBy),
      lastCleanedDate: Value(details.lastCleanedDate),
      matrixRunoutsJson: Value(
        jsonEncode(details.matrixRunouts.map((item) => item.toJson()).toList()),
      ),
      discStorageJson: Value(
        jsonEncode(details.discStorage.map((item) => item.toJson()).toList()),
      ),
    );
  }

  static MusicOwnedItem fromOwnedItemRow(MusicOwnedItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.music,
      // Owned copies are anchored to the Music release-group root. The
      // catalog transport uses the structural root entity type (`work`),
      // while `release_group` is a kind-owned domain concept and must not be
      // used as a cross-feature lookup key.
      entityType: CatalogEntityTypeId.root,
      id: row.itemId,
    );
    final item = MusicOwnedItem(
      id: MusicOwnedItemId(row.id),
      catalogRef: catalogRef,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      targetRef: _decodeTargetRef(row.targetRefJson),
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      purchaseStore: row.purchaseStore,
      collectionStatus: row.collectionStatus,
      marketValueCents: row.marketValueCents,
      details: MusicOwnedDetails(
        storageDevice: row.storageDevice,
        storageSlot: row.storageSlot,
        signedBy: row.signedBy,
        lastCleanedDate: row.lastCleanedDate,
        matrixRunouts: [
          for (final value in _decodeMaps(row.matrixRunoutsJson))
            MusicMatrixRunout.fromJson(value),
        ],
        discStorage: [
          for (final value in _decodeMaps(row.discStorageJson))
            MusicDiscStorage.fromJson(value),
        ],
      ),
    );
    item.validateReleaseOwnership();
    return item;
  }

  static String? _encodeTargetRef(CatalogEntityRef? targetRef) =>
      targetRef == null ? null : jsonEncode(targetRef.toJson());

  static CatalogEntityRef? _decodeTargetRef(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final decoded = _decodeJson(raw);
    if (decoded is! Map) return null;
    return CatalogEntityRef.fromJson(Map<String, Object?>.from(decoded));
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<String> _decodeStrings(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static List<Map<String, dynamic>> _decodeMaps(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final value in decoded)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  static void _require(String value, String label) {
    if (value.trim().isEmpty) {
      throw StateError('Cannot persist $label without an id');
    }
  }
}
