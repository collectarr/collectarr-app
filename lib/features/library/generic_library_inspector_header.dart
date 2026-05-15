import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/generic_library_display.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericInspectorBackdrop extends StatelessWidget {
  const GenericInspectorBackdrop({super.key, required this.entry});

  final LibraryWorkspaceEntry entry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.38,
          child: LibraryCoverImage(
            title: entry.title,
            itemNumber: entry.itemNumber,
            imageUrl: entry.displayCoverUrl,
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x66111111),
                Color(0xE0121212),
                Color(0xFA111111),
              ],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xF0101010),
                Color(0xC0101010),
                Color(0xE8101010),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GenericInspectorActionBar extends StatelessWidget {
  const GenericInspectorActionBar({
    super.key,
    required this.type,
    required this.entry,
    required this.onToggleOwned,
    required this.onToggleWishlist,
    required this.onOpenDetails,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onToggleOwned;
  final VoidCallback? onToggleWishlist;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51D1D1D),
        border: Border.all(color: kClzDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          children: [
            _GenericInspectorActionButton(
              tooltip: entry.isOwned
                  ? 'Remove from collection'
                  : 'Add to collection',
              onPressed: onToggleOwned,
              icon: entry.isOwned
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
            ),
            const SizedBox(width: 4),
            _GenericInspectorActionButton(
              tooltip: entry.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
              onPressed: onToggleWishlist,
              icon: entry.isWishlisted ? Icons.star : Icons.star_border,
            ),
            const SizedBox(width: 4),
            _GenericInspectorActionButton(
              tooltip: 'Open details',
              onPressed: onOpenDetails,
              icon: Icons.open_in_new,
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: entry.isOwned ? kClzYellow : const Color(0xFF2A2A2A),
                border: Border.all(
                  color: entry.isOwned ? kClzYellow : kClzDivider,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      entry.isOwned
                          ? Icons.check
                          : Icons.check_box_outline_blank,
                      size: 15,
                      color: entry.isOwned
                          ? const Color(0xFF141414)
                          : kClzTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.isOwned ? 'OWNED' : 'LOCAL',
                      style: TextStyle(
                        color: entry.isOwned
                            ? const Color(0xFF141414)
                            : kClzTextMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericInspectorActionButton extends StatelessWidget {
  const _GenericInspectorActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 28,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      ),
    );
  }
}

class GenericInspectorHero extends StatelessWidget {
  const GenericInspectorHero({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 560;
        final cover = SizedBox(
          width: wide ? 146 : 174,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xAAFFFFFF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xCC000000),
                    blurRadius: 16,
                    offset: Offset(0, 5),
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
        final info = _GenericInspectorHeroInfo(
          type: type,
          entry: entry,
          ownedItem: ownedItem,
          accent: accent,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.52)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xD70A0A0A),
                Color.alphaBlend(
                  accent.withValues(alpha: 0.18),
                  const Color(0xB3132830),
                ),
                const Color(0xE80A0A0A),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 14),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cover,
                      const SizedBox(height: 10),
                      info,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _GenericInspectorHeroInfo extends StatelessWidget {
  const _GenericInspectorHeroInfo({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
              ),
            ),
            if (entry.itemNumber != null && entry.itemNumber!.isNotEmpty) ...[
              const SizedBox(width: 7),
              GenericLibraryItemPill(
                label: entry.itemNumber!,
                color: kClzYellow,
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          [
            if (entry.variant != null && entry.variant!.isNotEmpty)
              entry.variant,
            if (entry.publisher != null && entry.publisher!.isNotEmpty)
              entry.publisher,
            if (releaseLabel != null) releaseLabel,
          ].whereType<String>().join('  |  '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            GenericLibraryMetaChip(
              icon: Icons.category_outlined,
              label: type.singularLabel,
              accent: accent,
            ),
            GenericLibraryMetaChip(
              icon: Icons.inventory_2,
              label: entry.isOwned ? 'Owned' : 'Not owned',
              accent: accent,
            ),
            GenericLibraryMetaChip(
              icon: entry.isWishlisted ? Icons.star : Icons.star_border,
              label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
              accent: accent,
            ),
            GenericLibraryMetaChip(
              icon: entry.hasMissingCover
                  ? Icons.image_not_supported_outlined
                  : Icons.image_outlined,
              label: entry.hasMissingCover ? 'Missing cover' : 'Cover ready',
              accent: accent,
            ),
            GenericLibraryMetaChip(
              icon: entry.hasMissingMetadata
                  ? Icons.manage_search
                  : Icons.fact_check_outlined,
              label:
                  entry.hasMissingMetadata ? 'Missing metadata' : 'Metadata ok',
              accent: accent,
            ),
            if (ownedItem?.condition != null)
              GenericLibraryMetaChip(
                icon: Icons.fact_check_outlined,
                label: ownedItem!.condition!,
                accent: accent,
              ),
            if (ownedItem?.grade != null)
              GenericLibraryMetaChip(
                icon: Icons.workspace_premium,
                label: ownedItem!.grade!,
                accent: accent,
              ),
            if (ownedItem?.pricePaidCents != null)
              GenericLibraryMetaChip(
                icon: Icons.attach_money,
                label: formatComicMoney(
                  ownedItem!.pricePaidCents,
                  ownedItem!.currency,
                ),
                accent: accent,
              ),
          ],
        ),
        if (entry.barcode != null && entry.barcode!.isNotEmpty) ...[
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xAA151515),
              border: Border.all(color: accent.withValues(alpha: 0.28)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.view_week_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.barcode!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.1,
                            color: kClzTextMuted,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class GenericInspectorPrimaryActions extends StatelessWidget {
  const GenericInspectorPrimaryActions({
    super.key,
    required this.entry,
    required this.type,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
  });

  final LibraryWorkspaceEntry entry;
  final LibraryTypeConfig type;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;

  @override
  Widget build(BuildContext context) {
    if (entry.isOwned) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          OutlinedButton.icon(
            onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
            icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
            label: Text(
              entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
            ),
          ),
          FilledButton.icon(
            onPressed: onRemoveOwned,
            icon: const Icon(Icons.remove_circle_outline),
            label: Text('Remove ${type.singularLabel.toLowerCase()}'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAddOwned,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add to collection'),
        ),
        const SizedBox(height: 8),
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
