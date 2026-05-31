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
    final surface = Color.alphaBlend(
      request.accent.withValues(alpha: palette.isDark ? 0.04 : 0.02),
      palette.isDark ? palette.panelRaised : Colors.white,
    );
    final border = palette.divider.withValues(alpha: palette.isDark ? 1 : 0.55);
    final ink = palette.textPrimary;
    final muted = palette.textMuted;
    final badgeSurface = palette.isDark ? palette.surface : Colors.white;
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
        libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            entry.primaryReferenceLabel ??
            (entry.itemNumber?.trim().isNotEmpty == true
                ? '#${entry.itemNumber!.trim()}'
                : request.type.singularLabel.toUpperCase());
    final seriesTitle = entry.series?.seriesTitle?.trim();
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
    final imprint = entry.publishing?.imprint?.trim();
    final publisherLabel = [
      if (entry.publisher?.trim().isNotEmpty == true) entry.publisher!.trim(),
      if (imprint != null && imprint.isNotEmpty) imprint,
    ].join(' / ');
    final synopsis = entry.synopsis?.trim();
    final hasBackCover = localBack != null || ownedItemId != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final cover = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: wide ? 210 : 180,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: border, width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x25000000),
                          blurRadius: 8,
                          offset: Offset(1, 2),
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
                const SizedBox(height: 8),
                _ComicCoverToggleRow(
                  accent: request.accent,
                  ink: ink,
                  muted: muted,
                  hasBackCover: hasBackCover,
                ),
              ],
            );

            final summaryColumn = ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editionLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8, bottom: 4),
                            child: Text(
                              'Release:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              releaseLabel,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (publisherLabel.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      publisherLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                    ),
                  ],
                  if (imprint != null && imprint.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Imprint',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      imprint,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                  if (entry.barcode?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.qr_code_2, size: 18, color: muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.barcode!.trim(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ink,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.surfaceSubtle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find sold listings on eBay',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: request.accent,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'CLZ may be compensated for purchases made',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: muted,
                                    height: 1.25,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );

            final descriptionBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _ComicOwnedBadge(
                    accent: request.accent,
                    owned: entry.isOwned,
                    muted: muted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Plot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  synopsis?.isNotEmpty == true ? synopsis! : 'No plot available.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ink,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            );

            final body = wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cover,
                      const SizedBox(width: 14),
                      summaryColumn,
                      const SizedBox(width: 18),
                      Expanded(child: descriptionBlock),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cover,
                          const SizedBox(width: 12),
                          Expanded(child: summaryColumn),
                        ],
                      ),
                      const SizedBox(height: 14),
                      descriptionBlock,
                    ],
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (seriesTitle != null &&
                    seriesTitle.isNotEmpty &&
                    seriesTitle != entry.resolvedTitle) ...[
                  Text(
                    seriesTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                ],
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: border)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.resolvedTitle,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: request.accent,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _ComicReferenceBadge(
                          label: referenceLabel,
                          surface: badgeSurface,
                          border: border,
                          ink: ink,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                body,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ComicReferenceBadge extends StatelessWidget {
  const _ComicReferenceBadge({
    required this.label,
    required this.surface,
    required this.border,
    required this.ink,
  });

  final String label;
  final Color surface;
  final Color border;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 1.6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ink,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _ComicOwnedBadge extends StatelessWidget {
  const _ComicOwnedBadge({
    required this.accent,
    required this.owned,
    required this.muted,
  });

  final Color accent;
  final bool owned;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: owned ? accent : muted.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              owned ? Icons.check : Icons.remove,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              owned ? 'In Collection' : 'Catalog only',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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
        Icon(Icons.circle, size: 10, color: accent),
        const SizedBox(width: 6),
        Text(
          'Front',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ink,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.circle,
          size: 10,
          color: hasBackCover ? muted : muted.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 6),
        Text(
          'Back',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: hasBackCover ? muted : muted.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}