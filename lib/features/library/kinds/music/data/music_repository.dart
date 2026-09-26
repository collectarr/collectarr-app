import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/repositories/repository_contracts.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_box_set_membership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:drift/drift.dart';

/// Typed Music repository for the release-group -> release -> medium -> track
/// graph. A group and a concrete release intentionally have separate APIs.
final class MusicRepository
    implements ReadRepository<MusicReleaseGroupId, MusicReleaseGroup> {
  MusicRepository(this._db);

  final LocalDatabase _db;

  @override
  Future<MusicReleaseGroup?> findById(MusicReleaseGroupId id) =>
      getReleaseGroup(id);

  Future<MusicRelease?> getRelease(MusicReleaseId id) async {
    final row = await (_db.select(_db.musicReleaseRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row == null) return null;
    return _hydrateRelease(row);
  }

  Future<MusicReleaseGroup?> getReleaseGroup(MusicReleaseGroupId id) async {
    final row = await (_db.select(_db.musicReleaseGroupRows)
          ..where((table) => table.id.equals(id.value)))
        .getSingleOrNull();
    if (row == null) return null;
    return MusicLocalMapper.fromReleaseGroupRow(
      row,
      releases: await releasesForGroup(id),
      artistCredits: await artistCreditsForGroup(id),
    );
  }

  Future<List<MusicReleaseGroup>> searchReleaseGroups(
      [String query = '']) async {
    final normalizedQuery = query.trim();
    final select = _db.select(_db.musicReleaseGroupRows);
    if (normalizedQuery.isNotEmpty) {
      final pattern = '%$normalizedQuery%';
      select.where(
        (table) =>
            table.title.like(pattern) |
            table.artist.like(pattern) |
            table.originalTitle.like(pattern),
      );
    }
    select.orderBy([
      (table) => OrderingTerm.asc(table.title),
      (table) => OrderingTerm.asc(table.id),
    ]);
    final rows = await select.get();
    return [
      for (final row in rows)
        MusicLocalMapper.fromReleaseGroupRow(
          row,
          releases: await releasesForGroup(MusicReleaseGroupId(row.id)),
        ),
    ];
  }

  Future<List<MusicRelease>> search([String query = '']) async {
    final normalizedQuery = query.trim();
    final rows = await _db.select(_db.musicReleaseRows).get();
    final groupRows = normalizedQuery.isEmpty
        ? const <MusicReleaseGroupRow>[]
        : await _db.select(_db.musicReleaseGroupRows).get();
    final groupsById = {
      for (final row in groupRows) row.id: row,
    };
    final filteredRows = rows.where((row) {
      if (normalizedQuery.isEmpty) return true;
      final queryLower = normalizedQuery.toLowerCase();
      final group = groupsById[row.releaseGroupId];
      return row.title.toLowerCase().contains(queryLower) ||
          (row.sortTitle?.toLowerCase().contains(queryLower) ?? false) ||
          (row.publisher?.toLowerCase().contains(queryLower) ?? false) ||
          (group?.title.toLowerCase().contains(queryLower) ?? false) ||
          (group?.artist?.toLowerCase().contains(queryLower) ?? false);
    }).toList()
      ..sort((left, right) {
        final sortTitle =
            (left.sortTitle ?? '').compareTo(right.sortTitle ?? '');
        if (sortTitle != 0) return sortTitle;
        final title = left.title.compareTo(right.title);
        if (title != 0) return title;
        return left.id.compareTo(right.id);
      });
    return [
      for (final row in filteredRows) await _hydrateRelease(row),
    ];
  }

  Future<List<MusicRelease>> releasesForGroup(
      MusicReleaseGroupId groupId) async {
    final rows = await (_db.select(_db.musicReleaseRows)
          ..where((table) => table.releaseGroupId.equals(groupId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.releaseDate),
            (table) => OrderingTerm.asc(table.title),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return [for (final row in rows) await _hydrateRelease(row)];
  }

  Future<List<MusicMedium>> mediumsFor(MusicReleaseId releaseId) async {
    final rows = await (_db.select(_db.musicMediumRows)
          ..where((table) => table.releaseId.equals(releaseId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.mediumNumber),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return [
      for (final row in rows)
        MusicLocalMapper.fromMediumRow(
          row,
          tracks: await tracksFor(MusicMediumId(row.id)),
        ),
    ];
  }

  Future<MusicMedium?> getMedium(
    MusicReleaseId releaseId,
    MusicMediumId mediumId,
  ) async {
    final row = await (_db.select(_db.musicMediumRows)
          ..where(
            (table) =>
                table.releaseId.equals(releaseId.value) &
                table.id.equals(mediumId.value),
          ))
        .getSingleOrNull();
    return row == null
        ? null
        : MusicLocalMapper.fromMediumRow(
            row,
            tracks: await tracksFor(mediumId),
          );
  }

  Future<List<MusicTrack>> tracksFor(MusicMediumId mediumId) async {
    final rows = await (_db.select(_db.musicTrackRows)
          ..where((table) => table.mediumId.equals(mediumId.value))
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    final tracks = rows.map(MusicLocalMapper.fromTrackRow).toList()
      ..sort(_compareMusicTrackOrder);
    return List<MusicTrack>.unmodifiable(tracks);
  }

  Future<MusicTrack?> getTrack(
    MusicMediumId mediumId,
    MusicTrackId trackId,
  ) async {
    final row = await (_db.select(_db.musicTrackRows)
          ..where(
            (table) =>
                table.mediumId.equals(mediumId.value) &
                table.id.equals(trackId.value),
          ))
        .getSingleOrNull();
    return row == null ? null : MusicLocalMapper.fromTrackRow(row);
  }

  Future<List<MusicExternalLink>> externalLinksFor(
    MusicReleaseId releaseId,
  ) async {
    final rows = await (_db.select(_db.musicReleaseExternalLinksRows)
          ..where((table) => table.releaseId.equals(releaseId.value))
          ..orderBy([(table) => OrderingTerm.asc(table.sequence)]))
        .get();
    return rows
        .map(MusicLocalMapper.fromExternalLinkRow)
        .toList(growable: false);
  }

  Future<MusicBoxSetMembership?> boxSetMembershipFor(
    MusicReleaseId releaseId,
  ) async {
    final row = await (_db.select(_db.musicReleaseBoxSetMembershipRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .getSingleOrNull();
    return row == null ? null : MusicLocalMapper.fromBoxSetMembershipRow(row);
  }

  Future<String?> boxSetNameFor(MusicReleaseId releaseId) async {
    final row = await (_db.select(_db.musicReleaseLocalDetailsRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .getSingleOrNull();
    return row?.boxSetName;
  }

  Future<void> updateReleaseGroup(MusicReleaseGroup group) async {
    _require(group.id.value, 'MusicReleaseGroup');
    final existing = await getReleaseGroup(group.id);
    final releasesById = <String, MusicRelease>{
      for (final release in existing?.releases ?? const <MusicRelease>[])
        release.id.value: release,
    };
    for (final release in group.releases) {
      releasesById[release.id.value] = release;
    }
    final persistedGroup = MusicReleaseGroup(
      id: group.id,
      title: group.title,
      sortTitle: group.sortTitle,
      artist: group.artist,
      originalTitle: group.originalTitle,
      originalReleaseDate: group.originalReleaseDate,
      originalReleaseDateParts: group.originalReleaseDateParts,
      recordingDate: group.recordingDate,
      recordingDateParts: group.recordingDateParts,
      studio: group.studio,
      isLive: group.isLive,
      genres: group.genres,
      artistCredits: group.artistCredits,
      coverImageUrl: group.coverImageUrl,
      coverImageKey: group.coverImageKey,
      releases: releasesById.values.toList(growable: false),
      externalLinks: group.externalLinks,
      localCoverImagePath: group.localCoverImagePath,
      localBackImagePath: group.localBackImagePath,
      localThumbnailImagePath: group.localThumbnailImagePath,
      createdAt: existing?.createdAt ?? group.createdAt,
      updatedAt: group.updatedAt,
    );
    for (final release in persistedGroup.releases) {
      _validateReleaseBelongs(persistedGroup.id, release);
      _validateMediumGraph(release);
    }

    await _db.transaction(() async {
      await _db.into(_db.musicReleaseGroupRows).insertOnConflictUpdate(
            MusicLocalMapper.toReleaseGroupRow(persistedGroup),
          );
      await (_db.delete(_db.musicArtistCreditsRows)
            ..where((table) =>
                table.targetType.equals('release_group') &
                table.targetId.equals(group.id.value)))
          .go();
      for (final credit in persistedGroup.artistCredits) {
        await _db.into(_db.musicArtistCreditsRows).insertOnConflictUpdate(
              MusicLocalMapper.toArtistCreditRow(
                targetType: 'release_group',
                targetId: group.id.value,
                credit: credit,
              ),
            );
      }
      for (final release in group.releases) {
        await _deleteReleaseGraph(release.id);
        await _writeReleaseGraph(release, preserveLocalDetails: true);
      }
    });
  }

  Future<void> updateRelease(MusicRelease release) async {
    _require(release.id.value, 'MusicRelease');
    _require(release.releaseGroupId.value, 'MusicRelease.releaseGroupId');
    _validateMediumGraph(release);

    await _db.transaction(() async {
      await _ensureReleaseGroupRow(release);
      await _deleteReleaseGraph(release.id);
      await _writeReleaseGraph(release);
    });
  }

  Future<void> updateMedium(
    MusicReleaseId releaseId,
    MusicMedium medium,
  ) async {
    _validateMediumBelongs(releaseId, medium);
    for (final track in medium.tracks) {
      _validateTrackBelongs(medium.id, track);
    }

    await _db.transaction(() async {
      await (_db.delete(_db.musicTrackRows)
            ..where((table) => table.mediumId.equals(medium.id.value)))
          .go();
      await _db.into(_db.musicMediumRows).insertOnConflictUpdate(
            MusicLocalMapper.toMediumRow(medium),
          );
      for (final track in medium.tracks) {
        await _db.into(_db.musicTrackRows).insertOnConflictUpdate(
              MusicLocalMapper.toTrackRow(track),
            );
      }
    });
  }

  Future<void> updateTrack(MusicMediumId mediumId, MusicTrack track) {
    _validateTrackBelongs(mediumId, track);
    return _db.into(_db.musicTrackRows).insertOnConflictUpdate(
          MusicLocalMapper.toTrackRow(track),
        );
  }

  Future<MusicRelease> _hydrateRelease(MusicReleaseRow row) async {
    return MusicLocalMapper.fromReleaseRow(
      row,
      boxSetName: await boxSetNameFor(MusicReleaseId(row.id)),
      externalLinks: await externalLinksFor(MusicReleaseId(row.id)),
      boxSetMembership: await boxSetMembershipFor(MusicReleaseId(row.id)),
      mediums: await mediumsFor(MusicReleaseId(row.id)),
      contributions: await contributionsFor(MusicReleaseId(row.id)),
      identifiers: await identifiersFor(MusicReleaseId(row.id)),
      artistCredits: await artistCreditsForRelease(MusicReleaseId(row.id)),
      labels: await labelsFor(MusicReleaseId(row.id)),
    );
  }

  Future<List<MusicArtistCredit>> artistCreditsForGroup(
    MusicReleaseGroupId groupId,
  ) async {
    final rows = await (_db.select(_db.musicArtistCreditsRows)
          ..where((table) =>
              table.targetType.equals('release_group') &
              table.targetId.equals(groupId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.sequence),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows
        .map(MusicLocalMapper.fromArtistCreditRow)
        .toList(growable: false);
  }

  Future<List<MusicArtistCredit>> artistCreditsForRelease(
    MusicReleaseId releaseId,
  ) async {
    final rows = await (_db.select(_db.musicArtistCreditsRows)
          ..where((table) =>
              table.targetType.equals('release') &
              table.targetId.equals(releaseId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.sequence),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows
        .map(MusicLocalMapper.fromArtistCreditRow)
        .toList(growable: false);
  }

  Future<List<MusicReleaseLabel>> labelsFor(MusicReleaseId releaseId) async {
    final rows = await (_db.select(_db.musicReleaseLabelsRows)
          ..where((table) => table.releaseId.equals(releaseId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.sequence),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows
        .map(MusicLocalMapper.fromReleaseLabelRow)
        .toList(growable: false);
  }

  Future<List<MusicReleaseContribution>> contributionsFor(
    MusicReleaseId releaseId,
  ) async {
    final rows = await (_db.select(_db.musicReleaseContributionsRows)
          ..where((table) => table.releaseId.equals(releaseId.value))
          ..orderBy([
            (table) => OrderingTerm.asc(table.sequence),
            (table) => OrderingTerm.asc(table.id),
          ]))
        .get();
    return rows
        .map(MusicLocalMapper.fromContributionRow)
        .toList(growable: false);
  }

  Future<List<MusicReleaseIdentifier>> identifiersFor(
    MusicReleaseId releaseId,
  ) async {
    final rows = await (_db.select(_db.musicReleaseIdentifiersRows)
          ..where((table) => table.releaseId.equals(releaseId.value))
          ..orderBy([
            (table) => OrderingTerm.desc(table.isPrimary),
            (table) => OrderingTerm.asc(table.identifierType),
            (table) => OrderingTerm.asc(table.value),
          ]))
        .get();
    return rows.map(MusicLocalMapper.fromIdentifierRow).toList(growable: false);
  }

  Future<void> _writeReleaseGraph(
    MusicRelease release, {
    bool preserveLocalDetails = false,
  }) async {
    await _db
        .into(_db.musicReleaseRows)
        .insertOnConflictUpdate(MusicLocalMapper.toReleaseRow(release));
    if (!preserveLocalDetails || release.boxSetName != null) {
      await _db.into(_db.musicReleaseLocalDetailsRows).insertOnConflictUpdate(
            MusicLocalMapper.toReleaseLocalDetailsRow(release),
          );
    }
    for (var index = 0; index < release.externalLinks.length; index++) {
      await _db.into(_db.musicReleaseExternalLinksRows).insert(
            MusicLocalMapper.toExternalLinkRow(
              release.id,
              release.externalLinks[index],
              index,
            ),
          );
    }
    final boxSetMembership = release.boxSetMembership;
    if (boxSetMembership != null) {
      await _db.into(_db.musicReleaseBoxSetMembershipRows).insert(
            MusicLocalMapper.toBoxSetMembershipRow(
              release.id,
              boxSetMembership,
            ),
          );
    }
    for (final contribution in release.contributions) {
      _validateContributionBelongs(release.id, contribution);
      await _db.into(_db.musicReleaseContributionsRows).insertOnConflictUpdate(
            MusicLocalMapper.toContributionRow(contribution),
          );
    }
    for (final identifier in release.identifiers) {
      _validateIdentifierBelongs(release.id, identifier);
      await _db.into(_db.musicReleaseIdentifiersRows).insertOnConflictUpdate(
            MusicLocalMapper.toIdentifierRow(identifier),
          );
    }
    for (final credit in release.artistCredits) {
      await _db.into(_db.musicArtistCreditsRows).insertOnConflictUpdate(
            MusicLocalMapper.toArtistCreditRow(
              targetType: 'release',
              targetId: release.id.value,
              credit: credit,
            ),
          );
    }
    for (final label in release.labels) {
      await _db.into(_db.musicReleaseLabelsRows).insertOnConflictUpdate(
            MusicLocalMapper.toReleaseLabelRow(release.id, label),
          );
    }
    for (final medium in release.mediums) {
      await _db.into(_db.musicMediumRows).insertOnConflictUpdate(
            MusicLocalMapper.toMediumRow(medium),
          );
      for (final track in medium.tracks) {
        await _db.into(_db.musicTrackRows).insertOnConflictUpdate(
              MusicLocalMapper.toTrackRow(track),
            );
      }
    }
  }

  Future<void> _ensureReleaseGroupRow(MusicRelease release) async {
    final existing = await (_db.select(_db.musicReleaseGroupRows)
          ..where((table) => table.id.equals(release.releaseGroupId.value)))
        .getSingleOrNull();
    if (existing != null) return;
    await _db.into(_db.musicReleaseGroupRows).insert(
          MusicLocalMapper.toReleaseGroupRow(
            MusicReleaseGroup(
              id: release.releaseGroupId,
              title: release.title,
              coverImageUrl: release.coverImageUrl,
              releases: [release],
            ),
          ),
        );
  }

  Future<void> _deleteReleaseGraph(MusicReleaseId releaseId) async {
    await (_db.delete(_db.musicReleaseExternalLinksRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicReleaseBoxSetMembershipRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicReleaseContributionsRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicReleaseIdentifiersRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicArtistCreditsRows)
          ..where((table) =>
              table.targetType.equals('release') &
              table.targetId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicReleaseLabelsRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    final mediumRows = await (_db.select(_db.musicMediumRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .get();
    for (final medium in mediumRows) {
      await (_db.delete(_db.musicTrackRows)
            ..where((table) => table.mediumId.equals(medium.id)))
          .go();
    }
    await (_db.delete(_db.musicMediumRows)
          ..where((table) => table.releaseId.equals(releaseId.value)))
        .go();
    await (_db.delete(_db.musicReleaseRows)
          ..where((table) => table.id.equals(releaseId.value)))
        .go();
  }

  static void _validateReleaseBelongs(
    MusicReleaseGroupId groupId,
    MusicRelease release,
  ) {
    if (release.releaseGroupId != groupId) {
      throw StateError('Music release does not belong to the supplied group');
    }
  }

  static int _compareMusicTrackOrder(MusicTrack left, MusicTrack right) {
    final position = _compareNaturalTrackPositions(
      left.position,
      right.position,
    );
    return position == 0 ? left.id.value.compareTo(right.id.value) : position;
  }

  static int _compareNaturalTrackPositions(String left, String right) {
    final leftParts = RegExp(r'\d+|\D+').allMatches(left).toList();
    final rightParts = RegExp(r'\d+|\D+').allMatches(right).toList();
    final count = leftParts.length < rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < count; index++) {
      final leftPart = leftParts[index].group(0)!;
      final rightPart = rightParts[index].group(0)!;
      final leftNumber = int.tryParse(leftPart);
      final rightNumber = int.tryParse(rightPart);
      final comparison = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : leftPart.toLowerCase().compareTo(rightPart.toLowerCase());
      if (comparison != 0) return comparison;
      if (leftNumber != null && rightNumber != null) {
        final widthComparison = leftPart.length.compareTo(rightPart.length);
        if (widthComparison != 0) return widthComparison;
      }
    }
    return leftParts.length.compareTo(rightParts.length);
  }

  static void _validateMediumGraph(MusicRelease release) {
    for (final medium in release.mediums) {
      _validateMediumBelongs(release.id, medium);
      for (final track in medium.tracks) {
        _validateTrackBelongs(medium.id, track);
      }
    }
  }

  static void _validateMediumBelongs(
    MusicReleaseId releaseId,
    MusicMedium medium,
  ) {
    if (medium.releaseId != releaseId) {
      throw StateError('Music medium does not belong to the supplied release');
    }
  }

  static void _validateTrackBelongs(
    MusicMediumId mediumId,
    MusicTrack track,
  ) {
    if (track.mediumId != mediumId) {
      throw StateError('Music track does not belong to the supplied medium');
    }
  }

  static void _validateContributionBelongs(
    MusicReleaseId releaseId,
    MusicReleaseContribution contribution,
  ) {
    if (contribution.releaseId != releaseId) {
      throw StateError(
        'Music release contribution does not belong to the supplied release',
      );
    }
  }

  static void _validateIdentifierBelongs(
    MusicReleaseId releaseId,
    MusicReleaseIdentifier identifier,
  ) {
    if (identifier.releaseId != releaseId) {
      throw StateError(
        'Music release identifier does not belong to the supplied release',
      );
    }
  }

  static void _require(String value, String label) {
    if (value.trim().isEmpty) {
      throw StateError('Cannot persist $label without an id');
    }
  }
}
