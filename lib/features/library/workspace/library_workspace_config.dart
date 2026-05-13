import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, list }

enum LibraryDetailsLayout { right, bottom, hidden }

enum LibraryWorkspacePreset { cover, card, list, details }

extension LibraryWorkspacePresetLabels on LibraryWorkspacePreset {
  String get label {
    return switch (this) {
      LibraryWorkspacePreset.cover => 'Cover',
      LibraryWorkspacePreset.card => 'Card',
      LibraryWorkspacePreset.list => 'List',
      LibraryWorkspacePreset.details => 'Details',
    };
  }

  IconData get icon {
    return switch (this) {
      LibraryWorkspacePreset.cover => Icons.grid_view,
      LibraryWorkspacePreset.card => Icons.view_module,
      LibraryWorkspacePreset.list => Icons.view_list,
      LibraryWorkspacePreset.details => Icons.view_sidebar,
    };
  }
}

enum LibrarySortColumn {
  status,
  title,
  issue,
  variant,
  publisher,
  releaseDate,
  barcode,
  grade,
  condition,
  price,
  storageBox,
  wishlist,
  updated
}

enum LibraryTableColumn {
  status,
  cover,
  title,
  issue,
  variant,
  publisher,
  releaseDate,
  barcode,
  grade,
  condition,
  price,
  storageBox,
  wishlist,
  updated
}

enum LibraryTableColumnGroup { main, edition, value, personal }

class LibraryWorkspaceConfig {
  const LibraryWorkspaceConfig({
    required this.kind,
    required this.title,
    required this.icon,
    required this.preferencePrefix,
    required this.defaultSortColumn,
    required this.defaultVisibleColumns,
  });

  final String kind;
  final String title;
  final IconData icon;
  final String preferencePrefix;
  final LibrarySortColumn defaultSortColumn;
  final Set<LibraryTableColumn> defaultVisibleColumns;

  String preferenceKey(String suffix) => '$preferencePrefix.$suffix';
}
