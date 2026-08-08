import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_mapper.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildComicInspectorHero(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  return ComicInspectorHero(request: request);
}

class ComicInspectorHero extends ConsumerStatefulWidget {
  const ComicInspectorHero({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  ConsumerState<ComicInspectorHero> createState() => _ComicInspectorHeroState();
}

class _ComicInspectorHeroState extends ConsumerState<ComicInspectorHero> {
  bool _showBackCover = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final palette = appPalette(context);
    final item = request.item;
    final dto = item.dto;
    final rawCatalog = item.source.catalogItem;
    final ComicCatalogItem? comic = rawCatalog is ComicCatalogItem
        ? rawCatalog as ComicCatalogItem
        : (rawCatalog is LibraryMetadataItem
            ? ComicCatalogMapper.mapMetadataItemToComic(rawCatalog)
            : null);
    final ownedItem = request.ownedItem;
    final surface = palette.surface;
    final border =
        palette.divider.withValues(alpha: palette.isDark ? 0.72 : 0.48);
    final ink = palette.textPrimary;
    final muted = palette.textMuted;
    final ownedItemId = resolveLibraryOwnedItemId(item, ownedItem);
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
    final db = ownedItemId == null ? null : ref.watch(localDatabaseProvider);
    final referenceLabel = (dto.itemNumber?.trim().isNotEmpty == true
            ? '#${dto.itemNumber!.trim()}'
            : null) ??
        dto.referenceFormatLabel ??
        libraryOwnedReferenceLabel(ownedItem, mediaType: item.source.catalogItem?.kind) ??
        request.type.singularLabel.toUpperCase();
    final seriesLabel = comic?.series?.seriesTitle?.trim().isNotEmpty == true
        ? comic!.series!.seriesTitle!.trim()
        : dto.seriesTitle?.trim().isNotEmpty == true
            ? dto.seriesTitle!.trim()
            : null;
    final editionLabel = comic?.publishing.subtitle?.trim().isNotEmpty == true
        ? comic!.publishing.subtitle!.trim()
        : dto.referenceFormatLabel?.trim().isNotEmpty == true
            ? dto.referenceFormatLabel!.trim()
            : dto.variant?.trim().isNotEmpty == true
                ? dto.variant!.trim()
                : 'Regular edition';
    final formatLabel = dto.referenceFormatLabel?.trim().isNotEmpty == true
        ? dto.referenceFormatLabel!.trim()
        : null;
    final releaseLabel = formatNullableDate(dto.releaseDate) ??
        dto.releaseDate?.year.toString() ??
        '-';
    final publisherLabel = [
      if (dto.publisher?.trim().isNotEmpty == true) dto.publisher!.trim(),
      if (comic?.publishing.imprint?.trim().isNotEmpty == true)
        comic!.publishing.imprint!.trim(),
    ].join(' / ');
    final subtitleParts = <String>[
      if (comic?.crossover?.trim().isNotEmpty == true) comic!.crossover!.trim(),
      if (comic?.storyArcs.isNotEmpty == true) comic!.storyArcs.first.trim(),
      if (dto.variant?.trim().isNotEmpty == true) dto.variant!.trim(),
    ];
    final subtitleLabel = subtitleParts.join(' • ');
    final isOwned = dto.isOwned || ownedItem != null;
    final statusLabel = isOwned
        ? 'Owned'
        : dto.isWishlisted
            ? 'Wishlist'
            : 'Not owned';
    final synopsis = dto.synopsis?.trim().isNotEmpty == true
        ? dto.synopsis?.trim()
        : comic?.plotSummary?.trim();
    final plotDescription = comic?.plotDescription?.trim();
    final comicDetails = ownedItem?.typedDetails is ComicOwnedDetails
        ? ownedItem!.typedDetails as ComicOwnedDetails
        : null;
    final slabLabel = librarySlabMarkerLabel(
      comicDetails?.rawOrSlabbed,
      comicDetails?.gradingCompany,
    );
    final slabGrade = ownedItem?.grade?.trim();
    final showSlabOverlay =
        comicDetails?.rawOrSlabbed?.trim().toLowerCase() == 'slabbed' &&
            slabLabel != null &&
            slabGrade != null &&
            slabGrade.isNotEmpty;
    final currentValue = ownedItem?.marketValueCents != null
        ? formatMoney(ownedItem!.marketValueCents, ownedItem.currency)
        : null;
    final gradeValueLabel = [
      if (ownedItem?.grade?.trim().isNotEmpty == true) ownedItem!.grade!.trim(),
      if (currentValue != null) currentValue,
    ].join('  •  ');
    final keyReason = comicDetails?.keyReason?.trim().isNotEmpty == true
        ? comicDetails!.keyReason!.trim()
        : null;
    final ebayQuery = [
      if (dto.barcode?.trim().isNotEmpty == true) dto.barcode!.trim(),
      if (seriesLabel != null) seriesLabel,
      if (referenceLabel.trim().isNotEmpty) referenceLabel,
      if (editionLabel.trim().isNotEmpty) editionLabel,
      if (ownedItem?.grade?.trim().isNotEmpty == true) ownedItem!.grade!.trim(),
    ].join(' ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 680;
        final hasBackCover = localBack?.isNotEmpty == true;
        final showBothCovers =
            hasBackCover && !stacked && constraints.maxWidth >= 860;

        Widget buildCoverFrame({
          required bool back,
          required double width,
        }) {
          return SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: border, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(
                          alpha: appPalette(context).isDark ? 0.5 : 0.16,
                        ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    LibraryInteractiveCover(
                      title: dto.title,
                      itemNumber: dto.itemNumber,
                      imageUrl: back ? null : (dto.coverImageUrl ?? comic?.displayCoverUrl),
                      localBytes: back ? localBack : localFront,
                      ownedItemId: back ? null : ownedItemId,
                      accentColor: request.accent,
                      fit: BoxFit.cover,
                      enableHoverCue: true,
                      enableSecondaryControl: false,
                      onMissingSecondaryPressed:
                          back || ownedItemId == null || db == null
                              ? null
                              : () async {
                                  final savedType =
                                      await pickAndStoreOwnedItemImage(
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
                    if (!back && showSlabOverlay)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: _ComicSlabCoverOverlay(
                          label: slabLabel,
                          grade: slabGrade,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        final coverWidth = stacked ? 120.0 : 140.0;
        final splitCoverWidth = stacked ? 120.0 : 116.0;
        final showBackInSingle = hasBackCover && _showBackCover;

        final cover = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBothCovers)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCoverFrame(back: false, width: splitCoverWidth),
                  const SizedBox(width: 6),
                  buildCoverFrame(back: true, width: splitCoverWidth),
                ],
              )
            else
              buildCoverFrame(
                back: showBackInSingle,
                width: coverWidth,
              ),
            if (!showBothCovers && hasBackCover) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  _ComicCoverToggleCheckbox(
                    label: 'Front',
                    value: !showBackInSingle,
                    onChanged: (value) {
                      if (!value || !mounted) {
                        return;
                      }
                      setState(() => _showBackCover = false);
                    },
                  ),
                  const SizedBox(width: 8),
                  _ComicCoverToggleCheckbox(
                    label: 'Back',
                    value: showBackInSingle,
                    onChanged: (value) {
                      if (!value || !mounted) {
                        return;
                      }
                      setState(() => _showBackCover = true);
                    },
                  ),
                ],
              ),
            ],
          ],
        );

        final infoColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitleLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  subtitleLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1.1,
                      ),
                ),
              ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ComicIssueBadge(referenceLabel: referenceLabel),
                _ComicMetaBadge(label: 'Edition', value: editionLabel),
                _ComicMetaBadge(
                  label: 'Status',
                  value: statusLabel,
                  icon: _ComicCollectionStatusIcon(
                    owned: isOwned,
                    wishlisted: dto.isWishlisted,
                    accent: request.accent,
                    muted: muted,
                  ),
                ),
              ],
            ),
            if (keyReason != null) ...[
              const SizedBox(height: 6),
              _ComicKeyReasonBanner(reason: keyReason),
            ],
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: border),
                      color: palette.surfaceSubtle.withValues(
                        alpha: palette.isDark ? 0.6 : 0.9,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Column(
                        children: [
                          if (seriesLabel != null)
                            _ComicDetailLine(
                                label: 'Series', value: seriesLabel),
                          if (formatLabel != null)
                            _ComicDetailLine(
                                label: 'Format', value: formatLabel),
                          _ComicDetailLine(
                              label: 'Release', value: releaseLabel),
                          if (publisherLabel.isNotEmpty)
                            _ComicDetailLine(
                                label: 'Publisher', value: publisherLabel),
                          if (dto.barcode?.trim().isNotEmpty == true)
                            _ComicDetailLine(
                                label: 'Barcode', value: dto.barcode!.trim()),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 126),
                  child: Column(
                    children: [
                      if (gradeValueLabel.isNotEmpty)
                        _ComicValueRibbon(
                          accent: request.accent,
                          label: gradeValueLabel,
                        ),
                      const SizedBox(height: 6),
                      _ComicEbayCard(
                        query: ebayQuery,
                        accent: request.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Plot',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 3),
            if (synopsis?.isNotEmpty == true) ...[
              Text(
                synopsis!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ink,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.start,
              ),
              if (plotDescription?.isNotEmpty == true)
                const SizedBox(height: 6),
            ],
            if (plotDescription?.isNotEmpty == true)
              Text(
                plotDescription!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ink.withValues(alpha: 0.85),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                textAlign: TextAlign.start,
              ),
            if (synopsis?.isEmpty != false && plotDescription?.isEmpty != false)
              Text(
                'No plot available.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: muted,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                textAlign: TextAlign.start,
              ),
          ],
        );

        final mainBody = _ComicHeroBlock(
          surface: surface,
          border: border,
          title: dto.title,
          overline: seriesLabel,
          accent: request.accent,
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(height: 1.5),
                    infoColumn,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(width: 1.5),
                    Expanded(child: infoColumn),
                  ],
                ),
        );

        return mainBody;
      },
    );
  }
}

class _ComicHeroBlock extends StatelessWidget {
  const _ComicHeroBlock({
    required this.surface,
    required this.border,
    required this.title,
    this.overline,
    required this.accent,
    required this.child,
  });

  final Color surface;
  final Color border;
  final String title;
  final String? overline;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overline != null && overline!.trim().isNotEmpty) ...[
              Text(
                overline!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: appPalette(context).textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ComicIssueBadge extends StatelessWidget {
  const _ComicIssueBadge({required this.referenceLabel});

  final String referenceLabel;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: palette.divider.withValues(alpha: 0.7)),
        color: Color.alphaBlend(
          palette.accent.withValues(alpha: palette.isDark ? 0.2 : 0.12),
          palette.surface,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        referenceLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.14,
            ),
      ),
    );
  }
}

class _ComicMetaBadge extends StatelessWidget {
  const _ComicMetaBadge({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.textMuted,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.08,
        );
    final valueStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.08,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: palette.divider.withValues(alpha: 0.7)),
        color: palette.surface,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            '$label ',
            style: labelStyle,
          ),
          Text(
            value,
            style: valueStyle,
          ),
        ],
      ),
    );
  }
}

class _ComicCoverToggleCheckbox extends StatelessWidget {
  const _ComicCoverToggleCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: (next) => onChanged(next == true),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComicSlabCoverOverlay extends StatelessWidget {
  const _ComicSlabCoverOverlay({
    required this.label,
    required this.grade,
  });

  final String label;
  final String grade;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      key: const ValueKey('comic-inspector-slab-overlay'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(
            color: palette.surface.withValues(alpha: 0.6),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.16,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Text(
                grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicKeyReasonBanner extends StatelessWidget {
  const _ComicKeyReasonBanner({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_outlined, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicValueRibbon extends StatelessWidget {
  const _ComicValueRibbon({required this.accent, required this.label});

  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.1), palette.surface),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _ComicEbayCard extends StatelessWidget {
  const _ComicEbayCard({
    required this.query,
    required this.accent,
  });

  final String query;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return InkWell(
      onTap: query.trim().isEmpty ? null : () => launchEbaySearch(query),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: palette.divider),
          color: palette.surface,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Icon(Icons.storefront_outlined, size: 13, color: accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Find sold listings on eBay',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.open_in_new,
              size: 12,
              color: palette.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComicCollectionStatusIcon extends StatelessWidget {
  const _ComicCollectionStatusIcon({
    required this.owned,
    required this.wishlisted,
    required this.accent,
    required this.muted,
  });

  final bool owned;
  final bool wishlisted;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final icon = owned
        ? Icons.check_circle
        : wishlisted
            ? Icons.favorite
            : Icons.remove_circle_outline;
    final color = owned
        ? accent
        : wishlisted
            ? Colors.red.shade400
            : muted;
    return Icon(icon, size: 12, color: color);
  }
}

class _ComicDetailLine extends StatelessWidget {
  const _ComicDetailLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.16,
                    height: 1,
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
