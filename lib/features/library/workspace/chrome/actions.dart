import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_typography.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:flutter/material.dart';

class LibraryToolbarPrimaryActions extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobileApp) ...[
          SizedBox(
            height: 30,
            child: FilledButton(
              onPressed: onAdd,
              // Hovering darkens it like the editor's Save button.
              style: withFilledButtonHover(
                FilledButton.styleFrom(
                  foregroundColor: addForegroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  textStyle: TextStyle(
                    fontFamily: appFontFamily,
                    fontFamilyFallback: kAppFontFamilyFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                addBackgroundColor,
              ),
              // Compact plus and bold label, as in the reference toolbar.
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.add, size: 13),
                  const SizedBox(width: 4),
                  Text(addLabel),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
