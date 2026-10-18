import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter/material.dart';

class LibrarySortFavorite {
  const LibrarySortFavorite({
    required this.id,
    required this.label,
    required this.icon,
    required this.rules,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<LibrarySortRule> rules;
}

const defaultLibraryColumnFavorites = [
  LibraryTableColumnPreset(
    label: 'Essential',
    columns: {
      'status',
      'title',
      'release_date',
      'updated',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Collection',
    columns: {
      'status',
      'title',
      'condition',
      'price',
      'wishlist',
      'updated',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Reference',
    columns: {
      'status',
      'title',
      'release_date',
      'updated',
    },
  ),
];

String libraryFallbackLabelForId(String value) {
  final tokens = value
      .split('.')
      .map((segment) => segment.replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]} ${match[2]}',
          ))
      .join(' ');
  if (tokens.isEmpty) {
    return value;
  }
  return tokens[0].toUpperCase() + tokens.substring(1);
}

String librarySortColumnFallbackLabel(String column) {
  final columnName = column.contains('.') ? column.split('.').last : column;
  final raw = columnName.replaceAll('_', ' ').replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );
  if (raw.isEmpty) {
    return columnName;
  }
  return raw.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}
