import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_catalog_candidate_projection.dart';

const musicAddDiscFilterId = LibraryAddFilterId('music.search.disc');
const musicAddArtistFilterId = LibraryAddFilterId('music.artist');
const musicAddLabelFilterId = LibraryAddFilterId('music.label');
const musicAddYearFilterId = LibraryAddFilterId('music.year');

enum MusicAddDiscFilter {
  all('all', 'All'),
  cd('cd', 'CD'),
  vinyl('vinyl', 'Vinyl'),
  cassette('cassette', 'Cassette'),
  digital('digital', 'Digital'),
  other('other', 'Other');

  const MusicAddDiscFilter(this.value, this.label);

  final String value;
  final String label;
}

MusicAddDiscFilter musicAddDiscFilterFor(LibraryAddSearchContext context) {
  return musicAddDiscFilterFromValue(context.valueFor(musicAddDiscFilterId));
}

MusicAddDiscFilter musicAddDiscFilterFromValue(
  LibraryAddFilterValue? value,
) {
  final raw = switch (value) {
    LibraryAddOptionFilterValue(:final value) => value,
    _ => null,
  };
  return MusicAddDiscFilter.values.firstWhere(
    (filter) => filter.value == raw?.trim().toLowerCase(),
    orElse: () => MusicAddDiscFilter.all,
  );
}

bool musicAddHasSearchInput(LibraryAddSearchContext context) {
  if (context.query.trim().isNotEmpty ||
      context.identifierCode.trim().isNotEmpty) {
    return true;
  }
  for (final entry in context.advancedFilters.entries) {
    if (entry.key == musicAddDiscFilterId) {
      continue;
    }
    if (entry.value.hasValue) return true;
  }
  return musicAddDiscFilterFor(context) != MusicAddDiscFilter.all;
}

bool musicAddCoreCandidateMatchesDisc(
  CatalogSearchCandidate item,
  LibraryAddSearchContext context,
) {
  final filter = musicAddDiscFilterFor(context);
  if (filter == MusicAddDiscFilter.all) return true;
  return musicAddDiscFilterMatchesTypes(
    [musicCatalogItemFromCandidate(item).format ?? ''],
    filter,
  );
}

bool musicAddDiscFilterMatchesTypes(
  Iterable<String> values,
  MusicAddDiscFilter filter,
) {
  if (filter == MusicAddDiscFilter.all) return true;
  final types = values
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (types.isEmpty) return false;
  return types.any((value) => switch (filter) {
        MusicAddDiscFilter.cd => _isCd(value),
        MusicAddDiscFilter.vinyl => _isVinyl(value),
        MusicAddDiscFilter.cassette => _isCassette(value),
        MusicAddDiscFilter.digital => _isDigital(value),
        MusicAddDiscFilter.other => !_isCd(value) &&
            !_isVinyl(value) &&
            !_isCassette(value) &&
            !_isDigital(value),
        MusicAddDiscFilter.all => true,
      });
}

bool _isCd(String value) =>
    value.contains('cd') || value.contains('compact disc');

bool _isVinyl(String value) =>
    value.contains('vinyl') || value.contains('record') || value == 'lp';

bool _isCassette(String value) =>
    value.contains('cassette') || value.contains('tape');

bool _isDigital(String value) =>
    value.contains('digital') ||
    value.contains('download') ||
    value.contains('stream') ||
    value.contains('file') ||
    value.contains('mp3') ||
    value.contains('flac');
