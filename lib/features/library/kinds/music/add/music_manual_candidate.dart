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
  final releaseDate = draft.releaseDate ?? _yearDate(draft.year);
  final id = 'manual-music-${DateTime.now().microsecondsSinceEpoch}';
  final itemJson = <String, dynamic>{
    'id': id,
    'kind': 'music',
    'title': normalizedTitle,
    'artist': _textOrNull(draft.artist),
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

  final artist = _textOrNull(draft.artist);
  final date = draft.releaseDate;
  final releaseDate = date == null
      ? (draft.year == null ? null : <String, Object?>{'year': draft.year})
      : <String, Object?>{
          'year': date.year,
          'month': date.month,
          'day': date.day,
        };
  final format = _textOrNull(draft.format);
  final barcode = _textOrNull(draft.barcode);
  final country = _textOrNull(draft.countryCode);
  final cover = _textOrNull(draft.coverImageUrl);

  return {
    'title': title.trim(),
    if (releaseDate != null) 'release_date': releaseDate,
    if (artist != null)
      'artist_credits': [
        <String, Object?>{'name': artist}
      ],
    if (draft.genres.isNotEmpty) 'genres': List<String>.of(draft.genres),
    if (_textOrNull(draft.recordLabel) case final value?) 'label': value,
    if (format != null) 'format': format,
    if (barcode != null) 'barcode': barcode,
    if (_textOrNull(draft.catalogNumber) case final value?)
      'catalog_number': value,
    if (country != null) 'country': country,
    if (_textOrNull(draft.packaging) case final value?) 'packaging': value,
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

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
