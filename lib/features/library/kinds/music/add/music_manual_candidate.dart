import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/catalog_music_item_dto.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

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
  final releaseDateParts =
      draft.releaseDateParts ?? _partsFromDate(draft.releaseDate);
  final id = 'manual-music-${DateTime.now().microsecondsSinceEpoch}';
  final itemJson = <String, dynamic>{
    'id': id,
    'kind': 'music',
    'title': normalizedTitle,
    'artist': _textOrNull(draft.artist),
    'revision': 1,
    ...proposal,
    'discs': _candidateDiscs(draft, id),
  };
  final musicItem = CatalogMusicItemDto.fromJson(itemJson);
  final item = CatalogItemDto.raw(
    id: id,
    mediaKind: CatalogMediaKind.music,
    common: CatalogCommonDto(
      title: normalizedTitle,
      coverImageUrl: musicItem.coverImageUrl,
      releaseDate: releaseDateParts?.asDateTime,
      releaseDateParts: releaseDateParts,
      releaseYear: releaseDateParts?.year,
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
  final releaseDateParts =
      draft.releaseDateParts ?? _partsFromDate(draft.releaseDate);
  final format = _textOrNull(draft.format);
  final barcode = _textOrNull(draft.barcode);
  final countryCode = _textOrNull(draft.countryCode);
  final country = countryCode == null
      ? null
      : _textOrNull(musicCountryName(countryCode) ?? countryCode);
  final cover = _textOrNull(draft.coverImageUrl);
  final backCover = _textOrNull(draft.backCoverImageUrl);
  final originalReleaseDateParts = draft.originalReleaseDateParts ??
      _partsFromDate(draft.originalReleaseDate);
  final recordingDateParts =
      draft.recordingDateParts ?? _partsFromDate(draft.recordingDate);

  return {
    'title': title.trim(),
    if (_textOrNull(draft.sortTitle) case final value?) 'sort_title': value,
    if (_textOrNull(draft.subtitle) case final value?) 'subtitle': value,
    if (releaseDateParts != null) 'release_date': releaseDateParts.isoString,
    if (originalReleaseDateParts != null)
      'original_release_date': originalReleaseDateParts.isoString,
    if (recordingDateParts != null)
      'recording_date': recordingDateParts.isoString,
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
    if (draft.studios.isNotEmpty) 'studios': List<String>.of(draft.studios),
    if (draft.isLive != null) 'is_live': draft.isLive,
    if (draft.soundTypes.isNotEmpty)
      'sound_types': List<String>.of(draft.soundTypes),
    if (_textOrNull(draft.vinylColor) case final value?) 'vinyl_color': value,
    if (_textOrNull(draft.vinylWeight) case final value?) 'vinyl_weight': value,
    if (draft.rpm != null) 'rpm': draft.rpm,
    if (_textOrNull(draft.extra) case final value?) 'extra': value,
    if (_textOrNull(draft.spars) case final value?) 'spars': value,
    if (_textOrNull(draft.boxSet) case final value?) 'box_set': value,
    if (cover != null) 'cover_image_url': cover,
    if (backCover != null) 'back_cover_image_url': backCover,
    if (draft.composers.isNotEmpty) 'composers': _namedCredits(draft.composers),
    if (draft.conductors.isNotEmpty)
      'conductors': _namedCredits(draft.conductors),
    if (draft.choruses.isNotEmpty) 'choruses': _creditNames(draft.choruses),
    if (draft.compositions.isNotEmpty)
      'compositions': _creditNames(draft.compositions),
    if (draft.orchestras.isNotEmpty)
      'orchestras': _creditNames(draft.orchestras),
    if (draft.songwriters.isNotEmpty)
      'songwriters': _namedCredits(draft.songwriters),
    if (draft.producers.isNotEmpty) 'producers': _namedCredits(draft.producers),
    if (draft.engineers.isNotEmpty) 'engineers': _namedCredits(draft.engineers),
    if (draft.musicians.isNotEmpty) 'musicians': _namedCredits(draft.musicians),
    if (draft.discs.isNotEmpty)
      'discs': [
        for (var index = 0; index < draft.discs.length; index++)
          draft.discs[index].toProposalData(index + 1),
      ],
    if (draft.externalLinks.any((link) => link.url.trim().isNotEmpty))
      'external_links': [
        for (final link in draft.externalLinks)
          if (link.url.trim().isNotEmpty) link.toProposalData(),
      ],
  };
}

List<Map<String, dynamic>> _candidateDiscs(
  MusicAddManualDraft draft,
  String itemId,
) =>
    [
      for (var discIndex = 0; discIndex < draft.discs.length; discIndex++)
        _candidateDisc(draft.discs[discIndex], itemId, discIndex),
    ];

Map<String, dynamic> _candidateDisc(
  MusicAddManualDisc disc,
  String itemId,
  int discIndex,
) {
  final tracks = disc.tracks
      .where((track) => track.title.trim().isNotEmpty)
      .toList(growable: false);
  return {
    'id': '$itemId:disc:${discIndex + 1}',
    'disc_number': discIndex + 1,
    if (disc.title.trim().isNotEmpty) 'title': disc.title.trim(),
    if (disc.matrixNumberSideA.trim().isNotEmpty)
      'matrix_number_side_a': disc.matrixNumberSideA.trim(),
    if (disc.matrixNumberSideB.trim().isNotEmpty)
      'matrix_number_side_b': disc.matrixNumberSideB.trim(),
    'tracks': [
      for (var trackIndex = 0; trackIndex < tracks.length; trackIndex++)
        {
          'id': '$itemId:disc:${discIndex + 1}:track:${trackIndex + 1}',
          'position': '${trackIndex + 1}',
          'position_order': trackIndex,
          'title': tracks[trackIndex].title.trim(),
          if (tracks[trackIndex].artist.trim().isNotEmpty)
            'artist': tracks[trackIndex].artist.trim(),
          if (tracks[trackIndex].durationMs case final durationMs?)
            'duration_ms': durationMs,
        },
    ],
  };
}

List<Map<String, Object?>> _namedCredits(
  Iterable<MusicAddManualNamedCredit> credits,
) =>
    [
      for (final credit in credits)
        if (credit.name.trim().isNotEmpty) credit.toCatalogData(),
    ];

List<String> _creditNames(Iterable<MusicAddManualNamedCredit> credits) => [
      for (final credit in credits)
        if (credit.name.trim().isNotEmpty) credit.name.trim(),
    ];

PartialDate? _partsFromDate(DateTime? date) =>
    date == null ? null : PartialDate.fromDateTime(date);

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
