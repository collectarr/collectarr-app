import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/ui/library_info_chip.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_workspace_contributors.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

class LibraryDetailHero extends StatelessWidget {
  const LibraryDetailHero({
    super.key,
    required this.type,
    required this.item,
    required this.libraryEntry,
    required this.accent,
    this.isEntry,
    this.kindEntryContent,
  });

  final LibraryKindRegistration type;
  final LibraryProjectionView item;
  final LibraryEntrySummary? libraryEntry;
  final Color accent;
  final bool? isEntry;
  final Widget? kindEntryContent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final dto = item.dto;
    final presentation = libraryCardPresentationForEntry(item);
    final resolvedLibraryEntryRef =
        resolveLibraryEntrySummaryRef(item, libraryEntry);
    final resolvedIsEntry =
        isEntry ?? (libraryEntry != null || item.source.isEntry);
    final referenceLabel = presentation.format;
    final summaryFacts = <({String label, String value})>[
      (
        label: 'Status',
        value: resolvedIsEntry ? 'In collection' : 'Not collected'
      ),
      (
        label: 'Updated',
        value: formatNullableDate(
                libraryEntry?.updatedAt ?? item.source.updatedAt) ??
            '-',
      ),
    ];
    final primaryChips = <Widget>[
      LibraryInfoChip(
        icon: Icons.inventory_2,
        label: resolvedIsEntry ? 'In collection' : 'Not collected',
        foreground: accent,
        background: palette.surfaceSubtle
            .withValues(alpha: palette.isDark ? 0.42 : 0.72),
        borderColor: palette.divider.withValues(alpha: 0.9),
      ),
      if (item.source.isWishlisted)
        LibraryInfoChip(
          icon: Icons.star,
          label: 'Wishlisted',
          foreground: accent,
          background: palette.surfaceSubtle
              .withValues(alpha: palette.isDark ? 0.42 : 0.72),
          borderColor: palette.divider.withValues(alpha: 0.9),
        ),
      if (referenceLabel != null)
        LibraryInfoChip(
          icon: Icons.link_outlined,
          label: referenceLabel,
          foreground: accent,
          background: palette.surfaceSubtle
              .withValues(alpha: palette.isDark ? 0.42 : 0.72),
          borderColor: palette.divider.withValues(alpha: 0.9),
        ),
    ];
    final seriesTitle = presentation.seriesTitle;

    return Container(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.divider.withValues(alpha: 0.9),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: LibraryInteractiveCover(
                  title: dto.primaryLabel,
                  itemNumber: presentation.itemNumber,
                  imageUrl: dto.imageUrl,
                  targetCacheWidth: _targetCacheWidth(
                    context,
                    coverWidth: 140,
                  ),
                  fallbackAspectRatio:
                      1 / libraryViewProfileForKind(type.kind).coverGridHeightFactor,
                  libraryEntryRef: resolvedLibraryEntryRef,
                  enableHoverCue: false,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dto.primaryLabel,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                    ),
                    if (seriesTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        seriesTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: palette.textMuted,
                                ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: primaryChips,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        for (final fact in summaryFacts)
                          _DetailSummaryFact(
                            label: fact.label,
                            value: fact.value,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (kindEntryContent != null) ...[
            const SizedBox(height: 20),
            kindEntryContent!,
          ],
        ],
      ),
    );
  }

  int? _targetCacheWidth(
    BuildContext context, {
    required double coverWidth,
  }) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (pixelRatio <= 0) {
      return null;
    }
    final rawWidth = coverWidth * pixelRatio;
    return ((rawWidth / 64).ceil() * 64).toInt();
  }
}

class _DetailSummaryFact extends StatelessWidget {
  const _DetailSummaryFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
