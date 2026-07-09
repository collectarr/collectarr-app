import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_toolbar_config.dart';
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
    this.defaultDensityPreset = LibraryWorkspaceDensityPreset.compact,
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
  final LibraryWorkspaceDensityPreset defaultDensityPreset;
  final List<LibraryWorkspaceDensityPreset> availableDensityPresets;
  final List<LibraryToolbarActionId> toolbarActions;

  bool supportsDensityPreset(LibraryWorkspaceDensityPreset preset) {
    return availableDensityPresets.contains(preset);
  }

  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';
}
