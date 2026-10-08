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
    if (releaseDateParts != null) 'release_date': releaseDateParts.isoString,
    if (originalReleaseDateParts != null)
      'original_release_date': originalReleaseDateParts.isoString,
    if (recordingDateParts != null)
      'recording_date': recordingDateParts.isoString,
    if (artist != null || draft.artistCredits.isNotEmpty)
      'artist_credits': draft.artistCredits.isEmpty
          ? [
              <String, Object?>{'name': artist!}
            ]
          : [
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
    if (draft.genres.isNotEmpty) 'genres': List<String>.of(draft.genres),
    if (_textOrNull(draft.recordLabel) case final value?) 'label': value,
    if (barcode != null) 'barcode': barcode,
    if (_textOrNull(draft.catalogNumber) case final value?)
      'catalog_number': value,
    if (country != null) 'country': country,
    if (_textOrNull(draft.packaging) case final value?) 'packaging': value,
    if (draft.studios.isNotEmpty) 'studios': List<String>.of(draft.studios),
    if (draft.isLive != null) 'is_live': draft.isLive,
    if (_textOrNull(draft.extra) case final value?) 'extra': value,
    if (_textOrNull(draft.sparsCode) case final value?) 'spars_code': value,
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
) =>
    [
      for (var discIndex = 0; discIndex < draft.discs.length; discIndex++)
        draft.discs[discIndex].toProposalData(discIndex + 1),
    ];

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

String? _textOrNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
