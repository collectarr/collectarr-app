import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/book_author_spotlight.dart';
import 'package:collectarr_app/features/library/shared/library_info_chip.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

class LibraryDetailHero extends StatelessWidget {
  const LibraryDetailHero({
    super.key,
    required this.type,
    required this.item,
    required this.ownedItem,
    this.ownedCopies = const [],
    required this.accent,
    this.isOwned,
  });

  final LibraryTypeConfig type;
  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;
  final Color accent;
  final bool? isOwned;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final dto = item.dto;
    final resolvedOwnedItemId = resolveLibraryOwnedItemId(item, ownedItem);
    final resolvedIsOwned = isOwned ?? (ownedItem != null || dto.isOwned);
    final referenceLabel = libraryOwnedReferenceLabel(ownedItem,
            mediaType: item.source.catalogItem?.kind) ??
        dto.referenceFormatLabel;
    final totalCopies =
        ownedCopies.isEmpty ? (ownedItem == null ? 0 : 1) : ownedCopies.length;
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
    final totalsCurrency =
        _detailHeroValueCurrency(ownedCopies, ownedItem, item);
    final selectedCopyIndex = ownedItem == null || ownedCopies.isEmpty
        ? null
        : ownedCopies.indexWhere((i) => i.id == ownedItem!.id);
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
        value: formatNullableDate(ownedItem?.updatedAt ?? dto.updatedAt) ?? '-',
      ),
    ];
    final primaryChips = <Widget>[
      LibraryInfoChip(
        icon: Icons.inventory_2,
        label: resolvedIsOwned ? 'Owned' : 'Not owned',
        foreground: accent,
        background: palette.surfaceSubtle
            .withValues(alpha: palette.isDark ? 0.42 : 0.72),
        borderColor: palette.divider.withValues(alpha: 0.9),
      ),
      if (dto.isWishlisted)
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
      if (ownedItem?.condition != null)
        LibraryInfoChip(
          icon: Icons.fact_check_outlined,
          label: ownedItem!.condition!,
          foreground: accent,
          background: palette.surfaceSubtle
              .withValues(alpha: palette.isDark ? 0.42 : 0.72),
          borderColor: palette.divider.withValues(alpha: 0.9),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: palette.divider.withValues(alpha: 0.7),
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
                child: LibraryCoverImage(
                  title: dto.title,
                  itemNumber: dto.itemNumber,
                  imageUrl: dto.coverImageUrl,
                  targetCacheWidth: _targetCacheWidth(
                    context,
                    coverWidth: 140,
                  ),
                  ownedItemId: resolvedOwnedItemId,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dto.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                    ),
                    if (dto.seriesTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dto.seriesTitle!,
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
          if ((item.source.catalogItem?.creators ?? const []).isNotEmpty) ...[
            const SizedBox(height: 20),
            BookAuthorSpotlight(
              creators: item.source.catalogItem?.creators ?? const [],
              accent: accent,
            ),
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
  LibraryProjectionRuntime item,
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
  final itemCurrency = item.dto.currency?.trim();
  if (itemCurrency != null && itemCurrency.isNotEmpty) {
    return itemCurrency;
  }
  return null;
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
