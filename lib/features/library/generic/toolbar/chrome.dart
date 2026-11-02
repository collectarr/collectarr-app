import 'package:collectarr_app/features/library/generic/toolbar/auxiliary_controls.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryToolbarDividerLine extends StatelessWidget {
  const LibraryToolbarDividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: appPalette(context).divider,
    );
  }
}

class LibraryToolbarChromeRow extends StatelessWidget {
  const LibraryToolbarChromeRow({
    super.key,
    required this.collectionStatusScope,
    this.onCollectionStatusScopeChanged,
    this.activeViewPreset,
    this.onViewPresetSelected,
    this.pinnedViewPresets = const {},
    this.onTogglePinnedViewPreset,
    this.sortFavorites = const [],
    this.activeSortFavoriteId,
    this.onSortFavoriteSelected,
    this.pinnedSortFavoriteIds = const {},
    this.onTogglePinnedSortFavorite,
    this.columnFavoritePresets = const [],
    this.activeColumnFavoriteLabel,
    this.onColumnFavoriteSelected,
    this.pinnedColumnFavoriteKeys = const {},
    this.onTogglePinnedColumnFavorite,
    required this.onManageColumns,
    this.onManageColumnFavorites,
    this.canJumpToNumber = false,
    this.onJumpToNumberSubmitted,
  });

  final LibraryCollectionStatusScope collectionStatusScope;
  final ValueChanged<LibraryCollectionStatusScope>?
      onCollectionStatusScopeChanged;
  final LibraryWorkspacePreset? activeViewPreset;
  final ValueChanged<LibraryWorkspacePreset>? onViewPresetSelected;
  final Set<LibraryWorkspacePreset> pinnedViewPresets;
  final ValueChanged<LibraryWorkspacePreset>? onTogglePinnedViewPreset;
  final List<LibrarySortFavorite> sortFavorites;
  final String? activeSortFavoriteId;
  final ValueChanged<LibrarySortFavorite>? onSortFavoriteSelected;
  final Set<String> pinnedSortFavoriteIds;
  final ValueChanged<LibrarySortFavorite>? onTogglePinnedSortFavorite;
  final List<LibraryTableColumnPreset> columnFavoritePresets;
  final String? activeColumnFavoriteLabel;
  final ValueChanged<LibraryTableColumnPreset>? onColumnFavoriteSelected;
  final Set<String> pinnedColumnFavoriteKeys;
  final ValueChanged<LibraryTableColumnPreset>? onTogglePinnedColumnFavorite;
  final VoidCallback onManageColumns;
  final VoidCallback? onManageColumnFavorites;
  final bool canJumpToNumber;
  final ValueChanged<String>? onJumpToNumberSubmitted;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: onCollectionStatusScopeChanged == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.centerLeft,
                child: LibraryCollectionStatusScopeDropdown(
                  collectionStatusScope: collectionStatusScope,
                  onCollectionStatusScopeChanged:
                      onCollectionStatusScopeChanged!,
                ),
              ),
      );
}
