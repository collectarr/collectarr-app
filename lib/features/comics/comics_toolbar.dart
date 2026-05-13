import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_workspace_controls.dart';
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: kClzToolbar,
        border: Border(bottom: BorderSide(color: kClzDivider)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            ComicsToolbarPrimaryActions(
              onAddComic: onAddComic,
              onScanBarcode: onScanBarcode,
              onRefreshMetadata: onRefreshMetadata,
            ),
            const LibraryWorkspaceSeparator(color: kClzDivider),
            ComicsToolbarSearch(
              controller: controller,
              selectedSeries: controlState.utility.selectedSeries,
              onSearch: onSearch,
              onClearSeries: onClearSeries,
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
