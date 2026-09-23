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
    final json = _criteriaObject(criteriaJson);
    final schemaVersion = _schemaVersion(json);
    _validateCriteria(json, schemaVersion);
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
      json['filter'] == null
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(json['filter'] as Map),
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

  static Map<String, dynamic> _criteriaObject(String criteriaJson) {
    final decoded = jsonDecode(criteriaJson);
    if (decoded is! Map) {
      throw const FormatException('SmartList criteria must be a JSON object.');
    }
    final result = <String, dynamic>{};
    for (final entry in decoded.entries) {
      if (entry.key is! String) {
        throw const FormatException(
          'SmartList criteria object keys must be strings.',
        );
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  static int _schemaVersion(Map<String, dynamic> json) {
    final rawVersion = json['schema_version'];
    if (rawVersion == null) return 1;
    if (rawVersion is! int) {
      throw const FormatException(
        'SmartList schema_version must be an integer.',
      );
    }
    if (rawVersion != 1 && rawVersion != 2) {
      throw FormatException(
        'Unsupported SmartList schema_version: $rawVersion.',
      );
    }
    return rawVersion;
  }

  static void _validateCriteria(Map<String, dynamic> json, int schemaVersion) {
    _validateOptionalType(json, 'media_kind', (value) => value is String);
    _validateOptionalType(json, 'entity_scope', (value) => value is String);
    _validateOptionalType(json, 'search_query', (value) => value is String);
    _validateOptionalType(json, 'quick_view', (value) => value is String);
    _validateOptionalType(json, 'sort_column', (value) => value is String);
    _validateOptionalType(json, 'sort_ascending', (value) => value is bool);

    final rawScope = json['entity_scope'];
    if (rawScope != null && _scopeFromValue(rawScope) == null) {
      throw FormatException('Unsupported SmartList entity_scope: $rawScope.');
    }

    final rawSortRules = json['sort_rules'];
    if (rawSortRules != null) {
      if (rawSortRules is! List) {
        throw const FormatException('SmartList sort_rules must be a list.');
      }
      for (var index = 0; index < rawSortRules.length; index++) {
        final rawRule = rawSortRules[index];
        if (rawRule is! Map) {
          throw FormatException(
              'SmartList sort_rules[$index] must be an object.');
        }
        final rule = Map<String, dynamic>.from(rawRule);
        if (rule['column'] is! String ||
            (rule['column'] as String).trim().isEmpty) {
          throw FormatException(
            'SmartList sort_rules[$index].column must be a non-empty string.',
          );
        }
        _validateOptionalType(
          rule,
          'ascending',
          (value) => value is bool,
          path: 'sort_rules[$index].ascending',
        );
      }
    }

    final rawFilter = json['filter'];
    if (rawFilter != null) {
      if (rawFilter is! Map) {
        throw const FormatException('SmartList filter must be an object.');
      }
      final filter = Map<String, dynamic>.from(rawFilter);
      for (final key in const [
        'ownership',
        'tracking_status',
        'loan_status',
        'date_field',
        'custom_field_definition_id',
        'custom_field_value',
      ]) {
        _validateOptionalType(filter, key, (value) => value is String);
      }
      for (final key in const ['date_from', 'date_to']) {
        final value = filter[key];
        if (value != null &&
            (value is! String ||
                (value.isNotEmpty && DateTime.tryParse(value) == null))) {
          throw FormatException('SmartList filter.$key must be a valid date.');
        }
      }
      for (final key in const ['missing_cover', 'missing_metadata']) {
        _validateOptionalType(filter, key, (value) => value is bool);
      }
      final rawFields = filter['fields'];
      if (rawFields != null) {
        if (rawFields is! Map) {
          throw const FormatException(
              'SmartList filter.fields must be an object.');
        }
        for (final entry in rawFields.entries) {
          if (entry.key is! String ||
              (entry.value != null && entry.value is! String)) {
            throw const FormatException(
              'SmartList filter.fields must map strings to strings or null.',
            );
          }
        }
      }
      if (schemaVersion == 1) {
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
          _validateOptionalType(filter, key, (value) => value is String);
        }
      }
    }
  }

  static void _validateOptionalType(
    Map<String, dynamic> object,
    String key,
    bool Function(Object? value) predicate, {
    String? path,
  }) {
    final value = object[key];
    if (value != null && !predicate(value)) {
      throw FormatException('SmartList ${path ?? key} has an invalid type.');
    }
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
      2 when parts.first == kind.apiValue => '${kind.apiValue}.${parts.last}',
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
    if (definition == null) {
      final structuralValue =
          parts.length >= 2 && parts.first == kind.apiValue && parts.length <= 3
              ? parts.last
              : candidate;
      return (value: structuralValue, degraded: true);
    }
    // SmartList keeps the public rule vocabulary structural (for example
    // `title` or `updated_at`). The kind-qualified token is only the persisted
    // identity used to resolve the definition without collisions.
    return (value: definition.id.value.split('.').last, degraded: false);
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
