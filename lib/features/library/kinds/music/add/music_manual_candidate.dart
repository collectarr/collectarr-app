import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_form_values.dart';
import 'package:collectarr_app/features/library/kinds/music/forms/music_release_group_form_values.dart';

/// Builds the typed catalog candidate used by Music's manual Add flow.
///
/// The shared Add host only asks the registered kind capability for this
/// candidate; it does not interpret Music fields or construct a Music graph.
CatalogSearchCandidate? buildMusicManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MusicAddManualDraft) return null;
  if (title.trim().isEmpty || musicAddSchema.validate!(draft) != null) {
    return null;
  }

  final normalizedTitle = title.trim();
  final releaseDate = draft.release.releaseDate ?? _yearDate(draft.year);
  final groupId = MusicReleaseGroupId(
    'manual-music-${DateTime.now().microsecondsSinceEpoch}',
  );
  final releaseId = MusicReleaseId('${groupId.value}-release');
  final groupValues = MusicReleaseGroupFormValues(
    title: normalizedTitle,
    artist: draft.releaseGroup.artist,
    originalReleaseDate: releaseDate,
    genres: draft.releaseGroup.genres,
    coverImageUrl: draft.releaseGroup.coverImageUrl,
  );
  final releaseValues = MusicReleaseFormValues(
    title: _textOrNull(draft.release.title) ?? normalizedTitle,
    publisher: draft.release.publisher,
    catalogNumber: draft.release.catalogNumber,
    barcode: draft.release.barcode,
    physicalFormat: draft.release.physicalFormat,
    physicalFormatLabel: draft.release.physicalFormatLabel,
    packaging: draft.release.packaging,
    countryCode: draft.release.countryCode,
    language: draft.release.language,
    releaseDate: releaseDate,
  );
  final mediumType = _textOrNull(
    releaseValues.physicalFormatLabel.isNotEmpty
        ? releaseValues.physicalFormatLabel
        : releaseValues.physicalFormat,
  );
  final release = MusicReleaseFormAdapter.create(
    releaseValues,
    id: releaseId,
    releaseGroupId: groupId,
    mediums: mediumType == null
        ? const []
        : [
            MusicMedium(
              id: MusicMediumId('${releaseId.value}:medium:1'),
              releaseId: releaseId,
              mediumNumber: 1,
              mediumType: mediumType,
            ),
          ],
  );
  final group = MusicReleaseGroupFormAdapter.create(
    groupValues,
    id: groupId,
    releases: [release],
  );
  final item = CatalogItemDto.raw(
    id: groupId.value,
    mediaKind: CatalogMediaKind.music,
    common: CatalogCommonDto(
      title: normalizedTitle,
      coverImageUrl: group.coverImageUrl,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year,
    ),
    kindMetadata: group,
  );
  return CatalogSearchCandidate.fromItem(item);
}

/// Builds a flat Core proposal directly from the Music Add form values.
///
/// Proposal data must not recreate a synthetic Release Group and Release just
/// to serialize the fields displayed by the form.
Map<String, Object?>? buildMusicManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MusicAddManualDraft) return null;
  if (title.trim().isEmpty || musicAddSchema.validate!(draft) != null) {
    return null;
  }

  final release = draft.release;
  final album = draft.releaseGroup;
  final artist = _textOrNull(album.artist);
  final date = release.releaseDate;
  final releaseDate = date == null
      ? (draft.year == null ? null : <String, Object?>{'year': draft.year})
      : <String, Object?>{
          'year': date.year,
          'month': date.month,
          'day': date.day,
        };
  final format = _textOrNull(release.physicalFormatLabel) ??
      _textOrNull(release.physicalFormat);
  final barcode = _textOrNull(release.barcode) ?? _textOrNull(release.upc);
  final country = _textOrNull(release.countryCode);
  final studio = _textOrNull(album.studio);
  final cover =
      _textOrNull(album.coverImageUrl) ?? _textOrNull(release.coverImageUrl);

  return {
    'title': title.trim(),
    if (_textOrNull(album.sortTitle) case final value?) 'sort_title': value,
    if (_textOrNull(release.subtitle) case final value?) 'subtitle': value,
    if (releaseDate != null) 'release_date': releaseDate,
    if (album.originalReleaseDate case final value?)
      'original_release_date': _dateValue(value),
    if (album.recordingDate case final value?)
      'recording_date': _dateValue(value),
    if (artist != null)
      'artist_credits': [
        <String, Object?>{'name': artist}
      ],
    if (album.genres.isNotEmpty) 'genres': List<String>.of(album.genres),
    if (_textOrNull(release.publisher) case final value?) 'label': value,
    if (format != null) 'format': format,
    if (barcode != null) 'barcode': barcode,
    if (_textOrNull(release.catalogNumber) case final value?)
      'catalog_number': value,
    if (country != null) 'country': country,
    if (_textOrNull(release.packaging) case final value?) 'packaging': value,
    if (studio != null) 'studios': [studio],
    if (album.isLive != null) 'is_live': album.isLive,
    if (_textOrNull(release.boxSetName) case final value?) 'box_set': value,
    if (cover != null) 'cover_image_url': cover,
  };
}

DateTime? _yearDate(int? year) =>
    year == null || year < 1 ? null : DateTime.utc(year);

Map<String, Object?> _dateValue(DateTime value) => {
      'year': value.year,
      'month': value.month,
      'day': value.day,
    };

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
