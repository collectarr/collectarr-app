import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MusicDiscTabButton extends StatelessWidget {
  const MusicDiscTabButton({
    super.key,
    required this.number,
    this.format,
    required this.selected,
    required this.onPressed,
  });
  final int number;
  final String? format;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final text = (format?.trim().isNotEmpty == true)
        ? '$number · ${format!.trim()}'
        : 'Disc #$number';
    return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            minimumSize: const Size(88, 34),
            foregroundColor: appPalette(context).textPrimary,
            backgroundColor: selected
                ? appPalette(context).surfaceBright
                : appPalette(context).panelRaised,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(3)))),
        child: Text(text));
  }
}
