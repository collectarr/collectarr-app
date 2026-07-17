import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'library_workspace_key.dart';

/// A display descriptor for a sort option available in this workspace.
class LibrarySortOption {
  const LibrarySortOption({
    required this.id,
    required this.label,
    required this.group,
    required this.defaultAscending,
  });

  final String id;
  final String label;
  /// Category name for grouping in the sort menu (e.g. 'Main', 'Metadata').
  final String group;
  final bool defaultAscending;
}

/// A display descriptor for a group option available in this workspace.
class LibraryGroupOption {
  const LibraryGroupOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

/// A display descriptor for a table column available in this workspace.
class LibraryColumnOption {
  const LibraryColumnOption({
    required this.id,
    required this.label,
    required this.group,
    required this.isNumeric,
    this.defaultWidth,
  });

  final String id;
  final String label;
  /// Column group label for the column-chooser UI (e.g. 'Main', 'Music').
  final String group;
  final bool isNumeric;
  final double? defaultWidth;
}

/// Available sort options for the current kind — driven by
/// [AnyLibraryFieldRegistry.sorts], zero hardcoded field names.
final libraryAvailableSortsProvider =
    Provider.family<List<LibrarySortOption>, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) {
    final module = libraryKindModuleForKind(key.kind);
    return [
      for (final def in module.fields.sorts)
        LibrarySortOption(
          id: def.id,
          label: def.label,
          group: def.group,
          defaultAscending: def.defaultAscending,
        ),
    ];
  },
);

/// Available group options for the current kind — driven by
/// [AnyLibraryFieldRegistry.groups], zero hardcoded group modes.
final libraryAvailableGroupsProvider =
    Provider.family<List<LibraryGroupOption>, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) {
    final module = libraryKindModuleForKind(key.kind);
    return [
      for (final def in module.fields.groups)
        LibraryGroupOption(
          id: def.id.value,
          label: def.label,
        ),
    ];
  },
);

/// Available column options for the current kind — driven by
/// [AnyLibraryFieldRegistry.columns], zero hardcoded column names.
final libraryAvailableColumnsProvider =
    Provider.family<List<LibraryColumnOption>, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) {
    final module = libraryKindModuleForKind(key.kind);
    return [
      for (final def in module.fields.columns)
        LibraryColumnOption(
          id: def.id.value,
          label: def.label,
          group: def.group,
          isNumeric: def.isNumeric,
          defaultWidth: def.defaultWidth,
        ),
    ];
  },
);
