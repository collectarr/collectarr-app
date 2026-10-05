import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact neutral tag shared by vocabulary fields and nested credit values.
class LibraryValueChip extends StatelessWidget {
  const LibraryValueChip({super.key, required this.label, this.onDeleted});
  final String label;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Material(
        color: palette.divider,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
            height: 26,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Tooltip(
                          message: label,
                          child: Text(label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 14))))),
              SizedBox(
                  width: 24,
                  height: 26,
                  child: IconButton(
                      tooltip: 'Remove $label',
                      padding: EdgeInsets.zero,
                      onPressed: onDeleted,
                      icon: Icon(Icons.close,
                          size: 14, color: palette.textMuted))),
            ])));
  }
}
