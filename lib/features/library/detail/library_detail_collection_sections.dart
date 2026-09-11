import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

class LibraryDetailPersonalSection extends StatelessWidget {
  const LibraryDetailPersonalSection({
    super.key,
    this.type,
    required this.item,
    this.ownedItemDispatch,
    this.ownedSummary,
    this.ownedCopies = const [],
    this.trackingLifecycle,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindModule? type;
  final LibraryProjectionView item;
  final LibraryOwnedItemDispatch? ownedItemDispatch;
  final OwnedItemSummary? ownedSummary;
  final List<OwnedItemSummary> ownedCopies;
  final TrackingLifecycle? trackingLifecycle;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final effectiveOwnedCopies = ownedCopies.isNotEmpty
        ? ownedCopies
        : ownedSummary == null
            ? const <OwnedItemSummary>[]
            : <OwnedItemSummary>[ownedSummary!];
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final paid = formatMoney(
      ownedSummary?.pricePaidCents ?? item.source.pricePaidCents,
      ownedSummary?.currency ?? adapter?.currency,
    );
    final currentValue = formatMoney(
      ownedSummary?.marketValueCents,
      ownedSummary?.currency,
    );
    final currency = ownedSummary?.currency ?? adapter?.currency;
    final sellPrice = formatMoney(ownedSummary?.sellPriceCents, currency);
    final kindPersonalFields = type?.inspector.buildPersonalDetailFields(
          context: context,
          item: item,
          ownedItem: ownedSummary,
          ownedItemDispatch: ownedItemDispatch ?? item.source.ownedItemDispatch,
          currency: currency,
        ) ??
        const [];
    final profitLoss = _detailProfitLossLabel(ownedSummary);
    final totalPaidCents = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.pricePaidCents,
    );
    final totalMarketValueCents = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.marketValueCents,
    );
    final totalsCurrency =
        _detailValueCurrency(effectiveOwnedCopies, ownedSummary, item);
    final totalPaid = totalPaidCents == null
        ? ''
        : formatMoney(totalPaidCents, totalsCurrency);
    final totalCurrentValue = totalMarketValueCents == null
        ? ''
        : formatMoney(totalMarketValueCents, totalsCurrency);
    final tracking = trackingLifecycle;
    final trackingStatus = tracking?.statusStorageValue;
    final trackingRating = tracking?.rating;
    final trackingProgress = _detailTrackingProgressLabel(trackingLifecycle);
    return LibraryDetailSection(
      title: 'Local collection',
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(
                label: 'Status', value: genericLibraryStatusLabel(item)),
            LibraryDetailField(
                label: 'Owned ID',
                value: genericLibraryDash(ownedSummary?.ref.id.value)),
            LibraryDetailField(
                label: 'Quantity',
                value: ownedSummary == null
                    ? '-'
                    : ownedSummary!.quantity.toString()),
            LibraryDetailField(
                label: 'Location',
                value: genericLibraryDash(item.source.locationPath)),
            LibraryDetailField(label: 'Paid', value: paid.isEmpty ? '-' : paid),
            LibraryDetailField(
                label: 'Current value',
                value: currentValue.isEmpty ? '-' : currentValue),
            if (effectiveOwnedCopies.length > 1)
              LibraryDetailField(
                  label: 'Total paid',
                  value: totalPaid.isEmpty ? '-' : totalPaid),
            if (effectiveOwnedCopies.length > 1)
              LibraryDetailField(
                  label: 'Total current value',
                  value: totalCurrentValue.isEmpty ? '-' : totalCurrentValue),
            ...kindPersonalFields,
            LibraryDetailField(
                label: 'Purchased',
                value: genericLibraryDash(
                  formatNullableDate(ownedSummary?.purchaseDate),
                )),
            LibraryDetailField(
                label: 'Sell price',
                value: sellPrice.isEmpty ? '-' : sellPrice),
            LibraryDetailField(
                label: 'Profit / Loss', value: profitLoss ?? '-'),
            LibraryDetailField(
                label: 'Sold to',
                value: genericLibraryDash(ownedSummary?.soldTo)),
            LibraryDetailField(
                label: 'Updated',
                value: formatNullableDate(ownedSummary?.updatedAt) ?? '-'),
            LibraryDetailField(
                label: 'Read status',
                value: genericLibraryDash(trackingStatus)),
            LibraryDetailField(
                label: 'Progress', value: genericLibraryDash(trackingProgress)),
            LibraryDetailField(
                label: 'Rating', value: trackingRating?.toString() ?? '-'),
            LibraryDetailField(
                label: 'Purchase Store',
                value: genericLibraryDash(ownedSummary?.purchaseStore)),
          ],
        ),
        if (trackingRating != null && trackingRating > 0) ...[
          const SizedBox(height: 10),
          _DetailStarRating(
              rating: trackingRating, maxRating: 10, accent: accent),
        ],
        if (ownedSummary?.notes != null &&
            ownedSummary!.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailFieldRow(
            field: LibraryDetailField(
              label: 'Notes',
              value: ownedSummary!.notes!,
            ),
          ),
        ],
      ],
    );
  }
}

int? _sumOwnedValueCents(
  List<OwnedItemSummary> items,
  int? Function(OwnedItemSummary item) selector,
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

String? _detailValueCurrency(
  List<OwnedItemSummary> ownedCopies,
  OwnedItemSummary? ownedItem,
  LibraryProjectionView item,
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
  return null;
}

String? _detailProfitLossLabel(OwnedItemSummary? ownedItem) {
  final paid = ownedItem?.pricePaidCents;
  final sold = ownedItem?.sellPriceCents;
  if (paid == null || sold == null) {
    return null;
  }
  return formatMoney(sold - paid, ownedItem?.currency);
}

String? _detailTrackingProgressLabel(TrackingLifecycle? trackingLifecycle) {
  final current = trackingLifecycle?.progressCurrent;
  final total = trackingLifecycle?.progressTotal;
  if (current == null && total == null) {
    return null;
  }
  if (total != null && total > 0) {
    return '${current ?? 0}/$total';
  }
  return '${current ?? 0}';
}

class _DetailStarRating extends StatelessWidget {
  const _DetailStarRating({
    required this.rating,
    required this.maxRating,
    required this.accent,
  });

  final int rating;
  final int maxRating;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // Convert rating to 5-star scale for display
    const starCount = 5;
    final filledStars = maxRating > 0
        ? (rating * starCount / maxRating).round().clamp(0, starCount)
        : 0;
    return Row(
      children: [
        Text(
          'Rating  ',
          style: Theme.of(context).textTheme.libraryMeta.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w800,
              ),
        ),
        for (var i = 0; i < starCount; i++)
          Icon(
            i < filledStars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < filledStars ? accent : appPalette(context).textMuted,
            size: 20,
          ),
        const SizedBox(width: 6),
        Text(
          '$rating/$maxRating',
          style: Theme.of(context).textTheme.libraryMeta.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
