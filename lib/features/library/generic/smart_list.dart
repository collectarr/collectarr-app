import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/generic/library_filters.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

/// Resolved, UI-facing Smart List for one active kind workspace.
///
/// Persistence lives in [SmartListCriteria]. This class contains only the
/// fields needed by the active page after criteria have been resolved against
/// its kind-owned workspace schema.
class SmartList {
  SmartList({
    required this.id,
    required this.name,
    required this.target,
    required List<String> kinds,
    this.filterSelection = LibraryFilterSelection.none,
    this.quickView,
    List<LibrarySortRule>? sortRules,
    this.searchQuery,
    this.degradedSortTokens = const [],
    this.degradedFieldTokens = const [],
  })  : kinds = List.unmodifiable(kinds),
        sortRules = sortRules == null ? null : List.unmodifiable(sortRules);

  final String id;
  final String name;
  final SmartListCriteriaTarget target;
  final List<String> kinds;
  final LibraryFilterSelection filterSelection;
  final LibraryQuickView? quickView;
  final List<LibrarySortRule>? sortRules;
  final String? searchQuery;
  final List<String> degradedSortTokens;
  final List<String> degradedFieldTokens;

  bool get isDegraded =>
      degradedSortTokens.isNotEmpty || degradedFieldTokens.isNotEmpty;

  List<LibrarySortRule> get effectiveSortRules => sortRules ?? const [];

  String? get sortColumn =>
      effectiveSortRules.isEmpty ? null : effectiveSortRules.first.column;

  bool? get sortAscending =>
      effectiveSortRules.isEmpty ? null : effectiveSortRules.first.ascending;

  bool appliesTo(String kind) => kinds.contains(kind);

  SmartListCriteria toCriteria() {
    final fields = <String, Object?>{
      for (final entry in filterSelection.fieldValues.entries)
        if (entry.value?.trim().isNotEmpty == true)
          entry.key: entry.value == '__missing__'
              ? const SmartListFieldCriterion(
                  operator: SmartListFieldOperator.isEmpty,
                ).toJson()
              : SmartListFieldCriterion(
                  operator: SmartListFieldOperator.equals,
                  value: entry.value!.trim(),
                ).toJson(),
      for (final entry in filterSelection.fieldCriteria.entries)
        entry.key: entry.value.toJson(),
    };
    return SmartListCriteria(
      target: target,
      kinds: kinds,
      search: searchQuery,
      quickView: quickView?.name,
      sorts: [
        for (final rule in effectiveSortRules)
          SmartListSortCriterion(
            field: rule.column,
            ascending: rule.ascending,
          ),
      ],
      expression: {
        if (filterSelection.entriesFilter != LibraryEntryPolicyFilter.all)
          'entries': filterSelection.entriesFilter.name,
        if (filterSelection.trackingStatusFilter !=
            LibraryTrackingStatusFilter.all)
          'tracking_status': filterSelection.trackingStatusFilter.name,
        if (filterSelection.loanStatusFilter != LibraryLoanStatusFilter.all)
          'loan_status': filterSelection.loanStatusFilter.name,
        if (filterSelection.hasActiveDateRange)
          'date_field': filterSelection.dateRangeField.name,
        if (filterSelection.dateFrom != null)
          'date_from': filterSelection.dateFrom!.toIso8601String(),
        if (filterSelection.dateTo != null)
          'date_to': filterSelection.dateTo!.toIso8601String(),
        if (filterSelection.customFieldDefinitionId != null)
          'custom_field_definition_id': filterSelection.customFieldDefinitionId,
        if (filterSelection.customFieldValue != null)
          'custom_field_value': filterSelection.customFieldValue,
        if (fields.isNotEmpty) 'fields': fields,
        if (filterSelection.missingCover) 'missing_cover': true,
        if (filterSelection.missingMetadata) 'missing_metadata': true,
      },
    );
  }
}
