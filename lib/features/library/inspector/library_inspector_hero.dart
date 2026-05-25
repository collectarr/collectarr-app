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
    final resolvedOwnedItemId = resolveLibraryOwnedItemId(entry, ownedItem);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= kAppStackedBreakpoint;
        final cover = Consumer(
          builder: (context, ref, _) {
            final ownedItemId = resolvedOwnedItemId;
            final db = ref.watch(localDatabaseProvider);
            final localFront = ownedItemId == null
                ? null
                : ref
                    .watch(
                      localItemImageProvider((
                        ownedItemId: ownedItemId,
                        imageType: 'front_cover',
                      )),
                    )
                    .value;
            final localBack = ownedItemId == null
                ? null
                : ref
                    .watch(
                      localItemImageProvider((
                        ownedItemId: ownedItemId,
                        imageType: 'back_cover',
                      )),
                    )
                    .value;
            return SizedBox(
              width: wide ? 146 : 174,
              child: LibraryInteractiveCover(
                title: entry.resolvedTitle,
                itemNumber: entry.itemNumber,
                imageUrl: entry.displayCoverUrl,
                localBase64: localFront,
                secondaryLocalBase64: localBack,
                ownedItemId: ownedItemId,
                accentColor: accent,
                enableHoverCue: false,
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
    final referenceLabel =
        libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            entry.primaryReferenceLabel;
    final referenceHierarchy = libraryReferenceHierarchySegments(
      mediaType: entry.mediaType,
      editions: entry.editions,
      editionId: ownedItem?.editionId ?? entry.referenceEditionId,
      variantId: ownedItem?.variantId ?? entry.referenceVariantId,
      bundleReleaseId:
          ownedItem?.bundleReleaseId ?? entry.referenceBundleReleaseId,
    );
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                entry.resolvedTitle,
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
        if (entry.mediaType == 'book' &&
            (entry.creators?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 10),
          BookAuthorSpotlight(
            creators: entry.creators!,
            accent: accent,
          ),
        ],
        const SizedBox(height: 10),
        if (referenceHierarchy.length > 1) ...[
          _ReferenceHierarchyLine(
            segments: referenceHierarchy,
            accent: accent,
          ),
          const SizedBox(height: 10),
        ],
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
            if (referenceLabel != null)
              LibraryMetaChip(
                icon: Icons.link_outlined,
                label: referenceLabel,
                accent: accent,
              ),
            if (entry.referenceFormatLabel != null)
              LibraryMetaChip(
                icon: Icons.album_outlined,
                label: 'Format: ${entry.referenceFormatLabel!}',
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

class _ReferenceHierarchyLine extends StatelessWidget {
  const _ReferenceHierarchyLine({
    required this.segments,
    required this.accent,
  });

  final List<String> segments;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x10000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < segments.length; i++) ...[
              Text(
                segments[i],
                style: TextStyle(
                  color:
                      i == segments.length - 1 ? Colors.white : kAppTextMuted,
                  fontWeight: i == segments.length - 1
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
              if (i < segments.length - 1)
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: accent.withValues(alpha: 0.8),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
