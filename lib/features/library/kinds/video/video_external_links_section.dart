import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoExternalLinksSection extends StatelessWidget {
  const VideoExternalLinksSection({
    super.key,
    required this.title,
    required this.links,
    required this.accent,
  });

  final String title;
  final List<TrailerLink> links;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final externalLinks = links.where((link) => link.isExternalLink).toList(growable: false);
    if (externalLinks.isEmpty) {
      return const SizedBox.shrink();
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).surfaceSubtle,
        border: Border.all(color: accent.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
            ),
            const SizedBox(height: 8),
            for (final link in externalLinks)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _LinkRow(link: link, accent: accent),
              ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link, required this.accent});

  final TrailerLink link;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final title = link.title?.trim().isNotEmpty == true ? link.title!.trim() : link.source?.trim();
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(link.url);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.link_outlined, size: 16, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title == null || title.isEmpty ? link.url : title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Uri.tryParse(link.url)?.host ?? '',
              style: TextStyle(color: palette.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
