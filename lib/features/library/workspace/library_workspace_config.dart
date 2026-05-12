import 'package:flutter/material.dart';

enum LibraryViewMode { grid, card, list }

enum LibraryDetailsLayout { right, bottom, hidden }

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
