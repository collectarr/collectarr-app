import 'dart:convert';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

class LibraryRouteState {
  const LibraryRouteState({
    this.kind,
    this.searchQuery,
    this.groupMode,
    this.folderPreset,
    this.selectedBucket,
    this.linkedMetadataValue,
    this.selectedLetter,
    this.collectionStatusScope = LibraryCollectionStatusScope.all,
    this.bucketCompletionScope = LibraryBucketCompletionScope.all,
    this.quickView,
    this.filterSelection = LibraryFilterSelection.none,
    this.sortRules,
    this.isSidebarVisible,
  });

  static const kindKey = 'kind';
  static const searchKey = 'q';
  static const folderKey = 'folder';
  static const filterValueKey = 'filterValue';
  static const linkedValueKey = 'linkedValue';
  static const letterKey = 'letter';
  static const scopeKey = 'scope';
  static const bucketScopeKey = 'bucketScope';
  static const quickKey = 'quick';
  static const filtersKey = 'filters';
  static const sortKey = 'sort';
  static const foldersKey = 'folders';

  final String? kind;
  final String? searchQuery;
  final String? groupMode;
  final LibraryFolderPreset? folderPreset;
  final String? selectedBucket;
  final String? linkedMetadataValue;
  final String? selectedLetter;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibraryBucketCompletionScope bucketCompletionScope;
  final LibraryQuickView? quickView;
  final LibraryFilterSelection filterSelection;
  final List<LibrarySortRule>? sortRules;
  final bool? isSidebarVisible;

  bool get hasExplicitViewState {
    return searchQuery != null ||
        folderPreset != null ||
        groupMode != null ||
        selectedBucket != null ||
        linkedMetadataValue != null ||
        selectedLetter != null ||
        collectionStatusScope != LibraryCollectionStatusScope.all ||
        bucketCompletionScope != LibraryBucketCompletionScope.all ||
        quickView != null ||
        filterSelection.hasActiveFilters ||
        (sortRules?.isNotEmpty ?? false) ||
        isSidebarVisible != null;
  }

  factory LibraryRouteState.fromUri(Uri uri) {
    final params = uri.queryParameters;
    final kindStr = _trimmed(params[kindKey])?.toLowerCase();
    final kindEnum = kindStr != null
        ? CatalogMediaKind.values
            .where((k) => k.apiValue == kindStr)
            .firstOrNull
        : null;
    final type = kindEnum != null
        ? defaultLibraryKindRegistry.tryGet(kindEnum)?.type
        : null;
    final folderPreset = _decodeFolderPreset(params[folderKey], type);
    return LibraryRouteState(
      kind: kindStr,
      searchQuery: _trimmed(params[searchKey]),
      groupMode: folderPreset?.primaryMode,
      folderPreset: folderPreset,
      selectedBucket: _trimmed(params[filterValueKey]),
      linkedMetadataValue: _trimmed(params[linkedValueKey]),
      selectedLetter: _trimmed(params[letterKey]),
      collectionStatusScope:
          _enumByName(LibraryCollectionStatusScope.values, params[scopeKey]) ??
              LibraryCollectionStatusScope.all,
      bucketCompletionScope: _enumByName(
            LibraryBucketCompletionScope.values,
            params[bucketScopeKey],
          ) ??
          LibraryBucketCompletionScope.all,
      quickView: _enumByName(LibraryQuickView.values, params[quickKey]),
      filterSelection: _decodeFilterSelection(params[filtersKey]) ??
          LibraryFilterSelection.none,
      sortRules: _decodeSortRules(params[sortKey]),
      isSidebarVisible: _decodeFolders(params[foldersKey]),
    );
  }

  Uri toUri(Uri baseUri, {required LibraryTypeConfig type}) {
    final kind = type.workspace.kind.apiValue;
    final params = <String, String>{kindKey: kind.trim().toLowerCase()};
    final trimmedQuery = _trimmed(searchQuery);
    if (trimmedQuery != null) {
      params[searchKey] = trimmedQuery;
    }
    final activePreset = folderPreset;
    if (activePreset != null) {
      params[folderKey] = activePreset.storageValue;
    } else if (groupMode != null && groupMode!.isNotEmpty) {
      params[folderKey] = libraryGroupModeStorageValue(groupMode!, type);
    }
    final trimmedBucket = _trimmed(selectedBucket);
    if (trimmedBucket != null) {
      params[filterValueKey] = trimmedBucket;
    }
    final trimmedLinkedValue = _trimmed(linkedMetadataValue);
    if (trimmedLinkedValue != null) {
      params[linkedValueKey] = trimmedLinkedValue;
    }
    final trimmedLetter = _trimmed(selectedLetter);
    if (trimmedLetter != null) {
      params[letterKey] = trimmedLetter;
    }
    if (collectionStatusScope != LibraryCollectionStatusScope.all) {
      params[scopeKey] = collectionStatusScope.name;
    }
    if (bucketCompletionScope != LibraryBucketCompletionScope.all) {
      params[bucketScopeKey] = bucketCompletionScope.name;
    }
    if (quickView != null) {
      params[quickKey] = quickView!.name;
    }
    final encodedFilters = _encodeFilterSelection(filterSelection);
    if (encodedFilters != null) {
      params[filtersKey] = encodedFilters;
    }
    final encodedSortRules = _encodeSortRules(sortRules, type);
    if (encodedSortRules != null) {
      params[sortKey] = encodedSortRules;
    }
    if (isSidebarVisible != null) {
      params[foldersKey] = isSidebarVisible! ? '1' : '0';
    }
    return baseUri.replace(queryParameters: params);
  }

  LibraryRouteState filteredForType(LibraryTypeConfig type) {
    final expectedKind = type.workspace.kind.apiValue;
    final routeKind = kind?.trim().toLowerCase();
    if (routeKind != null && routeKind != expectedKind) {
      return LibraryRouteState(kind: expectedKind);
    }
    final allowedGroupModes = type.availableGroupModes.toSet();
    final filteredFolderPreset = sanitizeLibraryFolderPreset(
      folderPreset,
      allowedModes: allowedGroupModes,
    );
    final allowedSortColumns = libraryKindRuntimeForType(type)
        .fields
        .sorts
        .map((d) => d.id.value)
        .toSet();
    final filteredSortRules = sortRules == null
        ? null
        : [
            for (final rule in sortRules!)
              if (allowedSortColumns.contains(rule.column)) rule,
          ];
    final resolvedGroupDef = groupMode != null
        ? libraryKindRuntimeForType(type).fields.findGroupDefinition(groupMode!)
        : null;
    final filteredGroupMode = filteredFolderPreset?.primaryMode ??
        (groupMode != null &&
                (allowedGroupModes.contains(groupMode) ||
                    resolvedGroupDef != null)
            ? (resolvedGroupDef?.id.value ?? groupMode)
            : null);
    final filteredBucketCompletionScope = filteredGroupMode != null &&
            libraryGroupModeSupportsCompletion(type, filteredGroupMode)
        ? bucketCompletionScope
        : LibraryBucketCompletionScope.all;
    return LibraryRouteState(
      kind: expectedKind,
      searchQuery: searchQuery,
      groupMode: filteredGroupMode,
      folderPreset: filteredFolderPreset,
      selectedBucket: selectedBucket,
      linkedMetadataValue: linkedMetadataValue,
      selectedLetter: selectedLetter,
      collectionStatusScope: collectionStatusScope,
      bucketCompletionScope: filteredBucketCompletionScope,
      quickView: sanitizeLibraryQuickViewForType(quickView, type),
      filterSelection: sanitizeLibraryFilterSelectionForType(
        filterSelection,
        type,
      ),
      sortRules: filteredSortRules == null || filteredSortRules.isEmpty
          ? null
          : filteredSortRules,
      isSidebarVisible: isSidebarVisible,
    );
  }

  static String? _encodeSortRules(
    List<LibrarySortRule>? rules,
    LibraryTypeConfig type,
  ) {
    if (rules == null || rules.isEmpty) {
      return null;
    }
    return rules
        .map(
          (rule) =>
              '${rule.column.toString()}:${rule.ascending ? 'asc' : 'desc'}',
        )
        .join(',');
  }

  static List<LibrarySortRule>? _decodeSortRules(String? rawValue) {
    final trimmedValue = _trimmed(rawValue);
    if (trimmedValue == null) {
      return null;
    }
    final decoded = <LibrarySortRule>[];
    for (final segment in trimmedValue.split(',')) {
      final separatorIndex = segment.lastIndexOf(':');
      final columnToken = separatorIndex == -1
          ? null
          : segment.substring(0, separatorIndex).trim();
      final direction = separatorIndex == -1
          ? null
          : segment.substring(separatorIndex + 1).trim().toLowerCase();

      final legacyParts = segment.split('.');
      final legacyColumnToken =
          legacyParts.length == 2 ? legacyParts.first.trim() : null;

      final resolvedColumn = _sortColumnFromToken(
        columnToken ?? legacyColumnToken,
      );
      if (resolvedColumn == null) {
        continue;
      }
      decoded.add(
        LibrarySortRule(
          column: resolvedColumn,
          ascending: (direction ??
                  (legacyParts.length == 2
                      ? legacyParts.last.trim().toLowerCase()
                      : 'asc')) !=
              'desc',
        ),
      );
    }
    return decoded.isEmpty ? null : decoded;
  }

  static String? _sortColumnFromToken(String? token) {
    final trimmed = _trimmed(token);
    if (trimmed == null) {
      return null;
    }
    // Sort column IDs are plain snake_case strings — return the token directly
    return trimmed.split('.').last;
  }

  static LibraryFolderPreset? _decodeFolderPreset(String? rawValue,
      [LibraryTypeConfig? type]) {
    final trimmedValue = _trimmed(rawValue);
    if (trimmedValue == null) {
      return null;
    }
    try {
      return LibraryFolderPreset.parse(trimmedValue, type);
    } catch (_) {
      return null;
    }
  }

  static String? _encodeFilterSelection(LibraryFilterSelection selection) {
    if (!selection.hasActiveFilters) {
      return null;
    }
    final payload = <String, dynamic>{
      if (selection.ownershipFilter != LibraryOwnershipFilter.all)
        'ownership': selection.ownershipFilter.name,
      if (selection.trackingStatusFilter != LibraryTrackingStatusFilter.all)
        'tracking': selection.trackingStatusFilter.name,
      if (selection.loanStatusFilter != LibraryLoanStatusFilter.all)
        'loan': selection.loanStatusFilter.name,
      if (selection.dateRangeField != LibraryDateRangeField.updated)
        'dateField': selection.dateRangeField.name,
      if (selection.dateFrom != null)
        'dateFrom': selection.dateFrom!.toIso8601String(),
      if (selection.dateTo != null)
        'dateTo': selection.dateTo!.toIso8601String(),
      if (_trimmed(selection.customFieldDefinitionId) != null)
        'customFieldDefinitionId': _trimmed(selection.customFieldDefinitionId),
      if (_trimmed(selection.customFieldValue) != null)
        'customFieldValue': _trimmed(selection.customFieldValue),
      if (selection.fieldValues.isNotEmpty)
        'fields': {
          for (final entry in selection.fieldValues.entries)
            if (_trimmed(entry.value) != null) entry.key: _trimmed(entry.value),
        },
      if (selection.missingCover) 'missingCover': true,
      if (selection.missingMetadata) 'missingMetadata': true,
    };
    return base64Url.encode(utf8.encode(jsonEncode(payload)));
  }

  static LibraryFilterSelection? _decodeFilterSelection(String? rawValue) {
    final trimmedValue = _trimmed(rawValue);
    if (trimmedValue == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(_normalizeBase64(trimmedValue))),
      );
      if (decoded is! Map) {
        return null;
      }
      final map = decoded.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final fieldValues = <String, String?>{};
      final rawFields = map['fields'];
      if (rawFields is Map) {
        for (final entry in rawFields.entries) {
          final value = _trimmed(entry.value);
          if (value != null) {
            fieldValues[_normalizeFilterFieldId(entry.key.toString())] = value;
          }
        }
      }
      for (final key in const [
        'series',
        'location',
        'tag',
        'grade',
        'condition',
        'publisher',
        'releaseYear',
        'country',
        'language',
      ]) {
        final value = _trimmed(map[key]);
        if (value != null) {
          fieldValues[_normalizeFilterFieldId(key)] = value;
        }
      }
      return LibraryFilterSelection(
        ownershipFilter:
            _enumByName(LibraryOwnershipFilter.values, map['ownership']) ??
                LibraryOwnershipFilter.all,
        trackingStatusFilter: _enumByName(
              LibraryTrackingStatusFilter.values,
              map['tracking'],
            ) ??
            LibraryTrackingStatusFilter.all,
        loanStatusFilter:
            _enumByName(LibraryLoanStatusFilter.values, map['loan']) ??
                LibraryLoanStatusFilter.all,
        dateRangeField:
            _enumByName(LibraryDateRangeField.values, map['dateField']) ??
                LibraryDateRangeField.updated,
        dateFrom: _parseDateTime(map['dateFrom']),
        dateTo: _parseDateTime(map['dateTo']),
        customFieldDefinitionId: _trimmed(map['customFieldDefinitionId']),
        customFieldValue: _trimmed(map['customFieldValue']),
        fieldValues: fieldValues,
        missingCover: map['missingCover'] == true,
        missingMetadata: map['missingMetadata'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  static bool? _decodeFolders(String? rawValue) {
    final trimmedValue = _trimmed(rawValue)?.toLowerCase();
    return switch (trimmedValue) {
      '1' || 'true' || 'yes' => true,
      '0' || 'false' || 'no' => false,
      _ => null,
    };
  }
}

String _normalizeFilterFieldId(String id) {
  return id == 'releaseYear' ? 'year' : id;
}

LibraryQuickView? sanitizeLibraryQuickViewForType(
  LibraryQuickView? quickView,
  LibraryTypeConfig type,
) {
  if (quickView == null) {
    return null;
  }
  if (quickView.requiresGrades && type.grades.isEmpty) {
    return null;
  }
  return quickView;
}

String? _trimmed(Object? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.toString().trim();
  return trimmed.isEmpty ? null : trimmed;
}

T? _enumByName<T extends Enum>(List<T> values, Object? rawValue) {
  final trimmed = _trimmed(rawValue)?.toLowerCase();
  if (trimmed == null) {
    return null;
  }
  for (final value in values) {
    if (value.name.toLowerCase() == trimmed) {
      return value;
    }
  }
  return null;
}

DateTime? _parseDateTime(Object? rawValue) {
  final trimmed = _trimmed(rawValue);
  return trimmed == null ? null : DateTime.tryParse(trimmed);
}

String _normalizeBase64(String rawValue) {
  final remainder = rawValue.length % 4;
  if (remainder == 0) {
    return rawValue;
  }
  return '$rawValue${'=' * (4 - remainder)}';
}
