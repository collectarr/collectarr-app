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
  final ValueChanged<LibraryAddDialogMode?> onModeSelected;
  final VoidCallback onScanCover;
  final Widget? input;
  final Widget? advanced;

  @override
  Widget build(BuildContext context) =>
      LibraryAddMobileSearchControls<LibraryAddDialogMode?>(
        tabs: [
          if (canScanCover) (value: null, label: 'Cover'),
          (value: LibraryAddDialogMode.identifier, label: 'Barcode'),
          if (browseLabel != null)
            (value: LibraryAddDialogMode.browse, label: browseLabel!),
          (value: LibraryAddDialogMode.search, label: searchLabel),
          if (codeLabel != null)
            (value: LibraryAddDialogMode.code, label: codeLabel!),
        ],
        selected: coverSelected ? null : mode,
        accent: accent,
        onSelected: onModeSelected,
        input: coverSelected
            ? FilledButton.icon(
                onPressed: isScanningCover ? null : onScanCover,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan cover'))
            : input,
        advanced: coverSelected ? null : advanced,
      );
}
