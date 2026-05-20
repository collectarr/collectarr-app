import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_controls.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/selection/library_selection_controls.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:flutter/material.dart';

class ComicsToolbar extends StatelessWidget {
  const ComicsToolbar({
    super.key,
    required this.controller,
    required this.controlState,
    required this.controlCallbacks,
    required this.onSearch,
    required this.onAddComic,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    required this.onClearSeries,
  });

  final TextEditingController controller;
  final ComicsWorkspaceControlState controlState;
  final ComicsWorkspaceControlCallbacks controlCallbacks;
  final ValueChanged<String> onSearch;
  final VoidCallback onAddComic;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context) {
    final accent = libraryAccentForKind('comic');
    return LibraryToolbarFrame(
      backgroundColor: kClzToolbar,
      dividerColor: kClzDivider,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            LibraryToolbarPrimaryActions(
              addLabel: 'Add ${comicsLibraryConfig.pluralLabel}',
              onAdd: onAddComic,
              onScanBarcode: onScanBarcode,
              onRefreshMetadata: onRefreshMetadata,
              addBackgroundColor: accent,
              addForegroundColor: Colors.white,
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            LibraryToolbarSearch(
              controller: controller,
              hintText: 'Search ${comicsLibraryConfig.pluralLabel.toLowerCase()}...',
              selectedFilterLabel: controlState.utility.selectedSeries,
              onSearch: onSearch,
              onClearFilter: onClearSeries,
              selectionColor: kClzSelection,
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            LibrarySelectionControls(
              enabled: controlState.selectionEnabled,
              selectedCount: controlState.selectedCount,
              callbacks: controlCallbacks.selection,
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            ComicsWorkspaceControlStrip(
              state: controlState,
              callbacks: controlCallbacks,
            ),
          ],
        ),
      ),
    );
  }
}
