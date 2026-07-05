import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'library_workspace_controls.dart';

class LibraryToolbarPrimaryActions extends ConsumerWidget {
  const LibraryToolbarPrimaryActions({
    super.key,
    required this.addLabel,
    required this.onAdd,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
    this.onRandomPick,
    this.onScanCover,
    required this.addBackgroundColor,
    required this.addForegroundColor,
  });

  final String addLabel;
  final VoidCallback onAdd;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;
  final VoidCallback? onRandomPick;
  final VoidCallback? onScanCover;
  final Color addBackgroundColor;
  final Color addForegroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useFab =
        ref.watch(uiPreferencesProvider.select((p) => p.fabAddButton));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!useFab) ...[
          SizedBox(
            height: 30,
            child: FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: addBackgroundColor,
                foregroundColor: addForegroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              icon: const Icon(Icons.add, size: 17),
              label: Text(addLabel),
            ),
          ),
        ],
      ],
    );
  }
}
