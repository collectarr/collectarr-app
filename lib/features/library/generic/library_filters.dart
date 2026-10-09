import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:flutter/foundation.dart';

/// Shared entry policy criteria used by Smart Lists and library projections.
enum LibraryEntryPolicyFilter { all, entry, wishlist, forSale, onOrder }

String libraryEntryPolicyFilterLabel(
  LibraryEntryPolicyFilter filter, {
  LibraryKindRegistration? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(
      type: type, mediaType: catalogMediaKindFromValue(mediaType));
  return switch (filter) {
    LibraryEntryPolicyFilter.all => labels.entriesAll,
    LibraryEntryPolicyFilter.entry => labels.entriesEntry,
    LibraryEntryPolicyFilter.wishlist => labels.entriesWishlist,
    LibraryEntryPolicyFilter.forSale => labels.entriesForSale,
    LibraryEntryPolicyFilter.onOrder => labels.entriesOnOrder,
  };
}

enum LibraryTrackingStatusFilter {
  all,
  notTracked,
  planned,
  inProgress,
  completed,
  paused,
  dropped,
  repeating,
}

String libraryTrackingStatusFilterLabel(
  LibraryTrackingStatusFilter filter, {
  LibraryKindRegistration? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(
      type: type, mediaType: catalogMediaKindFromValue(mediaType));
  return switch (filter) {
    LibraryTrackingStatusFilter.all => labels.trackingAny,
    LibraryTrackingStatusFilter.notTracked => labels.trackingNotTracked,
    LibraryTrackingStatusFilter.planned => MediaTrackingStatus.planned.label,
    LibraryTrackingStatusFilter.inProgress =>
      MediaTrackingStatus.inProgress.label,
    LibraryTrackingStatusFilter.completed =>
      MediaTrackingStatus.completed.label,
    LibraryTrackingStatusFilter.paused => MediaTrackingStatus.paused.label,
    LibraryTrackingStatusFilter.dropped => MediaTrackingStatus.dropped.label,
    LibraryTrackingStatusFilter.repeating =>
      MediaTrackingStatus.repeating.label,
  };
}

bool libraryTrackingStatusMatchesFilter(
  MediaTrackingStatus status,
  LibraryTrackingStatusFilter filter,
) {
  return switch (filter) {
    LibraryTrackingStatusFilter.all => true,
    LibraryTrackingStatusFilter.notTracked =>
      status == MediaTrackingStatus.none,
    LibraryTrackingStatusFilter.planned =>
      status == MediaTrackingStatus.planned,
    LibraryTrackingStatusFilter.inProgress =>
      status == MediaTrackingStatus.inProgress,
    LibraryTrackingStatusFilter.completed =>
      status == MediaTrackingStatus.completed,
    LibraryTrackingStatusFilter.paused => status == MediaTrackingStatus.paused,
    LibraryTrackingStatusFilter.dropped =>
      status == MediaTrackingStatus.dropped,
    LibraryTrackingStatusFilter.repeating =>
      status == MediaTrackingStatus.repeating,
  };
}

enum LibraryLoanStatusFilter { all, onLoan, available }

String libraryLoanStatusFilterLabel(
  LibraryLoanStatusFilter filter, {
  LibraryKindRegistration? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(
      type: type, mediaType: catalogMediaKindFromValue(mediaType));
  return switch (filter) {
    LibraryLoanStatusFilter.all => labels.loanAny,
    LibraryLoanStatusFilter.onLoan => labels.loanOnLoan,
    LibraryLoanStatusFilter.available => labels.loanAvailable,
  };
}

enum LibraryDateRangeField { updated, purchased, started, finished }

String libraryDateRangeFieldLabel(
  LibraryDateRangeField field, {
  LibraryKindRegistration? type,
  Object? mediaType,
}) {
  final labels = _libraryFilterOptionLabels(
      type: type, mediaType: catalogMediaKindFromValue(mediaType));
  return switch (field) {
    LibraryDateRangeField.updated => labels.dateUpdated,
    LibraryDateRangeField.purchased => labels.datePurchased,
    LibraryDateRangeField.started => labels.dateStarted,
    LibraryDateRangeField.finished => labels.dateFinished,
  };
}

LibraryFilterOptionLabels _libraryFilterOptionLabels({
  LibraryKindRegistration? type,
  CatalogMediaKind? mediaType,
}) {
  return (type == null
          ? null
          : libraryPresentationForKind(type.kind).filterOptionLabels) ??
      (mediaType != null
          ? libraryPresentationForKind(mediaType).filterOptionLabels
          : null) ??
      const LibraryFilterOptionLabels();
}

class LibraryFilterSelection {
  const LibraryFilterSelection({
    this.entriesFilter = LibraryEntryPolicyFilter.all,
    this.trackingStatusFilter = LibraryTrackingStatusFilter.all,
    this.loanStatusFilter = LibraryLoanStatusFilter.all,
    this.dateRangeField = LibraryDateRangeField.updated,
    this.dateFrom,
    this.dateTo,
    this.customFieldDefinitionId,
    this.customFieldValue,
    this.fieldValues = const {},
    this.fieldCriteria = const {},
    this.missingCover = false,
    this.missingMetadata = false,
  });

  static const none = LibraryFilterSelection();

  final LibraryEntryPolicyFilter entriesFilter;
  final LibraryTrackingStatusFilter trackingStatusFilter;
  final LibraryLoanStatusFilter loanStatusFilter;
  final LibraryDateRangeField dateRangeField;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? customFieldDefinitionId;
  final String? customFieldValue;
  final Map<String, String?> fieldValues;
  final Map<String, SmartListFieldCriterion> fieldCriteria;
  final bool missingCover;
  final bool missingMetadata;

  String? fieldValue(String id) => fieldValues[id];

  bool get hasActiveDateRange => dateFrom != null || dateTo != null;

  bool get hasActiveFilters {
    return entriesFilter != LibraryEntryPolicyFilter.all ||
        trackingStatusFilter != LibraryTrackingStatusFilter.all ||
        loanStatusFilter != LibraryLoanStatusFilter.all ||
        hasActiveDateRange ||
        customFieldDefinitionId != null ||
        customFieldValue != null ||
        fieldValues.values.any((value) => value != null) ||
        fieldCriteria.isNotEmpty ||
        missingCover ||
        missingMetadata;
  }

  int get activeFilterCount {
    var count = 0;
    if (entriesFilter != LibraryEntryPolicyFilter.all) count++;
    if (trackingStatusFilter != LibraryTrackingStatusFilter.all) count++;
    if (loanStatusFilter != LibraryLoanStatusFilter.all) count++;
    if (hasActiveDateRange) count++;
    if (customFieldDefinitionId != null || customFieldValue != null) count++;
    count += fieldValues.values.where((value) => value != null).length;
    count += fieldCriteria.length;
    if (missingCover) count++;
    if (missingMetadata) count++;
    return count;
  }

  LibraryFilterSelection copyWith({
    LibraryEntryPolicyFilter? entriesFilter,
    LibraryTrackingStatusFilter? trackingStatusFilter,
    LibraryLoanStatusFilter? loanStatusFilter,
    LibraryDateRangeField? dateRangeField,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    String? customFieldDefinitionId,
    bool clearCustomFieldDefinitionId = false,
    String? customFieldValue,
    bool clearCustomFieldValue = false,
    Map<String, String?>? fieldValues,
    Map<String, SmartListFieldCriterion>? fieldCriteria,
    bool? missingCover,
    bool? missingMetadata,
  }) {
    return LibraryFilterSelection(
      entriesFilter: entriesFilter ?? this.entriesFilter,
      trackingStatusFilter: trackingStatusFilter ?? this.trackingStatusFilter,
      loanStatusFilter: loanStatusFilter ?? this.loanStatusFilter,
      dateRangeField: dateRangeField ?? this.dateRangeField,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      customFieldDefinitionId: clearCustomFieldDefinitionId
          ? null
          : (customFieldDefinitionId ?? this.customFieldDefinitionId),
      customFieldValue: clearCustomFieldValue
          ? null
          : (customFieldValue ?? this.customFieldValue),
      fieldValues: fieldValues ?? this.fieldValues,
      fieldCriteria: fieldCriteria ?? this.fieldCriteria,
      missingCover: missingCover ?? this.missingCover,
      missingMetadata: missingMetadata ?? this.missingMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LibraryFilterSelection &&
            other.entriesFilter == entriesFilter &&
            other.trackingStatusFilter == trackingStatusFilter &&
            other.loanStatusFilter == loanStatusFilter &&
            other.dateRangeField == dateRangeField &&
            other.dateFrom == dateFrom &&
            other.dateTo == dateTo &&
            other.customFieldDefinitionId == customFieldDefinitionId &&
            other.customFieldValue == customFieldValue &&
            mapEquals(other.fieldValues, fieldValues) &&
            mapEquals(other.fieldCriteria, fieldCriteria) &&
            other.missingCover == missingCover &&
            other.missingMetadata == missingMetadata;
  }

  @override
  int get hashCode => Object.hash(
        entriesFilter,
        trackingStatusFilter,
        loanStatusFilter,
        dateRangeField,
        dateFrom,
        dateTo,
        customFieldDefinitionId,
        customFieldValue,
        _fieldValuesHash(fieldValues),
        _fieldCriteriaHash(fieldCriteria),
        missingCover,
        missingMetadata,
      );
}

int _fieldValuesHash(Map<String, String?> values) {
  final keys = values.keys.toList()..sort();
  return Object.hashAll([
    for (final key in keys) Object.hash(key, values[key]),
  ]);
}

int _fieldCriteriaHash(Map<String, SmartListFieldCriterion> criteria) {
  final keys = criteria.keys.toList()..sort();
  return Object.hashAll(
      [for (final key in keys) Object.hash(key, criteria[key])]);
}

LibraryFilterSelection sanitizeLibraryFilterSelectionForType(
  LibraryFilterSelection selection,
  LibraryKindRegistration type,
) {
  final supportedFields = {
    for (final definition
        in libraryPresentationForKind(type.kind).filterDefinitions)
      definition.id,
  };
  final editCap = libraryEditPresentationForKind(type.kind);
  final collectionValues = editCap.collectionValueOptions;
  final hasCollectionValues =
      collectionValues.isNotEmpty && supportedFields.contains('grade');
  final fieldValues = <String, String?>{};
  for (final entry in selection.fieldValues.entries) {
    if (!supportedFields.contains(entry.key)) {
      continue;
    }
    if (entry.key == 'grade' && !hasCollectionValues) {
      continue;
    }
    fieldValues[entry.key] = entry.value;
  }

  return LibraryFilterSelection(
    entriesFilter: selection.entriesFilter,
    trackingStatusFilter: selection.trackingStatusFilter,
    loanStatusFilter: selection.loanStatusFilter,
    dateRangeField: selection.dateRangeField,
    dateFrom: selection.dateFrom,
    dateTo: selection.dateTo,
    customFieldDefinitionId: selection.customFieldDefinitionId,
    customFieldValue: selection.customFieldValue,
    fieldValues: fieldValues,
    fieldCriteria: selection.fieldCriteria,
    missingCover: selection.missingCover,
    missingMetadata: selection.missingMetadata,
  );
}

/// Available filter values extracted from a set of library items.
bool libraryFilterMatches(
  LibraryProjectionView item,
  LibraryFilterSelection filters, {
  Iterable<LibraryFilterDefinition<Object?>> filterDefinitions = const [],
  LibraryFieldRegistry<LibraryWorkspaceDto>? fieldRegistry,
}) {
  final source = item.source;
  if (filters.entriesFilter == LibraryEntryPolicyFilter.entry &&
      !source.isEntry) {
    return false;
  }
  if (filters.entriesFilter == LibraryEntryPolicyFilter.wishlist &&
      !source.isWishlisted) {
    return false;
  }
  final location = filters.fieldValue('location');
  if (location != null && item.source.locationPath?.trim() != location) {
    return false;
  }
  for (final definition in filterDefinitions) {
    if (definition.id == 'location') {
      continue;
    }
    final selectedValue = filters.fieldValue(definition.id);
    if (selectedValue != null && !definition.matchesItem(item, selectedValue)) {
      return false;
    }
  }
  if (filters.fieldCriteria.isNotEmpty && fieldRegistry != null) {
    final context = LibraryProjectionContext<LibraryWorkspaceDto>(
      item: item.source.item,
      personal: item.source.personal,
      dto: item.dto,
    );
    for (final entry in filters.fieldCriteria.entries) {
      final candidates = <Object?>[];
      for (final candidate in fieldRegistry.fields) {
        if (candidate.id.value == entry.key) {
          if (candidate.filterable &&
              _fieldSourceAllowedForTarget(candidate.metadata, item.target)) {
            candidates.add(candidate.getValue(context));
          }
          break;
        }
      }
      for (final filter in filterDefinitions) {
        if (filter.metadata.id != entry.key ||
            !_fieldSourceAllowedForTarget(filter.metadata, item.target)) {
          continue;
        }
        candidates.add(
          filter.id == 'location'
              ? item.source.locationPath
              : filter.value?.call(item),
        );
      }
      if (candidates.isEmpty) continue;
      if (!_matchesSmartListCriterion(
        candidates,
        entry.value,
      )) {
        return false;
      }
    }
  }
  if (filters.missingCover && item.dto.imageUrl != null) return false;
  if (filters.missingMetadata && item.source.kindPresentationData != null) {
    return false;
  }
  return true;
}

bool _fieldSourceAllowedForTarget(
  LibraryKindFieldMetadata metadata,
  LibraryTargetRef target,
) =>
    target is! CatalogTargetRef ||
    metadata.source != LibraryFieldSource.libraryEntry;

bool librarySmartListCriterionMatches(
  Object? candidate,
  SmartListFieldCriterion criterion,
) =>
    _matchesSmartListCriterion([candidate], criterion);

bool _matchesSmartListCriterion(
  List<Object?> candidates,
  SmartListFieldCriterion criterion,
) {
  final values = <Object?>[];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    if (candidate is Iterable && candidate is! String) {
      values.addAll(candidate.cast<Object?>());
    } else {
      values.add(candidate);
    }
  }
  final expected = criterion.value?.trim().toLowerCase();
  bool equals(Object? value) {
    if (expected == null) return false;
    if (value is num) {
      final numericExpected = num.tryParse(expected);
      if (numericExpected != null) return value == numericExpected;
    }
    return _smartListValueText(value).toLowerCase() == expected;
  }

  return switch (criterion.operator) {
    SmartListFieldOperator.equals => values.any(equals),
    SmartListFieldOperator.notEquals => !values.any(equals),
    SmartListFieldOperator.contains => values
        .whereType<String>()
        .any((value) => value.toLowerCase().contains(expected ?? '')),
    SmartListFieldOperator.isEmpty => candidates.every((candidate) {
        if (candidate == null) return true;
        if (candidate is Iterable && candidate is! String) {
          return candidate.isEmpty;
        }
        return candidate is String && candidate.trim().isEmpty;
      }),
  };
}

String _smartListValueText(Object? value) {
  if (value is DateTime) return value.toIso8601String().split('T').first;
  return value?.toString().trim() ?? '';
}
