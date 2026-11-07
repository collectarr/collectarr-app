import 'package:collectarr_app/features/library/add/mobile/search_controls.dart';
import 'package:collectarr_app/features/library/add/shared.dart';
import 'package:flutter/material.dart';

/// Native Add chrome. Search state and actions remain in the shared mode bar.
class LibraryAddMobileModeBar extends StatelessWidget {
  const LibraryAddMobileModeBar({
    super.key,
    required this.accent,
    required this.mode,
    required this.coverSelected,
    required this.canScanCover,
    required this.isScanningCover,
    required this.searchLabel,
    required this.browseLabel,
    required this.codeLabel,
    this.kindTabLabels = const [],
    this.kindTab = 0,
    this.onKindTab,
    required this.onModeSelected,
    required this.onScanCover,
    required this.input,
    this.advanced,
  });

  final Color accent;
  final LibraryAddDialogMode mode;
  final bool coverSelected;
  final bool canScanCover;
  final bool isScanningCover;
  final String searchLabel;
  final String? browseLabel;
  final String? codeLabel;

  /// The kind's own tabs, chosen by their index.
  final List<String> kindTabLabels;
  final int kindTab;
  final ValueChanged<int>? onKindTab;
  final ValueChanged<LibraryAddDialogMode?> onModeSelected;
  final VoidCallback onScanCover;
  final Widget? input;
  final Widget? advanced;

  @override
  Widget build(BuildContext context) =>
      // A tab is a dialog mode, or a kind tab's index.
      LibraryAddMobileSearchControls<Object?>(
        tabs: [
          if (canScanCover) (value: null, label: 'Cover'),
          (value: LibraryAddDialogMode.identifier, label: 'Barcode'),
          if (browseLabel != null)
            (value: LibraryAddDialogMode.browse, label: browseLabel!),
          (value: LibraryAddDialogMode.search, label: searchLabel),
          if (codeLabel != null)
            (value: LibraryAddDialogMode.code, label: codeLabel!),
          for (final (index, label) in kindTabLabels.indexed)
            (value: index, label: label),
        ],
        selected: coverSelected
            ? null
            : mode == LibraryAddDialogMode.kindTab
                ? kindTab
                : mode,
        accent: accent,
        onSelected: (value) => value is int
            ? onKindTab?.call(value)
            : onModeSelected(value as LibraryAddDialogMode?),
        input: coverSelected
            ? FilledButton.icon(
                onPressed: isScanningCover ? null : onScanCover,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan cover'))
            : input,
        advanced: coverSelected ? null : advanced,
      );
}
