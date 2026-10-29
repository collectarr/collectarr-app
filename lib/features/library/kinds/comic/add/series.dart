import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/ui/app_icons.dart';

/// The Add Comics Series tab: Core series, then every issue of one.
const comicAddSeries = LibraryAddBrowseCapability(
  label: 'Series',
  hintText: 'Enter series title...',
  icon: AppIcons.series,
  searchGroups: searchComicSeries,
  loadItemRows: loadComicSeriesIssueRows,
);

Future<List<LibraryAddBrowseGroup>> searchComicSeries(
    ApiClient api, String query) async {
  final rows = await api.getJsonRows(
    '/api/v1/metadata/comics/series',
    queryParameters: {'q': query, 'limit': 50},
  );
  return rows.map(comicAddSeriesFromJson).toList(growable: false);
}

Future<List<Map<String, dynamic>>> loadComicSeriesIssueRows(
        ApiClient api, LibraryAddBrowseGroup series) =>
    api.getJsonRows(
      '/api/v1/metadata/comics/series/issues',
      queryParameters: series.query,
    );

/// One Core series row; a volume start year names the volume, as in
/// "Amazing Spider-Man (2018)".
LibraryAddBrowseGroup comicAddSeriesFromJson(Map<String, dynamic> json) {
  final title = json['series_title'] as String;
  final publisher = json['publisher'] as String?;
  final volume = json['volume_start_year'] as int?;
  final first = json['first_year'] as int?;
  final last = json['last_year'] as int?;
  final count = json['issue_count'] as int;
  final years = first == null
      ? null
      : (last == null || last == first ? '$first' : '$first–$last');
  final details = [
    if (publisher != null) publisher,
    if (years != null) years,
  ].join(', ');
  return LibraryAddBrowseGroup(
    title: volume == null ? title : '$title ($volume)',
    countLabel: '$count ${count == 1 ? 'issue' : 'issues'}',
    coverImageUrl: json['cover_image_url'] as String?,
    details: details.isEmpty ? null : details,
    query: {
      'series_title': title,
      if (publisher != null) 'publisher': publisher,
      if (volume != null) 'volume_start_year': volume,
    },
  );
}
