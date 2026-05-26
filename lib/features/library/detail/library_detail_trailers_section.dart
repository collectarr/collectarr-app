import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LibraryDetailTrailersSection extends StatelessWidget {
  const LibraryDetailTrailersSection({
    super.key,
    required this.trailerUrls,
    required this.accent,
  });

  final List<TrailerLink> trailerUrls;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (trailerUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_outline, size: 18, color: accent),
              const SizedBox(width: 6),
              Text(
                'Trailers',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final trailer in trailerUrls)
            _TrailerTile(trailer: trailer, accent: accent),
        ],
      ),
    );
  }
}

class _TrailerTile extends StatelessWidget {
  const _TrailerTile({required this.trailer, required this.accent});

  final TrailerLink trailer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isYouTube = trailer.url.contains('youtube.com') ||
        trailer.url.contains('youtu.be');
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _launchUrl(trailer.url),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Icon(
                isYouTube ? Icons.smart_display : Icons.open_in_new,
                size: 20,
                color: isYouTube ? Colors.red : kAppTextMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trailer.title ?? 'Trailer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (trailer.source != null)
                      Text(
                        trailer.source!,
                        style: const TextStyle(
                          color: kAppTextMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (!trailer.isAutomatic)
                Tooltip(
                  message: 'User-added trailer',
                  child: Icon(Icons.person_outline, size: 14, color: accent),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: kAppTextMuted),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
