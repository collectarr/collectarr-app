import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/smart_list.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';

/// Resolves persistence-only Smart List criteria against a kind workspace.
class SmartListResolver {
  const SmartListResolver._();

  static SmartList resolve({
    required String id,
    required String name,
    required SmartListCriteria criteria,
    required CatalogMediaKind kind,
  }) {
    if (!criteria.kinds.contains(kind.apiValue)) {
      throw ArgumentError('Smart List does not include ${kind.apiValue}.');
    }
    final target = criteria.target;
    final workspace = libraryKindWorkspaceForKind(kind);
    final registry = target == SmartListCriteriaTarget.catalog
        ? workspace.fields
        : workspace.libraryEntryFields;
    final sorts = <LibrarySortRule>[];
    final degradedSortTokens = <String>[];
    for (final rule in criteria.sorts) {
      final result = _resolveSortField(rule.field, kind, registry);
      if (result.degraded) degradedSortTokens.add(rule.field);
      if (result.value != null) {
        sorts.add(LibrarySortRule(
          column: result.value!,
          ascending: rule.ascending,
        ));
      }
    }
    final filter = _resolveExpression(
      criteria.expression,
      kind,
      target,
      registry,
    );
    return SmartList(
      id: id,
      name: name,
      target: target,
      kinds: criteria.kinds,
      filterSelection: filter.selection,
      quickView: _quickViewFromName(criteria.quickView),
      sortRules: sorts.isEmpty ? null : sorts,
      searchQuery: criteria.search,
      degradedSortTokens: List.unmodifiable(degradedSortTokens),
      degradedFieldTokens: List.unmodifiable(filter.degraded),
    );
  }

  static ({String? value, bool degraded}) _resolveSortField(
    String raw,
    CatalogMediaKind activeKind,
    LibraryFieldRegistry<LibraryWorkspaceDto> registry,
  ) {
    if (activeKind.isUnknown) return (value: raw, degraded: true);
    final normalized = _stableToken(raw);
    final parts = normalized.split('.');
    var candidate = normalized;
    if (parts.length >= 2 &&
        !catalogMediaKindFromValue(parts.first).isUnknown) {
      if (parts.first != activeKind.apiValue) {
        return (value: null, degraded: true);
      }
      candidate = parts.skip(1).join('.');
    }
    final resolved = '${activeKind.apiValue}.$candidate';
    final definition = registry.findSortDefinition(
      registry.decodeSortId(resolved),
    );
    if (definition == null) {
      final structural = candidate.split('.').last;
      return (value: structural, degraded: true);
    }
    return (
      value: definition.id.value.split('.').last,
      degraded: false,
    );
  }

  static ({LibraryFilterSelection selection, List<String> degraded})
      _resolveExpression(
    Map<String, Object?> expression,
    CatalogMediaKind kind,
    SmartListCriteriaTarget target,
    LibraryFieldRegistry<LibraryWorkspaceDto> registry,
  ) {
    final fieldCriteria = <String, SmartListFieldCriterion>{};
    final degraded = <String>[];
    final rawFields = expression['fields'];
    if (rawFields is Map) {
      for (final entry in rawFields.entries) {
        if (entry.key is! String) continue;
        final criterion = SmartListFieldCriterion.fromJson(entry.value);
        final token = _fieldTokenForKind(
          entry.key as String,
          kind,
          registry,
        );
        fieldCriteria[token] = criterion;
        if (!_isKnownField(token, kind, registry) ||
            !_supportsCriterion(token, criterion, kind, target, registry)) {
          degraded.add(token);
        }
      }
    }
    return (
      selection: LibraryFilterSelection(
        entriesFilter: _enumByNameOrNull(
              LibraryEntryPolicyFilter.values.asNameMap(),
              expression['entries'],
            ) ??
            LibraryEntryPolicyFilter.all,
        trackingStatusFilter: _enumByNameOrNull(
              LibraryTrackingStatusFilter.values.asNameMap(),
              expression['tracking_status'],
            ) ??
            LibraryTrackingStatusFilter.all,
        loanStatusFilter: _enumByNameOrNull(
              LibraryLoanStatusFilter.values.asNameMap(),
              expression['loan_status'],
            ) ??
            LibraryLoanStatusFilter.all,
        dateRangeField: _enumByNameOrNull(
              LibraryDateRangeField.values.asNameMap(),
              expression['date_field'],
            ) ??
            LibraryDateRangeField.updated,
        dateFrom: _dateFromJson(expression['date_from']),
        dateTo: _dateFromJson(expression['date_to']),
        customFieldDefinitionId:
            expression['custom_field_definition_id'] as String?,
        customFieldValue: expression['custom_field_value'] as String?,
        fieldCriteria: Map.unmodifiable(fieldCriteria),
        missingCover: expression['missing_cover'] as bool? ?? false,
        missingMetadata: expression['missing_metadata'] as bool? ?? false,
      ),
      degraded: List.unmodifiable(degraded.toSet()),
    );
  }

  static bool _isKnownField(
    String token,
    CatalogMediaKind kind,
    LibraryFieldRegistry<LibraryWorkspaceDto> registry,
  ) {
    return registry.fields.any((field) => field.id.value == token) ||
        registry.columns.any((column) => column.id.value == token) ||
        libraryPresentationForKind(kind)
            .filterDefinitions
            .any((filter) => filter.metadata.id == token);
  }

  static bool _supportsCriterion(
    String token,
    SmartListFieldCriterion criterion,
    CatalogMediaKind kind,
    SmartListCriteriaTarget target,
    LibraryFieldRegistry<LibraryWorkspaceDto> registry,
  ) {
    final field = registry.fields.where((field) => field.id.value == token);
    final filter = libraryPresentationForKind(kind)
        .filterDefinitions
        .where((filter) => filter.metadata.id == token);
    final metadata = field.isNotEmpty
        ? field.first.metadata
        : (filter.isEmpty ? null : filter.first.metadata);
    if (target == SmartListCriteriaTarget.catalog &&
        metadata?.source == LibraryFieldSource.libraryEntry) {
      return false;
    }
    if (metadata != null && !metadata.filterable) return false;
    if (criterion.operator == SmartListFieldOperator.contains &&
        metadata != null &&
        metadata.valueType != LibraryFieldValueType.text) {
      return false;
    }
    if (metadata != null &&
        criterion.operator != SmartListFieldOperator.isEmpty) {
      final value = criterion.value;
      if (metadata.valueType == LibraryFieldValueType.boolean &&
          value != 'true' &&
          value != 'false') {
        return false;
      }
      if (metadata.valueType == LibraryFieldValueType.number &&
          (value == null || num.tryParse(value) == null)) {
        return false;
      }
    }
    return metadata != null;
  }

  static String _fieldTokenForKind(
    String raw,
    CatalogMediaKind kind,
    LibraryFieldRegistry<LibraryWorkspaceDto> registry,
  ) {
    final normalized = _stableToken(raw);
    if (_isKnownField(normalized, kind, registry)) return normalized;
    for (final definition
        in libraryPresentationForKind(kind).filterDefinitions) {
      if (definition.id == normalized) return definition.metadata.id;
    }
    final parts = normalized.split('.');
    final hasKindPrefix =
        parts.length >= 2 && !catalogMediaKindFromValue(parts.first).isUnknown;
    if (hasKindPrefix && parts.first != kind.apiValue) return normalized;
    if (hasKindPrefix) return normalized;
    return '${kind.apiValue}.$normalized';
  }

  static T? _enumByNameOrNull<T>(Map<String, T> values, Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) return null;
    return values[rawValue];
  }

  static LibraryQuickView? _quickViewFromName(Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) return null;
    return LibraryQuickView.values.asNameMap()[rawValue];
  }

  static DateTime? _dateFromJson(Object? rawValue) {
    if (rawValue is! String || rawValue.isEmpty) return null;
    return DateTime.tryParse(rawValue);
  }

  static String _stableToken(String value) => value
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]}_${match[2]}',
      )
      .toLowerCase();
}
