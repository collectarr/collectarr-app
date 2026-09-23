import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/catalog/music_catalog_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/provider/music_provider_candidates.dart';
import 'package:collectarr_app/features/providers/transport/provider_search_candidate.dart';

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

String? musicAddProviderMediumQuery(LibraryAddSearchContext context) {
  return switch (musicAddMediumFilterFor(context)) {
    MusicAddMediumFilter.cd => 'format:CD',
    MusicAddMediumFilter.vinyl => 'format:Vinyl',
    MusicAddMediumFilter.cassette => 'format:Cassette',
    MusicAddMediumFilter.digital => 'format:Digital',
    MusicAddMediumFilter.all || MusicAddMediumFilter.other => null,
  };
}

bool musicAddCoreCandidateMatchesMedium(
  CatalogSearchCandidate item,
  LibraryAddSearchContext context,
) {
  final filter = musicAddMediumFilterFor(context);
  if (filter == MusicAddMediumFilter.all) return true;
  final group = item.mapTransport(MusicCatalogMapper.mapMetadataItemToMusic);
  return group.releases.any(
    (release) => musicAddMediumFilterMatchesTypes(
      musicAddMediumTypesForRelease(release),
      filter,
    ),
  );
}

bool musicAddProviderCandidateMatchesMedium(
  ProviderSearchCandidate candidate,
  LibraryAddSearchContext context,
) {
  final filter = musicAddMediumFilterFor(context);
  if (filter == MusicAddMediumFilter.all) return true;
  if (candidate case final MusicReleaseGroupCandidate group) {
    final types = [
      for (final release in group.releases)
        if (release.format?.trim() case final format? when format.isNotEmpty)
          format,
    ];
    return types.isEmpty || musicAddMediumFilterMatchesTypes(types, filter);
  }
  if (candidate case final MusicReleaseCandidate release) {
    final types = [
      for (final medium in release.mediums)
        if (medium.format?.trim() case final format? when format.isNotEmpty)
          format,
    ];
    return musicAddMediumFilterMatchesTypes(types, filter);
  }
  return false;
}

List<String> musicAddMediumTypesForRelease(MusicRelease release) {
  final values = <String>[];
  for (final medium in release.mediums) {
    final value = medium.mediumType?.trim();
    if (value != null && value.isNotEmpty) values.add(value);
  }
  return values;
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
