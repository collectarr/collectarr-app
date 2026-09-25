import 'package:collectarr_app/features/library/kinds/music/domain/music_external_link.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';

abstract final class MusicReleaseGroupFormAdapter {
  static MusicReleaseGroup create(
    MusicReleaseGroupFormValues values, {
    required MusicReleaseGroupId id,
    List<MusicRelease> releases = const [],
  }) =>
      MusicReleaseGroup(
        id: id,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        artist: _text(values.artist),
        originalTitle: _text(values.originalTitle),
        originalReleaseDate: values.originalReleaseDate,
        recordingDate: values.recordingDate,
        studio: _text(values.studio),
        isLive: values.isLive,
        genres: List.unmodifiable(values.genres),
        coverImageUrl: _text(values.coverImageUrl),
        releases: List.unmodifiable(releases),
      );

  static MusicReleaseGroup update(
    MusicReleaseGroup original,
    MusicReleaseGroupFormValues values, {
    required List<MusicExternalLink> externalLinks,
    required String? localCoverImagePath,
    required String? localBackImagePath,
    required String? localThumbnailImagePath,
  }) =>
      MusicReleaseGroup(
        id: original.id,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        artist: _text(values.artist),
        originalTitle: _text(values.originalTitle),
        originalReleaseDate: values.originalReleaseDate,
        originalReleaseDateParts:
            values.originalReleaseDate == original.originalReleaseDate
                ? original.originalReleaseDateParts
                : null,
        recordingDate: values.recordingDate,
        recordingDateParts: values.recordingDate == original.recordingDate
            ? original.recordingDateParts
            : null,
        studio: _text(values.studio),
        isLive: values.isLive,
        genres: List.unmodifiable(values.genres),
        artistCredits: original.artistCredits,
        coverImageUrl: _text(values.coverImageUrl),
        coverImageKey: original.coverImageKey,
        externalLinks: List.unmodifiable(externalLinks),
        releases: original.releases,
        localCoverImagePath: localCoverImagePath,
        localBackImagePath: localBackImagePath,
        localThumbnailImagePath: localThumbnailImagePath,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
      );
}

abstract final class MusicReleaseFormAdapter {
  static MusicRelease create(
    MusicReleaseFormValues values, {
    required MusicReleaseId id,
    required MusicReleaseGroupId releaseGroupId,
    List<MusicMedium> mediums = const [],
  }) =>
      MusicRelease(
        id: id,
        releaseGroupId: releaseGroupId,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        subtitle: _text(values.subtitle),
        releaseType: _text(values.releaseType),
        releaseStatus: _text(values.releaseStatus),
        releaseDate: values.releaseDate,
        publisher: _text(values.publisher),
        countryCode: _text(values.countryCode),
        language: _text(values.language),
        barcode: _text(values.barcode),
        upc: _text(values.upc),
        catalogNumber: _text(values.catalogNumber),
        packaging: _text(values.packaging),
        boxSetName: _text(values.boxSetName),
        coverImageUrl: _text(values.coverImageUrl),
        boxSetMembership: values.boxSetMembership,
        mediums: List.unmodifiable(mediums),
      );

  static MusicRelease update(
    MusicRelease original,
    MusicReleaseFormValues values, {
    List<MusicMedium>? mediums,
    List<MusicExternalLink>? externalLinks,
    List<MusicReleaseContribution>? contributions,
  }) =>
      MusicRelease(
        id: original.id,
        releaseGroupId: original.releaseGroupId,
        title: values.title.trim(),
        sortTitle: _text(values.sortTitle),
        subtitle: _text(values.subtitle),
        releaseType: _text(values.releaseType),
        releaseStatus: _text(values.releaseStatus),
        releaseDate: values.releaseDate,
        releaseDateParts: values.releaseDate == original.releaseDate
            ? original.releaseDateParts
            : null,
        publisher: _text(values.publisher),
        countryCode: _text(values.countryCode),
        language: _text(values.language),
        barcode: _text(values.barcode),
        upc: _text(values.upc),
        catalogNumber: _text(values.catalogNumber),
        packaging: _text(values.packaging),
        boxSetName: _text(values.boxSetName),
        coverImageUrl: _text(values.coverImageUrl),
        coverImageKey: original.coverImageKey,
        externalLinks:
            List.unmodifiable(externalLinks ?? original.externalLinks),
        boxSetMembership: values.boxSetMembership,
        createdAt: original.createdAt,
        updatedAt: original.updatedAt,
        contributions:
            List.unmodifiable(contributions ?? original.contributions),
        artistCredits: original.artistCredits,
        labels: original.labels,
        identifiers: original.identifiers,
        mediums: List.unmodifiable(mediums ?? original.mediums),
      );
}

String? _text(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
