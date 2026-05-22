import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryDetailHero extends StatelessWidget {
  const LibraryDetailHero({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final releaseLabel = formatNullableDate(entry.releaseDate) ??
        entry.releaseYear?.toString();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF101010),
            Color.alphaBlend(
              accent.withValues(alpha: 0.18),
              const Color(0xFF18242A),
            ),
            const Color(0xFF101010),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
            final cover = SizedBox(
              width: wide ? 180 : 150,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: LibraryInteractiveCover(
                  title: entry.title,
                  itemNumber: entry.itemNumber,
                  imageUrl: entry.displayCoverUrl,
                  ownedItemId: entry.ownedItemId,
                  accentColor: accent,
                ),
              ),
            );
            final info = Column(
              crossAxisAlignment:
                  wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  entry.title,
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    type.singularLabel,
                    if (entry.itemNumber != null &&
                        entry.itemNumber!.isNotEmpty)
                      '#${entry.itemNumber}',
                    if (entry.variant != null && entry.variant!.isNotEmpty)
                      entry.variant,
                    if (entry.publisher != null && entry.publisher!.isNotEmpty)
                      entry.publisher,
                    if (releaseLabel != null) releaseLabel,
                  ].whereType<String>().join(' | '),
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                  children: [
                    _DetailHeaderChip(
                      icon: Icons.inventory_2,
                      label: entry.isOwned ? 'Owned' : 'Not owned',
                      accent: accent,
                    ),
                    _DetailHeaderChip(
                      icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                      label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
                      accent: accent,
                    ),
                    _DetailHeaderChip(
                      icon: entry.hasMissingCover
                          ? Icons.image_not_supported_outlined
                          : Icons.image_outlined,
                      label: entry.hasMissingCover
                          ? 'Missing cover'
                          : 'Cover ready',
                      accent: accent,
                    ),
                    _DetailHeaderChip(
                      icon: entry.hasMissingMetadata
                          ? Icons.manage_search
                          : Icons.fact_check_outlined,
                      label: entry.hasMissingMetadata
                          ? 'Missing metadata'
                          : 'Metadata ready',
                      accent: accent,
                    ),
                    if (ownedItem?.condition != null)
                      _DetailHeaderChip(
                        icon: Icons.fact_check_outlined,
                        label: ownedItem!.condition!,
                        accent: accent,
                      ),
                    if (ownedItem?.grade != null)
                      _DetailHeaderChip(
                        icon: Icons.workspace_premium,
                        label: ownedItem!.grade!,
                        accent: accent,
                      ),
                  ],
                ),
                if (entry.synopsis != null &&
                    entry.synopsis!.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    entry.synopsis!,
                    maxLines: wide ? 5 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: kClzTextMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(width: 18),
                  Expanded(child: info),
                ],
              );
            }
            return Column(
              children: [
                cover,
                const SizedBox(height: 14),
                info,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailHeaderChip extends StatelessWidget {
  const _DetailHeaderChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryMetaChip(
      icon: icon,
      label: label,
      accent: accent,
      borderRadius: BorderRadius.circular(3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    );
  }
}
