import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
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
              width: wide ? 92 : 108,
              child: LibraryInteractiveCover(
                title: entry.resolvedTitle,
                itemNumber: entry.itemNumber,
                imageUrl: entry.displayCoverUrl,
                localBytes: localFront,
                secondaryLocalBytes: localBack,
                ownedItemId: ownedItemId,
                accentColor: accent,
                enableHoverCue: true,
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
            border: Border(
              left: BorderSide(color: accent, width: 3),
              bottom: BorderSide(color: appPalette(context).divider),
            ),
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.04),
              appPalette(context).surface,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 10),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(height: 8),
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
    // Collect unique format IDs from editions.
    final formatBadges = <Widget>[];
    final seenFormats = <String>{};
    for (final edition in entry.editions) {
      final id = edition.physicalFormat;
      if (id != null && seenFormats.add(id)) {
        formatBadges.add(FormatBadge.fromFormat(
          id: id,
          label: edition.physicalFormatLabel ?? id,
        ));
      }
    }
    final genreText = entry.genres?.join('  |  ');
    final countryLangRow = [
      if (entry.country != null) entry.country!,
      if (entry.language != null) entry.language!,
      if (entry.video?.runtimeMinutes != null)
        '${entry.video!.runtimeMinutes} min',
    ].join('  |  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Title ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                entry.resolvedTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
              ),
            ),
            if (entry.itemNumber != null && entry.itemNumber!.isNotEmpty) ...[
              const SizedBox(width: 6),
              LibraryItemPill(
                label: entry.itemNumber!,
                color: kAppHighlight,
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        // ── Publisher (Year) ──
        Text(
          [
            if (entry.publisher != null && entry.publisher!.isNotEmpty)
              entry.publisher,
            if (releaseLabel != null) '($releaseLabel)',
          ].whereType<String>().join(' '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        // ── Format badges (prominent, CLZ-style) ──
        if (formatBadges.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(spacing: 5, runSpacing: 5, children: formatBadges),
        ],
        // ── Barcode ──
        if (entry.barcode != null && entry.barcode!.isNotEmpty) ...[
          const SizedBox(height: 6),
          _InspectorHeroInfoBlock(
            label: 'Barcode',
            child: Row(
              children: [
                Icon(
                  Icons.view_week_outlined,
                  size: 16,
                  color: appPalette(context).textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.barcode!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          letterSpacing: 1.1,
                          color: appPalette(context).textMuted,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // ── Genres (pipe-separated like CLZ) ──
        if (genreText != null && genreText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            genreText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: kAppTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        // ── Country | Language | Runtime ──
        if (countryLangRow.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            countryLangRow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        // ── Synopsis ──
        if (entry.synopsis != null && entry.synopsis!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _InspectorHeroInfoBlock(
            label: 'Summary',
            child: Text(
              entry.synopsis!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kAppTextSecondary,
                    height: 1.3,
                  ),
            ),
          ),
        ],
        if (type.capabilities.showsCreatorSpotlight &&
            (entry.creators?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 8),
          BookAuthorSpotlight(
            creators: entry.creators!,
            accent: accent,
          ),
        ],
        if (referenceHierarchy.length > 1) ...[
          const SizedBox(height: 8),
          const _InspectorHeroCaption(label: 'Reference'),
          const SizedBox(height: 4),
          _ReferenceHierarchyLine(
            segments: referenceHierarchy,
            accent: accent,
          ),
        ],
        // ── Status chips ──
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
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
      ],
    );
  }
}

class _InspectorHeroInfoBlock extends StatelessWidget {
  const _InspectorHeroInfoBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InspectorHeroCaption(label: label),
        const SizedBox(height: 3),
        child,
      ],
    );
  }
}

class _InspectorHeroCaption extends StatelessWidget {
  const _InspectorHeroCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: appPalette(context).textMuted,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.25,
          ),
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
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < segments.length; i++) ...[
              Text(
                segments[i],
                style: TextStyle(
                  color: i == segments.length - 1
                      ? palette.textPrimary
                      : palette.textMuted,
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
