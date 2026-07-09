import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:flutter/material.dart';

import 'library_workspace_enums.dart';

export 'library_workspace_enums.dart';

class LibrarySortRule {
  const LibrarySortRule({required this.column, required this.ascending});

  final LibrarySortColumn column;
  final bool ascending;

  LibrarySortRule copyWith({
    LibrarySortColumn? column,
    bool? ascending,
  }) {
    return LibrarySortRule(
      column: column ?? this.column,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LibrarySortRule &&
        other.column == column &&
        other.ascending == ascending;
  }

  @override
  int get hashCode => Object.hash(column, ascending);
}

class LibrarySortPreset {
  const LibrarySortPreset({
    this.id,
    required this.label,
    required this.rules,
    this.icon,
    this.isBuiltIn = false,
  });

  final String? id;
  final String label;
  final List<LibrarySortRule> rules;
  final IconData? icon;
  final bool isBuiltIn;

  bool get isSaved => id != null && !isBuiltIn;
}

enum LibraryTableColumnGroup { main, edition, value, personal }

class LibraryTableColumnPreset {
  const LibraryTableColumnPreset({
    this.id,
    required this.label,
    required this.columns,
  });

  final String? id;
  final String label;
  final Set<LibraryTableColumn> columns;

  bool get isSaved => id != null;
}

class LibraryWorkspaceConfig {
  const LibraryWorkspaceConfig({
    required this.kind,
    required this.title,
    required this.icon,
    required this.accent,
    required this.preferencePrefix,
    required this.defaultSortColumn,
    required this.defaultVisibleColumns,
    this.defaultDensityPreset = LibraryWorkspaceDensityPreset.compact,
    this.availableSortColumns = const [],
    this.availableSortColumnDefinitions = const [],
    this.availableTableColumns = const [],
    this.availableDensityPresets = const [
      LibraryWorkspaceDensityPreset.comfortable,
      LibraryWorkspaceDensityPreset.compact,
      LibraryWorkspaceDensityPreset.ultraCompact,
    ],
    this.toolbarActions = kDefaultLibraryToolbarActions,
  });

  final CatalogMediaKind kind;
  final String title;
  final IconData icon;
  final Color accent;
  final String preferencePrefix;
  final LibrarySortColumn defaultSortColumn;
  final Set<LibraryTableColumn> defaultVisibleColumns;
  final LibraryWorkspaceDensityPreset defaultDensityPreset;
  final List<LibrarySortColumn> availableSortColumns;
  final List<LibrarySortColumnDefinition> availableSortColumnDefinitions;
  final List<LibraryTableColumn> availableTableColumns;
  final List<LibraryWorkspaceDensityPreset> availableDensityPresets;
  final List<LibraryToolbarActionId> toolbarActions;

  bool supportsSortColumn(LibrarySortColumn column) {
    return availableSortColumns.contains(column) ||
        availableSortColumnDefinitions.any((definition) =>
            definition.column == column);
  }

  bool supportsTableColumn(LibraryTableColumn column) {
    return availableTableColumns.contains(column);
  }

  bool supportsDensityPreset(LibraryWorkspaceDensityPreset preset) {
    return availableDensityPresets.contains(preset);
  }

  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';

  String sortColumnFieldId(LibrarySortColumn column) {
    return sortColumnDefinitionFor(column).id;
  }

  String tableColumnFieldId(LibraryTableColumn column) {
    return '${kind.apiValue}.${_stableToken(column.name)}';
  }

  LibrarySortColumn? sortColumnFromFieldId(String? fieldId) {
    if (fieldId == null || fieldId.trim().isEmpty) {
      return null;
    }
    final normalized = fieldId.trim();
    final normalizedToken = _stableToken(normalized.split('.').last);
    for (final definition in availableSortColumnDefinitions) {
      final definitionToken = _stableToken(definition.id.split('.').last);
      if (definition.id == normalized ||
          definitionToken == normalizedToken ||
          _stableToken(definition.column.name) == normalizedToken) {
        return definition.column;
      }
    }
    for (final column in availableSortColumns) {
      if (_stableToken(column.name) == normalizedToken) {
        return column;
      }
    }
    return null;
  }

  LibrarySortColumnDefinition sortColumnDefinitionFor(
    LibrarySortColumn column,
  ) {
    for (final definition in availableSortColumnDefinitions) {
      if (definition.column == column) {
        return definition;
      }
    }
    return LibrarySortColumnDefinition(
      column: column,
      label: librarySortColumnFallbackLabel(column),
    );
  }

  LibraryTableColumn? tableColumnFromFieldId(String? fieldId) {
    if (fieldId == null || fieldId.trim().isEmpty) {
      return null;
    }
    final normalized = fieldId.trim();
    for (final column in availableTableColumns) {
      if (tableColumnFieldId(column) == normalized ||
          _stableToken(column.name) == normalized.split('.').last) {
        return column;
      }
    }
    return null;
  }

  String _stableToken(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
  }
}
