import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:flutter/material.dart';

class LibraryDetailPersonalSection extends StatelessWidget {
  const LibraryDetailPersonalSection({
    super.key,
    required this.item,
    required this.ownedItem,
    this.ownedCopies = const [],
    this.trackingEntry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final effectiveOwnedCopies = ownedCopies.isNotEmpty
        ? ownedCopies
        : ownedItem == null
            ? const <OwnedItem>[]
            : <OwnedItem>[ownedItem!];
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final details = ownedItem?.details;
    final ownedComicDetails = details is ComicOwnedDetails ? details : null;
    final ownedMusicDetails = details is MusicOwnedDetails ? details : null;
    final paid = formatMoney(
      ownedItem?.pricePaidCents ?? item.source.pricePaidCents,
      ownedItem?.currency ?? adapter?.currency,
    );
    final currentValue = formatMoney(
      ownedItem?.marketValueCents,
      ownedItem?.currency,
    );
    final coverPriceCents = ownedComicDetails?.coverPriceCents;
    final currency = ownedItem?.currency ?? adapter?.currency;
    final coverPrice = formatMoney(coverPriceCents, currency);
    final sellPrice = formatMoney(ownedItem?.sellPriceCents, currency);
    final profitLoss = _detailProfitLossLabel(ownedItem);
    final totalPaidCents = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.pricePaidCents,
    );
    final totalMarketValueCents = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.marketValueCents,
    );
    final totalsCurrency =
        _detailValueCurrency(effectiveOwnedCopies, ownedItem, item);
    final totalPaid = totalPaidCents == null
        ? ''
        : formatMoney(totalPaidCents, totalsCurrency);
    final totalCurrentValue = totalMarketValueCents == null
        ? ''
        : formatMoney(totalMarketValueCents, totalsCurrency);
    final trackingStatus =
        trackingEntry?.statusStorageValue ?? ownedItem?.readStatus;
    final trackingRating = trackingEntry?.rating ?? ownedItem?.rating;
    final trackingProgress = _detailTrackingProgressLabel(trackingEntry);
    return LibraryDetailSection(
      title: 'Local collection',
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(
                label: 'Status', value: genericLibraryStatusLabel(item)),
            LibraryDetailField(
                label: 'Owned ID', value: genericLibraryDash(ownedItem?.id)),
            LibraryDetailField(
                label: 'Condition',
                value: genericLibraryDash(
                    ownedItem?.condition ?? item.source.condition)),
            LibraryDetailField(
                label: 'Grade',
                value:
                    genericLibraryDash(ownedItem?.grade ?? item.source.grade)),
            LibraryDetailField(
                label: 'Quantity',
                value:
                    ownedItem == null ? '-' : ownedItem!.quantity.toString()),
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
            LibraryDetailField(
                label: 'Cover price',
                value: coverPrice.isEmpty ? '-' : coverPrice),
            LibraryDetailField(
                label: 'Purchased',
                value: genericLibraryDash(
                  formatNullableDate(ownedItem?.purchaseDate),
                )),
            LibraryDetailField(
                label: 'Sell price',
                value: sellPrice.isEmpty ? '-' : sellPrice),
            LibraryDetailField(
                label: 'Profit / Loss', value: profitLoss ?? '-'),
            LibraryDetailField(
                label: 'Sold to', value: genericLibraryDash(ownedItem?.soldTo)),
            LibraryDetailField(
                label: 'Updated',
                value: formatNullableDate(ownedItem?.updatedAt) ?? '-'),
            LibraryDetailField(
                label: 'Read status',
                value: genericLibraryDash(trackingStatus)),
            LibraryDetailField(
                label: 'Progress', value: genericLibraryDash(trackingProgress)),
            LibraryDetailField(
                label: 'Rating', value: trackingRating?.toString() ?? '-'),
            LibraryDetailField(
                label: 'Purchase Store',
                value: genericLibraryDash(ownedItem?.purchaseStore)),
            LibraryDetailField(
                label: 'Storage Device',
                value: genericLibraryDash(ownedMusicDetails?.storageDevice)),
            LibraryDetailField(
                label: 'Storage Slot',
                value: genericLibraryDash(ownedMusicDetails?.storageSlot)),
          ],
        ),
        if (trackingRating != null && trackingRating > 0) ...[
          const SizedBox(height: 10),
          _DetailStarRating(
              rating: trackingRating, maxRating: 10, accent: accent),
        ],
        if (ownedItem?.personalNotes != null &&
            ownedItem!.personalNotes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailFieldRow(
            field: LibraryDetailField(
              label: 'Notes',
              value: ownedItem!.personalNotes!,
            ),
          ),
        ],
        if (ownedItem?.tags != null && ownedItem!.tags!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            onValueTap: onFilterByValue,
            values: [
              for (final tag in ownedItem!.tags!.split(','))
                if (tag.trim().isNotEmpty) tag.trim(),
            ],
          ),
        ],
      ],
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

String? _detailValueCurrency(
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
  return null;
}

String? _detailProfitLossLabel(OwnedItem? ownedItem) {
  final paid = ownedItem?.pricePaidCents;
  final sold = ownedItem?.sellPriceCents;
  if (paid == null || sold == null) {
    return null;
  }
  return formatMoney(sold - paid, ownedItem?.currency);
}

String? _detailTrackingProgressLabel(TrackingEntry? trackingEntry) {
  final current = trackingEntry?.progressCurrent;
  final total = trackingEntry?.progressTotal;
  if (current == null && total == null) {
    return null;
  }
  if (total != null && total > 0) {
    return '${current ?? 0}/$total';
  }
  return '${current ?? 0}';
}

class LibraryDetailLocalSnapshotSection extends StatelessWidget {
  const LibraryDetailLocalSnapshotSection({
    super.key,
    required this.item,
    required this.ownedItem,
  });

  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    return LibraryDetailSection(
      title: 'Local snapshot',
      children: [
        SelectableText(
          [
            'catalog_id: ${item.node.titleItemId}',
            'kind: ${item.source.catalogItem?.kind ?? '-'}',
            'owned_id: ${ownedItem?.id ?? '-'}',
            'edition_id: ${ownedItem?.editionId ?? '-'}',
            'variant_id: ${ownedItem?.variantId ?? '-'}',
            'updated_at: ${(ownedItem?.updatedAt ?? DateTime.now()).toUtc().toIso8601String()}',
          ].join('\n'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: appPalette(context).textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
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
