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
    final statusLabel = entry.isOwned
        ? 'In Collection'
        : entry.isWishlisted
            ? 'Wish list'
            : 'Catalog only';

    return LayoutBuilder(
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

        final detailsColumn = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editionLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              if (publisherLabel.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ComicPublisherMark(
                      label: _publisherMarkLabel(entry.publisher, imprint),
                      accent: request.accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Publisher',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            publisherLabel,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: ink,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              _ComicDetailLine(label: 'Release', value: releaseLabel),
              if (imprint != null && imprint.isNotEmpty)
                _ComicDetailLine(label: 'Imprint', value: imprint),
              if (entry.referenceFormatLabel?.trim().isNotEmpty == true)
                _ComicDetailLine(
                  label: 'Format',
                  value: entry.referenceFormatLabel!.trim(),
                ),
              if (entry.barcode?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _ComicBarcodeCard(
                  barcode: entry.barcode!.trim(),
                  accent: request.accent,
                  border: border,
                  palette: palette,
                ),
              ],
            ],
          ),
        );

        final plotColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _ComicCollectionStatusIcon(
                  owned: entry.isOwned,
                  wishlisted: entry.isWishlisted,
                  accent: request.accent,
                  muted: muted,
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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

        final mainBody = _ComicHeroBlock(
          surface: surface,
          border: border,
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cover,
                    const SizedBox(width: 16),
                    detailsColumn,
                    const SizedBox(width: 20),
                    Expanded(child: plotColumn),
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
                        Expanded(child: detailsColumn),
                      ],
                    ),
                    const SizedBox(height: 14),
                    plotColumn,
                  ],
                ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      entry.resolvedTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: request.accent,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: palette.surfaceSubtle,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      referenceLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            mainBody,
          ],
        );
      },
    );
  }
}

class _ComicHeroBlock extends StatelessWidget {
  const _ComicHeroBlock({
    required this.surface,
    required this.border,
    required this.child,
  });

  final Color surface;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
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
    return Icon(icon, size: 18, color: color);
  }
}

class _ComicPublisherMark extends StatelessWidget {
  const _ComicPublisherMark({
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: SizedBox(
        width: 46,
        height: 46,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicBarcodeCard extends StatelessWidget {
  const _ComicBarcodeCard({
    required this.barcode,
    required this.accent,
    required this.border,
    required this.palette,
  });

  final String barcode;
  final Color accent;
  final Color border;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            Row(
              children: [
                Icon(Icons.qr_code_scanner_outlined, size: 18, color: palette.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    barcode,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Find sold listings on eBay',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
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

String _publisherMarkLabel(String? publisher, String? imprint) {
  final seed = imprint?.trim().isNotEmpty == true
      ? imprint!.trim()
      : publisher?.trim().isNotEmpty == true
          ? publisher!.trim()
          : 'COMIC';
  final compact = seed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(3)
      .map((part) => part.substring(0, 1).toUpperCase())
      .join();
  if (compact.isNotEmpty) {
    return compact;
  }
  final normalized = seed.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  if (normalized.isEmpty) {
    return 'COM';
  }
  return normalized.length <= 3 ? normalized : normalized.substring(0, 3);
}