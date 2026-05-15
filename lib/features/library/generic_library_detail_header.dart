import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericDetailHero extends StatelessWidget {
  const GenericDetailHero({
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
    final releaseLabel = formatNullableComicDate(entry.releaseDate) ??
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
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xAAFFFFFF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xCC000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: LibraryCoverImage(
                    title: entry.title,
                    itemNumber: entry.itemNumber,
                    imageUrl: entry.displayCoverUrl,
                  ),
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
                    _DetailChip(
                      icon: Icons.inventory_2,
                      label: entry.isOwned ? 'Owned' : 'Not owned',
                      accent: accent,
                    ),
                    _DetailChip(
                      icon: entry.isWishlisted ? Icons.star : Icons.star_border,
                      label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
                      accent: accent,
                    ),
                    _DetailChip(
                      icon: entry.hasMissingCover
                          ? Icons.image_not_supported_outlined
                          : Icons.image_outlined,
                      label: entry.hasMissingCover
                          ? 'Missing cover'
                          : 'Cover ready',
                      accent: accent,
                    ),
                    _DetailChip(
                      icon: entry.hasMissingMetadata
                          ? Icons.manage_search
                          : Icons.fact_check_outlined,
                      label: entry.hasMissingMetadata
                          ? 'Missing metadata'
                          : 'Metadata ready',
                      accent: accent,
                    ),
                    if (ownedItem?.condition != null)
                      _DetailChip(
                        icon: Icons.fact_check_outlined,
                        label: ownedItem!.condition!,
                        accent: accent,
                      ),
                    if (ownedItem?.grade != null)
                      _DetailChip(
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

class GenericDetailActionStrip extends StatelessWidget {
  const GenericDetailActionStrip({
    super.key,
    required this.type,
    required this.entry,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (entry.isOwned)
          FilledButton.icon(
            onPressed: onRemoveOwned,
            icon: const Icon(Icons.remove_circle_outline),
            label: Text('Remove ${type.singularLabel.toLowerCase()}'),
          )
        else
          FilledButton.icon(
            onPressed: onAddOwned,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add to collection'),
          ),
        OutlinedButton.icon(
          onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
          icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
          label: Text(
            entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
          ),
        ),
      ],
    );
  }
}

class GenericDetailStatsBar extends StatelessWidget {
  const GenericDetailStatsBar({
    super.key,
    required this.entry,
    required this.ownedItem,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DetailStat(label: 'Status', value: _statusLabel(entry)),
        _DetailStat(
          label: 'Cover',
          value: entry.hasMissingCover ? 'Missing' : 'Ready',
        ),
        _DetailStat(
          label: 'Metadata',
          value: entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
        _DetailStat(
          label: 'Quantity',
          value: ownedItem == null ? '0' : ownedItem!.quantity.toString(),
        ),
        _DetailStat(
          label: 'Updated',
          value: formatNullableComicDate(entry.updatedAt) ?? '-',
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCC172E35),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kClzPanelRaised,
        border: Border.all(color: kClzDivider),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: kClzTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(LibraryWorkspaceEntry entry) {
  if (entry.isOwned) {
    return 'Owned';
  }
  if (entry.isWishlisted) {
    return 'Wishlist';
  }
  return 'Local catalog';
}
