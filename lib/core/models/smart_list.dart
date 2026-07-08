import 'dart:convert';

import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

/// A saved filter/sort preset that acts as a "smart list".
class SmartList {
  const SmartList({
    required this.id,
    required this.name,
    this.mediaKind,
    this.filterSelection = LibraryFilterSelection.none,
    this.quickView,
    this.sortRules,
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
  final List<LibrarySortRule>? sortRules;
  final LibrarySortColumn? sortColumn;
  final bool? sortAscending;
  final String? searchQuery;

  List<LibrarySortRule> get effectiveSortRules {
    final configuredRules = sortRules;
    if (configuredRules != null && configuredRules.isNotEmpty) {
      return configuredRules;
    }
    if (sortColumn == null) {
      return const [];
    }
    return [
      LibrarySortRule(
        column: sortColumn!,
        ascending: sortAscending ?? true,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    final effectiveSortRules = this.effectiveSortRules;
    return {
      'name': name,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (searchQuery != null) 'search_query': searchQuery,
      if (quickView != null) 'quick_view': quickView!.name,
      if (effectiveSortRules.isNotEmpty)
        'sort_rules': [
          for (final rule in effectiveSortRules)
            {
              'column': _sortColumnToken(mediaKind, rule.column),
              'ascending': rule.ascending,
            },
        ],
      if (sortColumn != null)
        'sort_column': _sortColumnToken(mediaKind, sortColumn!),
      if (sortAscending != null) 'sort_ascending': sortAscending,
      'filter': _filterToJson(filterSelection),
    };
  }

  factory SmartList.fromRow(String id, String name, String criteriaJson) {
    final json = jsonDecode(criteriaJson) as Map<String, dynamic>;
    final decodedSortRules = _sortRulesFromJson(json['sort_rules']);
    final primarySortColumn = decodedSortRules.isNotEmpty
        ? decodedSortRules.first.column
        : _sortColumnFromToken(json['sort_column']);
    final primarySortAscending = decodedSortRules.isNotEmpty
        ? decodedSortRules.first.ascending
        : json['sort_ascending'] as bool?;
    return SmartList(
      id: id,
      name: name,
      mediaKind: json['media_kind'] as String?,
      searchQuery: json['search_query'] as String?,
      quickView: _enumByNameOrNull(
        LibraryQuickView.values.asNameMap(),
        json['quick_view'],
      ),
      sortRules: decodedSortRules.isEmpty ? null : decodedSortRules,
      sortColumn: primarySortColumn,
      sortAscending: primarySortAscending,
      filterSelection: _filterFromJson(
          json['filter'] as Map<String, dynamic>? ?? {}),
    );
  }

  static Map<String, dynamic> _filterToJson(LibraryFilterSelection f) {
    return {
      if (f.ownershipFilter != LibraryOwnershipFilter.all)
        'ownership': f.ownershipFilter.name,
      if (f.trackingStatusFilter != LibraryTrackingStatusFilter.all)
        'tracking_status': f.trackingStatusFilter.name,
      if (f.loanStatusFilter != LibraryLoanStatusFilter.all)
        'loan_status': f.loanStatusFilter.name,
      if (f.hasActiveDateRange) 'date_field': f.dateRangeField.name,
      if (f.dateFrom != null) 'date_from': f.dateFrom!.toIso8601String(),
      if (f.dateTo != null) 'date_to': f.dateTo!.toIso8601String(),
      if (f.customFieldDefinitionId != null)
        'custom_field_definition_id': f.customFieldDefinitionId,
      if (f.customFieldValue != null)
        'custom_field_value': f.customFieldValue,
      if (f.series != null) 'series': f.series,
      if (f.location != null) 'location': f.location,
      if (f.tag != null) 'tag': f.tag,
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
      ownershipFilter: _enumByNameOrNull(
            LibraryOwnershipFilter.values.asNameMap(),
            json['ownership'],
          ) ??
          LibraryOwnershipFilter.all,
      trackingStatusFilter: _enumByNameOrNull(
            LibraryTrackingStatusFilter.values.asNameMap(),
            json['tracking_status'],
          ) ??
          LibraryTrackingStatusFilter.all,
      loanStatusFilter: _enumByNameOrNull(
            LibraryLoanStatusFilter.values.asNameMap(),
            json['loan_status'],
          ) ??
          LibraryLoanStatusFilter.all,
      dateRangeField: _enumByNameOrNull(
            LibraryDateRangeField.values.asNameMap(),
            json['date_field'],
          ) ??
          LibraryDateRangeField.updated,
      dateFrom: _dateFromJson(json['date_from']),
      dateTo: _dateFromJson(json['date_to']),
      customFieldDefinitionId: json['custom_field_definition_id'] as String?,
      customFieldValue: json['custom_field_value'] as String?,
      series: json['series'] as String?,
      location: json['location'] as String?,
      tag: json['tag'] as String?,
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

  static T? _enumByNameOrNull<T>(Map<String, T> values, Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) {
      return null;
    }
    return values[rawValue];
  }

  static DateTime? _dateFromJson(Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawValue);
  }

  static List<LibrarySortRule> _sortRulesFromJson(Object? rawValue) {
    if (rawValue is! List) {
      return const [];
    }
    final rules = <LibrarySortRule>[];
    for (final entry in rawValue) {
      if (entry is! Map) {
        continue;
      }
      final column = _sortColumnFromToken(entry['column']);
      if (column == null) {
        continue;
      }
      rules.add(
        LibrarySortRule(
          column: column,
          ascending: entry['ascending'] as bool? ?? true,
        ),
      );
    }
    return rules;
  }

  static String _sortColumnToken(String? mediaKind, LibrarySortColumn column) {
    final kind = mediaKind?.trim().toLowerCase();
    final stableColumn = _stableToken(column.name);
    return kind == null || kind.isEmpty ? stableColumn : '$kind.$stableColumn';
  }

  static String? _sortColumnTokenFromJson(Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) {
      return null;
    }
    return _stableToken(rawValue.split('.').last);
  }

  static LibrarySortColumn? _sortColumnFromToken(Object? rawValue) {
    final candidate = _sortColumnTokenFromJson(rawValue);
    if (candidate == null) {
      return null;
    }
    for (final column in LibrarySortColumn.values) {
      if (_stableToken(column.name) == candidate) {
        return column;
      }
    }
    return null;
  }

  static String _stableToken(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
  }
}
