import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/providers/local_cover_image_provider.dart';
import 'package:collectarr_app/features/library/inspector/item_image_picker.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/book_author_spotlight.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryDetailHero extends StatelessWidget {
  const LibraryDetailHero({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    this.ownedCopies = const [],
    required this.accent,
    this.isOwned,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;
  final Color accent;
  final bool? isOwned;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final resolvedOwnedItemId = resolveLibraryOwnedItemId(entry, ownedItem);
    final resolvedIsOwned = isOwned ?? (ownedItem != null || entry.isOwned);
    final referenceLabel =
        libraryOwnedReferenceLabel(ownedItem, mediaType: entry.mediaType) ??
            entry.primaryReferenceLabel;
    final releaseLabel =
        formatNullableDate(entry.releaseDate) ?? entry.releaseYear?.toString();
    final totalCopies = ownedCopies.isEmpty ? (ownedItem == null ? 0 : 1) : ownedCopies.length;
    final totalQuantity = ownedCopies.isEmpty
        ? (ownedItem?.quantity ?? 0)
        : ownedCopies.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalPaidCents = _sumOwnedValueCents(
      ownedCopies,
      (item) => item.pricePaidCents,
    );
    final totalMarketValueCents = _sumOwnedValueCents(
      ownedCopies,
      (item) => item.marketValueCents,
    );
    final totalsCurrency = _detailHeroValueCurrency(ownedCopies, ownedItem, entry);
    final selectedCopyIndex = ownedItem == null || ownedCopies.isEmpty
        ? null
        : ownedCopies.indexWhere((item) => item.id == ownedItem!.id);
    final summaryFacts = <({String label, String value})>[
      (label: 'Status', value: resolvedIsOwned ? 'Owned' : 'Not owned'),
      (label: 'Quantity', value: totalQuantity.toString()),
      if (totalCopies > 1) (label: 'Copies', value: totalCopies.toString()),
      if (totalCopies > 1 && totalPaidCents != null)
        (
          label: 'Total paid',
          value: formatMoney(totalPaidCents, totalsCurrency),
        ),
      if (totalCopies > 1 && totalMarketValueCents != null)
        (
          label: 'Total value',
          value: formatMoney(totalMarketValueCents, totalsCurrency),
        ),
      if (selectedCopyIndex != null && selectedCopyIndex >= 0)
        (label: 'Selected', value: 'Copy ${selectedCopyIndex + 1}'),
      (
        label: 'Updated',
        value: formatNullableDate(ownedItem?.updatedAt ?? entry.updatedAt) ?? '-',
      ),
    ];
    final primaryChips = <Widget>[
      _DetailHeaderChip(
        icon: Icons.inventory_2,
        label: resolvedIsOwned ? 'Owned' : 'Not owned',
        accent: accent,
      ),
      if (entry.isWishlisted)
        _DetailHeaderChip(
          icon: Icons.star,
          label: 'Wishlisted',
          accent: accent,
        ),
      if (referenceLabel != null)
        _DetailHeaderChip(
          icon: Icons.link_outlined,
          label: referenceLabel,
          accent: accent,
        ),
      if (ownedItem?.condition != null)
        _DetailHeaderChip(
          icon: Icons.fact_check_outlined,
          label: ownedItem!.condition!,
          accent: accent,
        ),
      if (ownedItem?.grade != null)
        _DetailHeaderChip(
          icon: Icons.workspace_premium,
          label: ownedItem!.grade!,
          accent: accent,
        ),
      if (ownedItem?.keyComic == true)
        _DetailHeaderChip(
          icon: Icons.label_important,
          label: ownedItem!.keyReason ?? 'Key item',
          accent: accent,
        ),
      if (ownedItem?.rawOrSlabbed != null || ownedItem?.gradingCompany != null)
        _DetailHeaderChip(
          icon: Icons.verified_outlined,
          label: librarySlabMarkerLabel(
                ownedItem?.rawOrSlabbed,
                ownedItem?.gradingCompany,
              ) ??
              'Collector copy',
          accent: accent,
        ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          bottom: BorderSide(
            color: palette.divider.withValues(alpha: 0.92),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
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
                  width: wide ? 164 : 138,
                  child: SlabFrameOverlay.maybeWrap(
                    rawOrSlabbed: ownedItem?.rawOrSlabbed,
                    gradingCompany: ownedItem?.gradingCompany,
                    grade: ownedItem?.grade,
                    labelType: ownedItem?.labelType,
                    child: LibraryInteractiveCover(
                      title: entry.resolvedTitle,
                      itemNumber: entry.itemNumber,
                      imageUrl: entry.displayCoverUrl,
                      localBytes: localFront,
                      secondaryLocalBytes: localBack,
                      ownedItemId: ownedItemId,
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
            final info = Column(
              crossAxisAlignment:
                  wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  entry.resolvedTitle,
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        height: 1.02,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    type.singularLabel,
                    if (entry.itemNumber != null &&
                        entry.itemNumber!.isNotEmpty)
                      '#${entry.itemNumber}',
                    if (entry.variant != null && entry.variant!.isNotEmpty)
                      entry.variant,
                    if (entry.publisher != null && entry.publisher!.isNotEmpty)
                      entry.publisher,
                    if (releaseLabel != null) releaseLabel,
                  ].whereType<String>().join(' | '),
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                      ),
                ),
                if (type.capabilities.showsCreatorSpotlight &&
                    (entry.creators?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 10),
                  BookAuthorSpotlight(
                    creators: entry.creators!,
                    accent: accent,
                    centered: !wide,
                  ),
                ],
                if (primaryChips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                    children: primaryChips,
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: wide ? WrapAlignment.start : WrapAlignment.center,
                  children: [
                    for (final fact in summaryFacts)
                      _DetailSummaryFact(
                        label: fact.label,
                        value: fact.value,
                      ),
                    if (entry.referenceFormatLabel != null)
                      _DetailSummaryFact(
                        label: 'Format',
                        value: entry.referenceFormatLabel!,
                      ),
                    if (entry.video?.runtimeMinutes != null)
                      _DetailSummaryFact(
                        label: 'Runtime',
                        value: '${entry.video!.runtimeMinutes} min',
                      ),
                    if (entry.music?.trackCount != null)
                      _DetailSummaryFact(
                        label: 'Tracks',
                        value: '${entry.music!.trackCount}',
                      ),
                    if (_detailPlatformLabel(entry.rawPlatforms)
                        case final platformLabel?)
                      _DetailSummaryFact(
                        label: 'Platform',
                        value: platformLabel,
                      ),
                    if (entry.hasMissingCover)
                      const _DetailSummaryFact(
                        label: 'Cover',
                        value: 'Missing',
                      ),
                    if (entry.hasMissingMetadata)
                      const _DetailSummaryFact(
                        label: 'Metadata',
                        value: 'Missing',
                      ),
                  ],
                ),
                if (entry.synopsis != null &&
                    entry.synopsis!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    entry.synopsis!,
                    maxLines: wide ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.textPrimary,
                          height: 1.28,
                        ),
                  ),
                ],
              ],
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  cover,
                  const SizedBox(width: 14),
                  Expanded(child: info),
                ],
              );
            }
            return Column(
              children: [
                cover,
                const SizedBox(height: 10),
                info,
              ],
            );
          },
        ),
      ),
    );
  }
}

int? _sumOwnedValueCents(
  List<OwnedItem> items,
  int? Function(OwnedItem item) selector,
) {
  var hasValue = false;
  var total = 0;
  for (final item in items) {
    final value = selector(item);
    if (value == null) {
      continue;
    }
    hasValue = true;
    total += value;
  }
  return hasValue ? total : null;
}

String? _detailHeroValueCurrency(
  List<OwnedItem> ownedCopies,
  OwnedItem? ownedItem,
  LibraryWorkspaceEntry entry,
) {
  for (final copy in ownedCopies) {
    final currency = copy.currency?.trim();
    if (currency != null && currency.isNotEmpty) {
      return currency;
    }
  }
  final ownedCurrency = ownedItem?.currency?.trim();
  if (ownedCurrency != null && ownedCurrency.isNotEmpty) {
    return ownedCurrency;
  }
  final entryCurrency = entry.currency?.trim();
  if (entryCurrency != null && entryCurrency.isNotEmpty) {
    return entryCurrency;
  }
  return null;
}

String? _detailPlatformLabel(List<String>? platforms) {
  if (platforms == null || platforms.isEmpty) {
    return null;
  }
  final values = platforms
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  return values.join(', ');
}

class _DetailHeaderChip extends StatelessWidget {
  const _DetailHeaderChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle.withValues(alpha: palette.isDark ? 0.42 : 0.72),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: palette.divider.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: accent.withValues(alpha: 0.92)),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
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
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
