import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
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
    final headerSurface = Color.alphaBlend(
      request.accent.withValues(alpha: palette.isDark ? 0.022 : 0.01),
      palette.surface,
    );
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
    final editionLabel =
        entry.publishing?.subtitle?.trim().isNotEmpty == true
            ? entry.publishing!.subtitle!.trim()
            : entry.referenceFormatLabel?.trim().isNotEmpty == true
                ? entry.referenceFormatLabel!.trim()
                : entry.variant?.trim().isNotEmpty == true
                    ? entry.variant!.trim()
                    : 'Regular edition';
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString() ?? '-';
    final publisherLabel = [
      if (entry.publisher?.trim().isNotEmpty == true) entry.publisher!.trim(),
      if (entry.publishing?.imprint?.trim().isNotEmpty == true)
      entry.publishing!.imprint!.trim(),
    ].join(' / ');
    final synopsis = entry.synopsis?.trim();
    final hasBackCover = localBack != null || ownedItemId != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 680;
        final cover = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: stacked ? 118 : 128,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: border, width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x25000000),
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child: LibraryInteractiveCover(
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
              ),
            ),
            const SizedBox(height: 2),
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
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: headerSurface,
                border: Border(bottom: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Text(
                        editionLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w800,
                          letterSpacing: 0.04,
                              height: 1,
                              fontSize: 9.25,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: border)),
                    ),
                    alignment: Alignment.center,
                    child: _ComicCollectionStatusIcon(
                      owned: entry.isOwned,
                      wishlisted: entry.isWishlisted,
                      accent: request.accent,
                      muted: muted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: border)),
              ),
              padding: const EdgeInsets.fromLTRB(2.5, 1, 2.5, 1),
              child: Column(
                children: [
                  _ComicDetailLine(label: 'Release', value: releaseLabel),
                  if (publisherLabel.isNotEmpty)
                    _ComicDetailLine(label: 'Publisher', value: publisherLabel),
                  if (entry.barcode?.trim().isNotEmpty == true)
                    _ComicDetailLine(label: 'Barcode', value: entry.barcode!.trim()),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
              padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: border.withValues(alpha: palette.isDark ? 0.92 : 0.82),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLOT SUMMARY',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            height: 1,
                            fontSize: 7.75,
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      synopsis?.isNotEmpty == true
                          ? synopsis!
                          : 'No plot available.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ink,
                            height: 1.1,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            fontSize: 8.5,
                          ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final mainBody = _ComicHeroBlock(
          surface: surface,
          headerSurface: headerSurface,
          border: border,
          title: entry.resolvedTitle,
          referenceLabel: referenceLabel,
          accent: request.accent,
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(height: 2),
                    infoColumn,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(width: 3),
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
    required this.headerSurface,
    required this.border,
    required this.title,
    required this.referenceLabel,
    required this.accent,
    required this.child,
  });

  final Color surface;
  final Color headerSurface;
  final Color border;
  final String title;
  final String referenceLabel;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: border),
          bottom: BorderSide(color: border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 17,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: headerSurface,
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.08,
                          height: 1,
                          fontSize: 12.5,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  referenceLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: appPalette(context).textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        fontSize: 8,
                        letterSpacing: 0.12,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
            child: child,
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
            width: 34,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    height: 1,
                    fontSize: 7.75,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.02,
                    fontSize: 8.5,
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
        Icon(Icons.circle, size: 6, color: accent),
        const SizedBox(width: 3),
        Text(
          'Front',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
          fontSize: 8,
              ),
        ),
        const SizedBox(width: 5),
        Icon(
          Icons.circle,
          size: 6,
          color: hasBackCover ? muted : muted.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 3),
        Text(
          'Back',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: hasBackCover ? muted : muted.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
                fontSize: 8,
              ),
        ),
      ],
    );
  }
}

