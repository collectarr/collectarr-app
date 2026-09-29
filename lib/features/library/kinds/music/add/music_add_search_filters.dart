import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_catalog_candidate_projection.dart';

const musicAddMediumFilterId = LibraryAddFilterId('music.search.medium');
const musicAddArtistFilterId = LibraryAddFilterId('music.artist');
const musicAddLabelFilterId = LibraryAddFilterId('music.label');
const musicAddYearFilterId = LibraryAddFilterId('music.year');

enum MusicAddMediumFilter {
  all('all', 'All'),
  cd('cd', 'CD'),
  vinyl('vinyl', 'Vinyl'),
  cassette('cassette', 'Cassette'),
  digital('digital', 'Digital'),
  other('other', 'Other');

  const MusicAddMediumFilter(this.value, this.label);

  final String value;
  final String label;
}

MusicAddMediumFilter musicAddMediumFilterFor(LibraryAddSearchContext context) {
  return musicAddMediumFilterFromValue(
      context.valueFor(musicAddMediumFilterId));
}

MusicAddMediumFilter musicAddMediumFilterFromValue(
  LibraryAddFilterValue? value,
) {
  final raw = switch (value) {
    LibraryAddOptionFilterValue(:final value) => value,
    _ => null,
  };
  return MusicAddMediumFilter.values.firstWhere(
    (filter) => filter.value == raw?.trim().toLowerCase(),
    orElse: () => MusicAddMediumFilter.all,
  );
}

bool musicAddHasSearchInput(LibraryAddSearchContext context) {
  if (context.query.trim().isNotEmpty ||
      context.identifierCode.trim().isNotEmpty) {
    return true;
  }
  for (final entry in context.advancedFilters.entries) {
    if (entry.key == musicAddMediumFilterId) {
      continue;
    }
    if (entry.value.hasValue) return true;
  }
  return musicAddMediumFilterFor(context) != MusicAddMediumFilter.all;
}

bool musicAddCoreCandidateMatchesMedium(
  CatalogSearchCandidate item,
  LibraryAddSearchContext context,
) {
  final filter = musicAddMediumFilterFor(context);
  if (filter == MusicAddMediumFilter.all) return true;
  return musicAddMediumFilterMatchesTypes(
    [musicCatalogItemFromCandidate(item).format ?? ''],
    filter,
  );
}

bool musicAddMediumFilterMatchesTypes(
  Iterable<String> values,
  MusicAddMediumFilter filter,
) {
  if (filter == MusicAddMediumFilter.all) return true;
  final types = values
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (types.isEmpty) return false;
  return types.any((value) => switch (filter) {
        MusicAddMediumFilter.cd => _isCd(value),
        MusicAddMediumFilter.vinyl => _isVinyl(value),
        MusicAddMediumFilter.cassette => _isCassette(value),
        MusicAddMediumFilter.digital => _isDigital(value),
        MusicAddMediumFilter.other => !_isCd(value) &&
            !_isVinyl(value) &&
            !_isCassette(value) &&
            !_isDigital(value),
        MusicAddMediumFilter.all => true,
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
