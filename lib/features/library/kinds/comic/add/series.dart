import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_issue_label.dart';
import 'package:collectarr_app/features/library/add/contracts/library_add_capability.dart';
import 'package:collectarr_app/ui/app_icons.dart';

/// The Add Comics Series tab: Core series, then every issue of one.
const comicAddSeries = LibraryAddBrowseCapability(
  label: 'Series',
  hintText: 'Enter series title...',
  icon: AppIcons.search,
  searchGroups: searchComicSeries,
  loadItemRows: loadComicSeriesIssueRows,
  coverBlock: comicAddCoverBlock,
);

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// An issue's block in the series grid: "#1A", the cover month and year
/// (else the release's), and the variant description.
LibraryAddCoverBlock comicAddCoverBlock(CatalogSearchCandidate item) {
  final comic = item.comicCatalogFields.metadata;
  final date = comic?.coverDateParts ??
      (comic?.coverDate == null
          ? null
          : PartialDate.fromDateTime(comic!.coverDate!)) ??
      comic?.releaseDateParts;
  final month = date?.month;
  return LibraryAddCoverBlock(
    badge: '#${comicIssueText(comic?.issueNumber, comic?.variant) ?? ''}',
    month: month == null || month < 1 || month > 12 ? null : _months[month - 1],
    year: date?.year,
    caption: comic?.variantDescription?.trim(),
  );
}

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
      : (last == null || last == first ? '$first' : '$first - $last');
  return LibraryAddBrowseGroup(
    title: volume == null ? title : '$title ($volume)',
    countLabel: '$count',
    coverImageUrl: json['cover_image_url'] as String?,
    details: publisher,
    period: years,
    query: {
      'series_title': title,
      if (publisher != null) 'publisher': publisher,
      if (volume != null) 'volume_start_year': volume,
    },
  );
}
