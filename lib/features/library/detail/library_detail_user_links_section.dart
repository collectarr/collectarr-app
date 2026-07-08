import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class LibraryDetailUserLinksSection extends ConsumerWidget {
  const LibraryDetailUserLinksSection({
    super.key,
    required this.itemId,
    required this.accent,
  });

  final String itemId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(userExternalLinksByItemProvider(itemId));
    return linksAsync.when(
      data: (links) {
        final userLinks = links.where((link) => link.kind != 'trailer').toList(growable: false);
        final trailers = links.where((link) => link.kind == 'trailer').toList(growable: false);
        if (userLinks.isEmpty && trailers.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            if (userLinks.isNotEmpty) ...[
              _LinkGroupSection(
                title: 'User links',
                accent: accent,
                links: userLinks,
              ),
              const SizedBox(height: 16),
            ],
            if (trailers.isNotEmpty)
              _LinkGroupSection(
                title: 'Trailers',
                accent: accent,
                links: trailers,
                kindIsTrailer: true,
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _LinkGroupSection extends StatelessWidget {
  const _LinkGroupSection({
    required this.title,
    required this.accent,
    required this.links,
    this.kindIsTrailer = false,
  });

  final String title;
  final Color accent;
  final List<UserExternalLink> links;
  final bool kindIsTrailer;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return LibraryDetailSection(
      title: title,
      accentColor: accent,
      children: [
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
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
                    Icon(
                      kindIsTrailer ? Icons.play_circle_outline : Icons.link_outlined,
                      size: 16,
                      color: accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            link.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      link.kind,
                      style: TextStyle(color: palette.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

