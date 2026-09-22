import 'dart:convert';

import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';

/// A saved filter/sort preset that acts as a "smart list".
class SmartList {
  const SmartList({
    required this.id,
    required this.name,
    this.mediaKind,
    this.entityScope,
    this.filterSelection = LibraryFilterSelection.none,
    this.quickView,
    this.sortRules,
    this.sortColumn,
    this.sortAscending,
    this.searchQuery,
    this.degradedSortTokens = const [],
    this.degradedFieldTokens = const [],
  });

  final String id;
  final String name;

  /// If non-null, this smart list only applies to a specific media kind.
  final String? mediaKind;
  final LibraryEntityScope? entityScope;
  final LibraryFilterSelection filterSelection;
  final LibraryQuickView? quickView;
  final List<LibrarySortRule>? sortRules;
  final String? sortColumn;
  final bool? sortAscending;
  final String? searchQuery;
  final List<String> degradedSortTokens;
  final List<String> degradedFieldTokens;

  bool get isDegraded =>
      degradedSortTokens.isNotEmpty || degradedFieldTokens.isNotEmpty;

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
      'schema_version': 2,
      'name': name,
      if (mediaKind != null) 'media_kind': mediaKind,
      if (entityScope != null) 'entity_scope': entityScope!.apiValue,
      if (searchQuery != null) 'search_query': searchQuery,
      if (quickView != null) 'quick_view': quickView!.name,
      if (effectiveSortRules.isNotEmpty)
        'sort_rules': [
          for (final rule in effectiveSortRules)
            {
              'column': _sortColumnToken(mediaKind, entityScope, rule.column),
              'ascending': rule.ascending,
            },
        ],
      if (sortColumn != null)
        'sort_column': _sortColumnToken(mediaKind, entityScope, sortColumn!),
      if (sortAscending != null) 'sort_ascending': sortAscending,
      'filter': _filterToJson(filterSelection),
    };
  }

  factory SmartList.fromRow(String id, String name, String criteriaJson) {
    final json = jsonDecode(criteriaJson) as Map<String, dynamic>;
    final schemaVersion = (json['schema_version'] as num?)?.toInt() ?? 1;
    final mediaKind = json['media_kind'] as String?;
    final entityScope = _scopeFromValue(json['entity_scope']);
    final decodedSortRules = _sortRulesFromJson(
      json['sort_rules'],
      mediaKind: mediaKind,
      entityScope: entityScope,
    );
    final primarySortColumn = decodedSortRules.rules.isNotEmpty
        ? decodedSortRules.rules.first.column
        : _sortColumnFromToken(
            json['sort_column'],
            mediaKind: mediaKind,
            entityScope: entityScope,
          ).value;
    final degradedSortTokens = <String>[
      ...decodedSortRules.degraded,
      if (_sortColumnFromToken(
            json['sort_column'],
            mediaKind: mediaKind,
            entityScope: entityScope,
          ).degraded &&
          json['sort_column'] != null)
        json['sort_column'].toString(),
    ];
    final filter = _filterFromJson(
      json['filter'] as Map<String, dynamic>? ?? {},
      schemaVersion: schemaVersion,
      mediaKind: mediaKind,
      entityScope: entityScope,
    );
    final primarySortAscending = decodedSortRules.rules.isNotEmpty
        ? decodedSortRules.rules.first.ascending
        : json['sort_ascending'] as bool?;
    return SmartList(
      id: id,
      name: name,
      mediaKind: mediaKind,
      entityScope: entityScope,
      searchQuery: json['search_query'] as String?,
      quickView: _enumByNameOrNull(
        LibraryQuickView.values.asNameMap(),
        json['quick_view'],
      ),
      sortRules: decodedSortRules.rules.isEmpty ? null : decodedSortRules.rules,
      sortColumn: primarySortColumn,
      sortAscending: primarySortAscending,
      filterSelection: filter.selection,
      degradedSortTokens: List.unmodifiable(degradedSortTokens),
      degradedFieldTokens: List.unmodifiable(filter.degraded),
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
      if (f.customFieldValue != null) 'custom_field_value': f.customFieldValue,
      if (f.fieldValues.isNotEmpty) 'fields': f.fieldValues,
      if (f.missingCover) 'missing_cover': true,
      if (f.missingMetadata) 'missing_metadata': true,
    };
  }

  static ({LibraryFilterSelection selection, List<String> degraded})
      _filterFromJson(
    Map<String, dynamic> json, {
    required int schemaVersion,
    required String? mediaKind,
    required LibraryEntityScope? entityScope,
  }) {
    final fieldValues = <String, String?>{};
    final degraded = <String>[];
    final rawFields = json['fields'];
    if (rawFields is Map) {
      for (final entry in rawFields.entries) {
        final value = entry.value?.toString().trim();
        if (value != null && value.isNotEmpty) {
          final token = _normalizeFilterFieldId(entry.key.toString());
          fieldValues[token] = value;
          if (!_isKnownField(token, mediaKind, entityScope)) {
            degraded.add(token);
          }
        }
      }
    }
    if (schemaVersion < 2) {
      for (final key in const [
        'series',
        'location',
        'tag',
        'grade',
        'condition',
        'publisher',
        'release_year',
        'country',
        'language',
      ]) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty) {
          final token = _normalizeFilterFieldId(key);
          fieldValues[token] = value;
          if (!_isKnownField(token, mediaKind, entityScope)) {
            degraded.add(token);
          }
        }
      }
    }
    return (
      selection: LibraryFilterSelection(
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
        fieldValues: fieldValues,
        missingCover: json['missing_cover'] as bool? ?? false,
        missingMetadata: json['missing_metadata'] as bool? ?? false,
      ),
      degraded: List.unmodifiable(degraded.toSet()),
    );
  }

  static String _normalizeFilterFieldId(String id) {
    return id == 'release_year' ? 'year' : id;
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

  static ({List<LibrarySortRule> rules, List<String> degraded})
      _sortRulesFromJson(
    Object? rawValue, {
    required String? mediaKind,
    required LibraryEntityScope? entityScope,
  }) {
    if (rawValue is! List) {
      return (rules: const [], degraded: const []);
    }
    final rules = <LibrarySortRule>[];
    final degraded = <String>[];
    for (final entry in rawValue) {
      if (entry is! Map) {
        continue;
      }
      final decoded = _sortColumnFromToken(
        entry['column'],
        mediaKind: mediaKind,
        entityScope: entityScope,
      );
      final column = decoded.value;
      if (column == null) continue;
      if (decoded.degraded) degraded.add(entry['column'].toString());
      rules.add(
        LibrarySortRule(
          column: column,
          ascending: entry['ascending'] as bool? ?? true,
        ),
      );
    }
    return (
      rules: List.unmodifiable(rules),
      degraded: List.unmodifiable(degraded),
    );
  }

  static String _sortColumnToken(
    String? mediaKind,
    LibraryEntityScope? entityScope,
    String column,
  ) {
    final kind = mediaKind?.trim().toLowerCase();
    final stableColumn = _stableToken(column);
    if (stableColumn.contains('.')) {
      final parts = stableColumn.split('.');
      if (parts.length == 2 && kind != null && entityScope != null) {
        return '$kind.${entityScope.apiValue}.${parts.last}';
      }
      return stableColumn;
    }
    if (kind == null || kind.isEmpty) return stableColumn;
    return entityScope == null
        ? '$kind.$stableColumn'
        : '$kind.${entityScope.apiValue}.$stableColumn';
  }

  static String? _sortColumnTokenFromJson(Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) {
      return null;
    }
    return _stableToken(rawValue);
  }

  static ({String? value, bool degraded}) _sortColumnFromToken(
    Object? rawValue, {
    required String? mediaKind,
    required LibraryEntityScope? entityScope,
  }) {
    final candidate = _sortColumnTokenFromJson(rawValue);
    if (candidate == null) return (value: null, degraded: false);
    final kind = catalogMediaKindFromValue(mediaKind);
    if (kind.isUnknown) return (value: candidate, degraded: true);
    final parts = candidate.split('.');
    final lookup = switch (parts.length) {
      1 => '${kind.apiValue}.${parts.single}',
      2 when parts.first == kind.apiValue => candidate,
      3 when parts.first == kind.apiValue =>
        '${kind.apiValue}.${parts.sublist(2).join('.')}',
      _ => candidate,
    };
    if (parts.length == 3 &&
        entityScope != null &&
        parts[1] != entityScope.apiValue) {
      return (value: candidate, degraded: true);
    }
    if (parts.length >= 2 && parts.first != kind.apiValue) {
      return (value: candidate, degraded: true);
    }
    final registry = libraryKindWorkspaceForKind(kind).fieldsForScope(
      entityScope ?? LibraryEntityScope.work,
    );
    final definition =
        registry.findSortDefinition(registry.decodeSortId(lookup));
    return definition == null
        ? (value: candidate, degraded: true)
        : (value: definition.id.value, degraded: false);
  }

  static LibraryEntityScope? _scopeFromValue(Object? value) {
    if (value is! String) return null;
    for (final scope in LibraryEntityScope.values) {
      if (scope.apiValue == value.trim().toLowerCase()) return scope;
    }
    return null;
  }

  static bool _isKnownField(
    String token,
    String? mediaKind,
    LibraryEntityScope? entityScope,
  ) {
    final kind = catalogMediaKindFromValue(mediaKind);
    if (kind.isUnknown) return false;
    final registry = libraryKindWorkspaceForKind(kind).fieldsForScope(
      entityScope ?? LibraryEntityScope.work,
    );
    final normalized = _stableToken(token);
    return registry.fields.any((field) => field.id.value == normalized) ||
        registry.columns.any((column) => column.id.value == normalized);
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
