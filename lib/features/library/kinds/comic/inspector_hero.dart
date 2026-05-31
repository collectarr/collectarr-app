import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
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
    final entry = request.entry;
    final ownedItem = request.ownedItem;
    final accent = request.accent;
    final palette = appPalette(context);
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
    final seriesTitle = entry.series?.seriesTitle?.trim();
    final subtitle = entry.publishing?.subtitle?.trim();
    final imprint = entry.publishing?.imprint?.trim();
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString();
    final topLine = [
      if (entry.publisher?.trim().isNotEmpty == true) entry.publisher!.trim(),
      if (imprint != null && imprint.isNotEmpty) imprint,
      if (releaseLabel != null && releaseLabel.isNotEmpty) releaseLabel,
    ].join('  •  ');
    final referenceLabel =
        libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            entry.primaryReferenceLabel;

    final formatBadges = <Widget>[];
    final seenFormats = <String>{};
    for (final edition in entry.editions) {
      final id = edition.physicalFormat;
      if (id != null && seenFormats.add(id)) {
        formatBadges.add(
          FormatBadge.fromFormat(
            id: id,
            label: edition.physicalFormatLabel ?? id,
          ),
        );
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              accent.withValues(alpha: palette.isDark ? 0.22 : 0.12),
              palette.panelRaised,
            ),
            Color.alphaBlend(
              accent.withValues(alpha: palette.isDark ? 0.08 : 0.04),
              palette.panel,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= kAppStackedBreakpoint;
            final cover = SizedBox(
              width: wide ? 154 : 176,
              child: LibraryInteractiveCover(
                title: entry.resolvedTitle,
                itemNumber: entry.itemNumber,
                imageUrl: entry.displayCoverUrl,
                localBytes: localFront,
                secondaryLocalBytes: localBack,
                ownedItemId: ownedItemId,
                accentColor: accent,
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
            );

            final info = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroKicker(
                  label: seriesTitle?.isNotEmpty == true ? seriesTitle! : 'Comic file',
                  accent: accent,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.resolvedTitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w900,
                                  height: 1.0,
                                ),
                      ),
                    ),
                    if (entry.itemNumber?.trim().isNotEmpty == true) ...[
                      const SizedBox(width: 8),
                      _IssueBadge(label: '#${entry.itemNumber!.trim()}'),
                    ],
                  ],
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: palette.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                if (topLine.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    topLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                if (formatBadges.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 5, runSpacing: 5, children: formatBadges),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (imprint != null && imprint.isNotEmpty)
                      _HeroMetaBadge(label: 'Imprint', value: imprint),
                    if (entry.barcode?.trim().isNotEmpty == true)
                      _HeroMetaBadge(label: 'Barcode', value: entry.barcode!.trim()),
                    if (referenceLabel?.trim().isNotEmpty == true)
                      _HeroMetaBadge(label: 'Ref', value: referenceLabel!.trim()),
                    if (entry.publishing?.seriesGroup?.trim().isNotEmpty == true)
                      _HeroMetaBadge(
                        label: 'Series Group',
                        value: entry.publishing!.seriesGroup!.trim(),
                      ),
                  ],
                ),
                if (entry.synopsis?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _HeroStoryPanel(
                    title: 'Plot',
                    body: entry.synopsis!.trim(),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _HeroStatusChip(
                      label: request.type.singularLabel,
                      accent: accent,
                    ),
                    _HeroStatusChip(
                      label: entry.isOwned ? 'Owned' : 'Not owned',
                      accent: accent,
                    ),
                    _HeroStatusChip(
                      label: entry.isWishlisted ? 'Wishlisted' : 'Wishlist',
                      accent: accent,
                    ),
                    if (ownedItem?.condition?.trim().isNotEmpty == true)
                      _HeroStatusChip(
                        label: ownedItem!.condition!.trim(),
                        accent: accent,
                      ),
                    if (ownedItem?.grade?.trim().isNotEmpty == true)
                      _HeroStatusChip(
                        label: ownedItem!.grade!.trim(),
                        accent: accent,
                      ),
                    if (entry.genres?.isNotEmpty == true)
                      _HeroStatusChip(
                        label: entry.genres!.first,
                        accent: accent,
                      ),
                  ],
                ),
              ],
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(width: 16),
                  Expanded(child: info),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: cover),
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

class _HeroKicker extends StatelessWidget {
  const _HeroKicker({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.35,
              ),
        ),
      ),
    );
  }
}

class _IssueBadge extends StatelessWidget {
  const _IssueBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kAppHighlight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
        ),
      ),
    );
  }
}

class _HeroMetaBadge extends StatelessWidget {
  const _HeroMetaBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStoryPanel extends StatelessWidget {
  const _HeroStoryPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              body,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatusChip extends StatelessWidget {
  const _HeroStatusChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.14),
          palette.panel,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}