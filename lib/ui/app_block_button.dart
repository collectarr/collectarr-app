import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The reference's "success" green for download buttons.
const Color kAppSuccessGreen = Color(0xff5cb85c);

enum AppBlockButtonIcon { spinner, download, copy }

/// Full-width 32 px button with 14/400 white text and 4 px corners, as the
/// reference uses for Generate and Download file on its export pages.
class AppBlockButton extends StatelessWidget {
  const AppBlockButton(
      {super.key,
      required this.label,
      required this.color,
      required this.onPressed,
      this.icon});
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final AppBlockButtonIcon? icon;

  @override
  Widget build(BuildContext context) {
    final working = icon == AppBlockButtonIcon.spinner;
    final leading = switch (icon) {
      AppBlockButtonIcon.spinner => const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xffbfbfbf))),
      AppBlockButtonIcon.download =>
        const Icon(Icons.download, size: 16, color: Colors.white),
      AppBlockButtonIcon.copy =>
        const Icon(Icons.copy, size: 16, color: Colors.white),
      null => null,
    };
    return SizedBox(
      height: 32,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: working ? const Color(0xff20719c) : color,
          disabledBackgroundColor: const Color(0xff20719c),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xffbfbfbf),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: TextStyle(
              fontFamily: appFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 6)],
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
