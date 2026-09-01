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

const defaultLibrarySortFavorites = [
  LibrarySortFavorite(
    id: 'title_asc',
    label: 'Title A-Z',
    icon: Icons.sort_by_alpha,
    rules: [
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'release_latest',
    label: 'Latest release',
    icon: Icons.event,
    rules: [
      LibrarySortRule(column: 'release_date', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'recent',
    label: 'Recently added',
    icon: Icons.update,
    rules: [
      LibrarySortRule(column: 'updated', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
  LibrarySortFavorite(
    id: 'value_desc',
    label: 'Value high to low',
    icon: Icons.attach_money,
    rules: [
      LibrarySortRule(column: 'price', ascending: false),
      LibrarySortRule(column: 'title', ascending: true),
    ],
  ),
];

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

String definitionIdFor(Object value) {
  final normalized = switch (value) {
    String text => text.trim(),
    Object _ => value.toString().trim(),
  };
  if (normalized.isEmpty) {
    return '';
  }
  if (value is String) {
    return normalized;
  }
  return normalized.contains('.') ? normalized.split('.').last : normalized;
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
