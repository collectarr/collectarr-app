import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
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

class ComicInspectorHero extends ConsumerWidget {
  const ComicInspectorHero({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final entry = request.entry;
    final ownedItem = request.ownedItem;
    final surface = palette.surface;
    final border =
        palette.divider.withValues(alpha: palette.isDark ? 0.82 : 0.52);
    final ink = palette.textPrimary;
    final muted = palette.textMuted;
    final ownedItemId = resolveLibraryOwnedItemId(entry, ownedItem);
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
    final referenceLabel =
        (entry.itemNumber?.trim().isNotEmpty == true
                ? '#${entry.itemNumber!.trim()}'
                : null) ??
            entry.primaryReferenceLabel ??
            libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            request.type.singularLabel.toUpperCase();
    final seriesLabel =
      entry.series?.seriesTitle?.trim().isNotEmpty == true
        ? entry.series!.seriesTitle!.trim()
        : null;
    final editionLabel =
        entry.publishing?.subtitle?.trim().isNotEmpty == true
            ? entry.publishing!.subtitle!.trim()
            : entry.referenceFormatLabel?.trim().isNotEmpty == true
                ? entry.referenceFormatLabel!.trim()
                : entry.variant?.trim().isNotEmpty == true
                    ? entry.variant!.trim()
                    : 'Regular edition';
    final formatLabel = entry.referenceFormatLabel?.trim().isNotEmpty == true
      ? entry.referenceFormatLabel!.trim()
      : null;
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString() ?? '-';
    final publisherLabel = [
      if (entry.publisher?.trim().isNotEmpty == true) entry.publisher!.trim(),
      if (entry.publishing?.imprint?.trim().isNotEmpty == true)
      entry.publishing!.imprint!.trim(),
    ].join(' / ');
    final statusLabel = entry.isOwned
        ? 'Owned'
        : entry.isWishlisted
            ? 'Wishlist'
            : 'Not owned';
    final synopsis = entry.synopsis?.trim();
    final hasBackCover = localBack != null || ownedItemId != null;
    final slabLabel = librarySlabMarkerLabel(
      ownedItem?.rawOrSlabbed,
      ownedItem?.gradingCompany,
    );
    final slabGrade = ownedItem?.grade?.trim();
    final showSlabOverlay =
        ownedItem?.rawOrSlabbed?.trim().toLowerCase() == 'slabbed' &&
        slabLabel != null &&
        slabGrade != null &&
        slabGrade.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 680;
        final cover = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: stacked ? 112 : 122,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Stack(
                  children: [
                    LibraryInteractiveCover(
                      title: entry.resolvedTitle,
                      itemNumber: entry.itemNumber,
                      imageUrl: entry.displayCoverUrl,
                      localBytes: localFront,
                      secondaryLocalBytes: localBack,
                      ownedItemId: ownedItemId,
                      accentColor: request.accent,
                      enableHoverCue: true,
                      onMissingSecondaryPressed: ownedItemId == null || db == null
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
                    if (showSlabOverlay)
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
            const SizedBox(height: 1),
            _ComicCoverToggleRow(
              accent: request.accent,
              ink: ink,
              muted: muted,
              hasBackCover: hasBackCover,
            ),
          ],
        );

        final infoColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ComicMetaBadge(label: 'Edition', value: editionLabel),
                _ComicMetaBadge(
                  label: 'Status',
                  value: statusLabel,
                  icon: _ComicCollectionStatusIcon(
                    owned: entry.isOwned,
                    wishlisted: entry.isWishlisted,
                    accent: request.accent,
                    muted: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: border),
                color: Color.alphaBlend(
                  request.accent.withValues(alpha: 0.02),
                  surface,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
                child: Column(
                  children: [
                    if (seriesLabel != null)
                      _ComicDetailLine(label: 'Series', value: seriesLabel),
                    _ComicDetailLine(label: 'Issue', value: referenceLabel),
                    if (formatLabel != null)
                      _ComicDetailLine(label: 'Format', value: formatLabel),
                    _ComicDetailLine(label: 'Release', value: releaseLabel),
                    if (publisherLabel.isNotEmpty)
                      _ComicDetailLine(label: 'Publisher', value: publisherLabel),
                    if (entry.barcode?.trim().isNotEmpty == true)
                      _ComicDetailLine(label: 'Barcode', value: entry.barcode!.trim()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Plot Summary',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.18,
                    height: 1,
                    fontSize: 7.8,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              synopsis?.isNotEmpty == true ? synopsis! : 'No plot available.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ink,
                    height: 1.18,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    fontSize: 8.6,
                  ),
              textAlign: TextAlign.start,
            ),
          ],
        );

        final mainBody = _ComicHeroBlock(
          surface: surface,
          border: border,
          title: entry.resolvedTitle,
          overline: seriesLabel,
          referenceLabel: referenceLabel,
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
    required this.referenceLabel,
    required this.accent,
    required this.child,
  });

  final Color surface;
  final Color border;
  final String title;
  final String? overline;
  final String referenceLabel;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overline != null && overline!.trim().isNotEmpty) ...[
              Text(
                overline!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: appPalette(context).textMuted,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.12,
                    ),
              ),
              const SizedBox(height: 3),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                          height: 1,
                          fontSize: 12.8,
                        ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  referenceLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: appPalette(context).textMuted,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontSize: 8,
                        letterSpacing: 0.14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            child,
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: palette.divider),
        color: palette.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.08,
                ),
          ),
        ],
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
                fontSize: 8.2,
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
                  fontSize: 8.4,
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
            width: 38,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.16,
                    height: 1,
                    fontSize: 7.8,
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
                    height: 1.08,
                    fontSize: 8.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicCoverToggleRow extends StatelessWidget {
  const _ComicCoverToggleRow({
    required this.accent,
    required this.ink,
    required this.muted,
    required this.hasBackCover,
  });

  final Color accent;
  final Color ink;
  final Color muted;
  final bool hasBackCover;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.circle, size: 5, color: accent),
        const SizedBox(width: 2),
        Text(
          'Front',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
                fontSize: 7.5,
              ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.circle,
          size: 5,
          color: hasBackCover ? muted : muted.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 2),
        Text(
          'Back',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: hasBackCover ? muted : muted.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                fontSize: 7.5,
              ),
        ),
      ],
    );
  }
}

