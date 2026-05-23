import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/book_author_spotlight.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InspectorHero extends StatelessWidget {
  const InspectorHero({
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
        final cover = Consumer(
          builder: (context, ref, _) {
            final ownedItemId = entry.ownedItemId;
            final db = ref.watch(localDatabaseProvider);
            final localFront = ownedItemId == null
                ? null
                : ref.watch(
                    localItemImageProvider((
                      ownedItemId: ownedItemId,
                      imageType: 'front_cover',
                    )),
                  ).value;
            final localBack = ownedItemId == null
                ? null
                : ref.watch(
                    localItemImageProvider((
                      ownedItemId: ownedItemId,
                      imageType: 'back_cover',
                    )),
                  ).value;
            return SizedBox(
              width: wide ? 146 : 174,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: LibraryInteractiveCover(
                  title: entry.title,
                  itemNumber: entry.itemNumber,
                  imageUrl: entry.displayCoverUrl,
                  localBase64: localFront,
                  secondaryLocalBase64: localBack,
                  ownedItemId: entry.ownedItemId,
                  accentColor: accent,
                  onMissingSecondaryPressed: ownedItemId == null
                      ? null
                      : () async {
                          final savedType = await pickAndStoreOwnedItemImage(
                            context: context,
                            db: db,
                            ownedItemId: ownedItemId,
                            imageType: 'back_cover',
                          );
                          if (savedType == 'back_cover') {
                            ref.invalidate(
                              localItemImageProvider((
                                ownedItemId: ownedItemId,
                                imageType: 'back_cover',
                              )),
                            );
                          }
                        },
                ),
              ),
            );
          },
        );
        final info = _InspectorHeroInfo(
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

class _InspectorHeroInfo extends StatelessWidget {
  const _InspectorHeroInfo({
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
              LibraryItemPill(
                label: entry.itemNumber!,
                color: kAppHighlight,
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
        if (entry.mediaType == 'book' && (entry.creators?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 10),
          BookAuthorSpotlight(
            creators: entry.creators!,
            accent: accent,
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            LibraryMetaChip(
              icon: Icons.category_outlined,
              label: type.singularLabel,
              accent: accent,
            ),
            LibraryMetaChip(
              icon: Icons.inventory_2,
              label: entry.isOwned ? 'Owned' : 'Not owned',
              accent: accent,
            ),
            LibraryMetaChip(
              icon: entry.isWishlisted ? Icons.star : Icons.star_border,
              label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
              accent: accent,
            ),
            LibraryMetaChip(
              icon: entry.hasMissingCover
                  ? Icons.image_not_supported_outlined
                  : Icons.image_outlined,
              label: entry.hasMissingCover ? 'Missing cover' : 'Cover ready',
              accent: accent,
            ),
            LibraryMetaChip(
              icon: entry.hasMissingMetadata
                  ? Icons.manage_search
                  : Icons.fact_check_outlined,
              label:
                  entry.hasMissingMetadata ? 'Missing metadata' : 'Metadata ok',
              accent: accent,
            ),
            if (ownedItem?.condition != null)
              LibraryMetaChip(
                icon: Icons.fact_check_outlined,
                label: ownedItem!.condition!,
                accent: accent,
              ),
            if (ownedItem?.grade != null)
              LibraryMetaChip(
                icon: Icons.workspace_premium,
                label: ownedItem!.grade!,
                accent: accent,
              ),
            if (ownedItem?.pricePaidCents != null)
              LibraryMetaChip(
                icon: Icons.attach_money,
                label: formatMoney(
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
                            color: kAppTextMuted,
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
