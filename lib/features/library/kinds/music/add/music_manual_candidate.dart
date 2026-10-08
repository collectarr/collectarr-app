import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_kind_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_manual_contents.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';

/// Builds the typed flat catalog candidate used by Music's manual Add flow.
///
/// The shared Add host only asks the registered kind capability for this
/// candidate; the concrete edition stays a kind-entry Music item with
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
  final id = 'manual-music-${DateTime.now().microsecondsSinceEpoch}';
  final itemJson = <String, dynamic>{
    'id': id,
    'kind': 'music',
    'title': normalizedTitle,
    'artist': _textOrNull(draft.artist),
    'revision': 1,
    ...proposal,
  };
  final musicItem = MusicCatalogMapper.fromCatalogPayload(itemJson);
  final localMusic = MusicAlbum.fromJson(
      {...musicItem.toJson(), 'discs': _candidateDiscs(draft)});
  final item = MusicCatalogMapper.toLocalCatalogItemDto(localMusic);
  return CatalogSearchCandidate.fromItem(item);
}

/// Builds a flat Core proposal directly from the Music Add form values.
///
/// Proposal data follows the flat Music Catalog Item contract shown by the form.
Map<String, Object?>? buildMusicManualProposalData(
  LibraryKindAddDraft draft, {
  required String title,
}) {
  if (draft is! MusicAddManualDraft) return null;
  if (title.trim().isEmpty || musicAddSchema.validate!(draft) != null) {
    return null;
  }

  final artist = _textOrNull(draft.artist);
  final releaseDateParts = draft.releaseDateParts;
  final barcode = _textOrNull(draft.barcode);
  final countryCode = _textOrNull(draft.countryCode);
  final country = countryCode == null
      ? null
      : _textOrNull(musicCountryName(countryCode) ?? countryCode);
  final cover = _textOrNull(draft.coverImageUrl);
  final backCover = _textOrNull(draft.backCoverImageUrl);
  final originalReleaseDateParts = draft.originalReleaseDateParts;
  final recordingDateParts = draft.recordingDateParts;

  return {
    'title': title.trim(),
    if (_textOrNull(draft.sortTitle) case final value?) 'sort_title': value,
    if (_textOrNull(draft.subtitle) case final value?) 'subtitle': value,
    if (releaseDateParts != null) 'release_date': releaseDateParts.toJson(),
    if (originalReleaseDateParts != null)
      'original_release_date': originalReleaseDateParts.toJson(),
    if (recordingDateParts != null)
      'recording_date': recordingDateParts.toJson(),
    'artist_credits': [
      for (var index = 0; index < draft.artistCredits.length; index++)
        {
          'id': draft.artistCredits[index].id,
          'name': draft.artistCredits[index].creditedName,
          if (draft.artistCredits[index].sortName != null)
            'sort_name': draft.artistCredits[index].sortName,
          if (draft.artistCredits[index].artistId != null)
            'artist_id': draft.artistCredits[index].artistId,
          if (draft.artistCredits[index].joinPhrase != null)
            'join_phrase': draft.artistCredits[index].joinPhrase,
          'sequence': index + 1,
        },
    ],
    'genres': List<String>.of(draft.genres),
    if (_textOrNull(draft.recordLabel) case final value?) 'label': value,
    if (barcode != null) 'barcode': barcode,
    if (_textOrNull(draft.catalogNumber) case final value?)
      'catalog_number': value,
    if (country != null) 'country': country,
    if (_textOrNull(draft.packaging) case final value?) 'packaging': value,
    'studios': List<String>.of(draft.studios),
    if (draft.isLive != null) 'is_live': draft.isLive,
    'extra': List<String>.of(draft.extra),
    if (_textOrNull(draft.sparsCode) case final value?) 'spars_code': value,
    if (_textOrNull(draft.boxSet) case final value?) 'box_set': value,
    if (cover != null) 'cover_image_url': cover,
    if (backCover != null) 'back_cover_image_url': backCover,
    'composers': _namedCredits(draft.composers),
    'conductors': _namedCredits(draft.conductors),
    'choruses': _creditNames(draft.choruses),
    'compositions': _creditNames(draft.compositions),
    'orchestras': _creditNames(draft.orchestras),
    'songwriters': _namedCredits(draft.songwriters),
    'producers': _namedCredits(draft.producers),
    'engineers': _namedCredits(draft.engineers),
    'musicians': _namedCredits(draft.musicians),
    'discs': [
      for (var index = 0; index < draft.discs.length; index++)
        draft.discs[index].toProposalData(index + 1),
    ],
    'external_links': [
      for (final link in draft.externalLinks)
        if (link.url.trim().isNotEmpty) link.toProposalData(),
    ],
  };
}

List<Map<String, dynamic>> _candidateDiscs(
  MusicAddManualDraft draft,
) =>
    [
      for (var discIndex = 0; discIndex < draft.discs.length; discIndex++)
        draft.discs[discIndex].toProposalData(discIndex + 1),
    ];

List<Map<String, Object?>> _namedCredits(
  Iterable<MusicAddManualNamedCredit> credits,
) {
  final namedCredits = credits
      .where((credit) => credit.name.trim().isNotEmpty)
      .toList(growable: false);
  return [
    for (var index = 0; index < namedCredits.length; index++)
      namedCredits[index].toCatalogData(sequence: index + 1),
  ];
}

List<String> _creditNames(Iterable<MusicAddManualNamedCredit> credits) => [
      for (final credit in credits)
        if (credit.name.trim().isNotEmpty) credit.name.trim(),
    ];

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
