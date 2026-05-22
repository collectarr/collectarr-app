import 'dart:convert';

import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/library_quick_view.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

/// A saved filter/sort preset that acts as a "smart list".
class SmartList {
  const SmartList({
    required this.id,
    required this.name,
    this.mediaKind,
    this.filterSelection = LibraryFilterSelection.none,
    this.quickView,
    this.sortColumn,
    this.sortAscending,
    this.searchQuery,
  });

  final String id;
  final String name;

  /// If non-null, this smart list only applies to a specific media kind.
  final String? mediaKind;
  final LibraryFilterSelection filterSelection;
  final LibraryQuickView? quickView;
  final LibrarySortColumn? sortColumn;
  final bool? sortAscending;
  final String? searchQuery;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (searchQuery != null) 'search_query': searchQuery,
      if (quickView != null) 'quick_view': quickView!.name,
      if (sortColumn != null) 'sort_column': sortColumn!.name,
      if (sortAscending != null) 'sort_ascending': sortAscending,
      'filter': _filterToJson(filterSelection),
    };
  }

  factory SmartList.fromRow(String id, String name, String criteriaJson) {
    final json = jsonDecode(criteriaJson) as Map<String, dynamic>;
    return SmartList(
      id: id,
      name: name,
      mediaKind: json['media_kind'] as String?,
      searchQuery: json['search_query'] as String?,
      quickView: json['quick_view'] != null
          ? LibraryQuickView.values.byName(json['quick_view'] as String)
          : null,
      sortColumn: json['sort_column'] != null
          ? LibrarySortColumn.values.byName(json['sort_column'] as String)
          : null,
      sortAscending: json['sort_ascending'] as bool?,
      filterSelection: _filterFromJson(
          json['filter'] as Map<String, dynamic>? ?? {}),
    );
  }

  static Map<String, dynamic> _filterToJson(LibraryFilterSelection f) {
    return {
      if (f.ownershipFilter != LibraryOwnershipFilter.all)
        'ownership': f.ownershipFilter.name,
      if (f.series != null) 'series': f.series,
      if (f.grade != null) 'grade': f.grade,
      if (f.condition != null) 'condition': f.condition,
      if (f.publisher != null) 'publisher': f.publisher,
      if (f.releaseYear != null) 'release_year': f.releaseYear,
      if (f.country != null) 'country': f.country,
      if (f.language != null) 'language': f.language,
      if (f.missingCover) 'missing_cover': true,
      if (f.missingMetadata) 'missing_metadata': true,
    };
  }

  static LibraryFilterSelection _filterFromJson(Map<String, dynamic> json) {
    return LibraryFilterSelection(
      ownershipFilter: json['ownership'] != null
          ? LibraryOwnershipFilter.values.byName(json['ownership'] as String)
          : LibraryOwnershipFilter.all,
      series: json['series'] as String?,
      grade: json['grade'] as String?,
      condition: json['condition'] as String?,
      publisher: json['publisher'] as String?,
      releaseYear: json['release_year'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
      missingCover: json['missing_cover'] as bool? ?? false,
      missingMetadata: json['missing_metadata'] as bool? ?? false,
    );
  }
}
