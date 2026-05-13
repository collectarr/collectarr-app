import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_chrome.dart';
import 'package:flutter/material.dart';

class ComicsToolbarPrimaryActions extends StatelessWidget {
  const ComicsToolbarPrimaryActions({
    super.key,
    required this.onAddComic,
    required this.onScanBarcode,
    required this.onRefreshMetadata,
  });

  final VoidCallback onAddComic;
  final VoidCallback onScanBarcode;
  final VoidCallback onRefreshMetadata;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 30,
          child: FilledButton.icon(
            onPressed: onAddComic,
            style: FilledButton.styleFrom(
              backgroundColor: kClzYellow,
              foregroundColor: const Color(0xFF151515),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('Add Comics'),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Scan barcode',
          child: LibraryWorkspaceIconButton(
            icon: Icons.qr_code_scanner,
            onPressed: onScanBarcode,
          ),
        ),
        Tooltip(
          message: 'Refresh metadata',
          child: LibraryWorkspaceIconButton(
            icon: Icons.sync,
            onPressed: onRefreshMetadata,
          ),
        ),
      ],
    );
  }
}
