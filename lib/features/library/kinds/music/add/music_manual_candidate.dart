import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';

/// Builds the typed flat catalog candidate used by Music's manual Add flow.
///
/// The shared Add host only asks the registered kind capability for this
/// candidate; the concrete edition stays a kind-owned Music item with
/// contained discs and tracks.
CatalogSearchCandidate? buildMusicManualCandidate(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MusicAddManualDraft) return null;
  if (title.trim().isEmpty || musicAddSchema.validate!(draft) != null) {
    return null;
  }

  final normalizedTitle = title.trim();
  final proposal = buildMusicManualProposalData(draft, title: normalizedTitle);
  if (proposal == null) return null;
  final releaseDate = draft.release.releaseDate ?? _yearDate(draft.year);
  final id = 'manual-music-${DateTime.now().microsecondsSinceEpoch}';
  final itemJson = <String, dynamic>{
    'id': id,
    'kind': 'music',
    'title': normalizedTitle,
    'artist': _textOrNull(draft.releaseGroup.artist),
    'revision': 1,
    ...proposal,
    if (releaseDate != null)
      'release_date': releaseDate.toIso8601String().split('T').first,
  };
  _normalizePartialDate(itemJson, 'original_release_date');
  _normalizePartialDate(itemJson, 'recording_date');
  _normalizePartialDate(itemJson, 'release_date');
  final musicItem = CatalogMusicItemDto.fromJson(itemJson);
  final item = CatalogItemDto.raw(
    id: id,
    mediaKind: CatalogMediaKind.music,
    common: CatalogCommonDto(
      title: normalizedTitle,
      coverImageUrl: musicItem.coverImageUrl,
      releaseDate: releaseDate,
      releaseYear: releaseDate?.year,
    ),
    kindMetadata: musicItem,
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

void _normalizePartialDate(Map<String, dynamic> payload, String field) {
  final value = payload[field];
  if (value is! Map) return;
  final parts = Map<String, dynamic>.from(value);
  payload['${field}_parts'] = parts;
  payload[field] = [
    parts['year']?.toString().padLeft(4, '0'),
    if (parts['month'] != null) parts['month'].toString().padLeft(2, '0'),
    if (parts['day'] != null) parts['day'].toString().padLeft(2, '0'),
  ].whereType<String>().join('-');
}

Map<String, Object?> _dateValue(DateTime value) => {
      'year': value.year,
      'month': value.month,
      'day': value.day,
    };

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
