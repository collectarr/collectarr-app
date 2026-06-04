import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryAddManualIntroCard extends StatelessWidget {
  const LibraryAddManualIntroCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    this.badges = const <Widget>[],
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final List<Widget> badges;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (subtitle?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!.trim(),
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (badges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: badges),
            ],
          ],
        ),
      ),
    );
  }
}

Widget libraryAddManualIntroBadge(String label, {Color? accent}) {
  return LibraryAddResultBadge(label, accent: accent);
}
