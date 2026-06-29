import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryDetailPersonalSection extends StatelessWidget {
  const LibraryDetailPersonalSection({
    super.key,
    required this.entry,
    required this.ownedItem,
    this.ownedCopies = const [],
    this.trackingEntry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final effectiveOwnedCopies = ownedCopies.isNotEmpty
        ? ownedCopies
        : ownedItem == null
            ? const <OwnedItem>[]
            : <OwnedItem>[ownedItem!];
    final paid = formatMoney(
      ownedItem?.pricePaidCents ?? entry.pricePaidCents,
      ownedItem?.currency ?? entry.currency,
    );
    final currentValue = formatMoney(
      ownedItem?.marketValueCents,
      ownedItem?.currency,
    );
    final coverPrice = formatMoney(ownedItem?.coverPriceCents, ownedItem?.currency);
    final sellPrice = formatMoney(ownedItem?.sellPriceCents, ownedItem?.currency);
    final profitLoss = _detailProfitLossLabel(ownedItem);
    final totalPaidCents = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.pricePaidCents,
    );
    final totalMarketValueCents = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.marketValueCents,
    );
    final totalsCurrency = _detailValueCurrency(effectiveOwnedCopies, ownedItem, entry);
    final totalPaid = totalPaidCents == null
        ? ''
        : formatMoney(totalPaidCents, totalsCurrency);
    final totalCurrentValue = totalMarketValueCents == null
        ? ''
        : formatMoney(totalMarketValueCents, totalsCurrency);
    final trackingStatus = trackingEntry?.mediaTracking.statusLabel == 'Not tracked'
      ? ownedItem?.readStatus
      : trackingEntry?.mediaTracking.statusLabel ?? ownedItem?.readStatus;
    final trackingRating = trackingEntry?.rating ?? ownedItem?.rating;
    final trackingProgress = _detailTrackingProgressLabel(trackingEntry);
    final trackingEpisode = _detailTrackingEpisodeLabel(trackingEntry);
    return LibraryInspectorSection(
      title: 'Local collection',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData(
              'Status',
              genericLibraryStatusLabel(entry),
            ),
            LibraryInspectorFactData(
              'Owned ID',
              genericLibraryDash(ownedItem?.id),
            ),
            LibraryInspectorFactData(
              'Condition',
              genericLibraryDash(ownedItem?.condition ?? entry.condition),
            ),
            LibraryInspectorFactData(
              'Grade',
              genericLibraryDash(ownedItem?.grade ?? entry.grade),
            ),
            LibraryInspectorFactData(
              'Quantity',
              ownedItem == null ? '-' : ownedItem!.quantity.toString(),
            ),
            LibraryInspectorFactData(
              'Location',
              genericLibraryDash(entry.locationPath),
            ),
            LibraryInspectorFactData('Paid', paid.isEmpty ? '-' : paid),
            LibraryInspectorFactData(
              'Current value',
              currentValue.isEmpty ? '-' : currentValue,
            ),
            if (effectiveOwnedCopies.length > 1)
              LibraryInspectorFactData(
                'Total paid',
                totalPaid.isEmpty ? '-' : totalPaid,
              ),
            if (effectiveOwnedCopies.length > 1)
              LibraryInspectorFactData(
                'Total current value',
                totalCurrentValue.isEmpty ? '-' : totalCurrentValue,
              ),
            LibraryInspectorFactData(
              'Cover price',
              coverPrice.isEmpty ? '-' : coverPrice,
            ),
            LibraryInspectorFactData(
              'Purchased',
              genericLibraryDash(
                formatNullableDate(ownedItem?.purchaseDate),
              ),
            ),
            LibraryInspectorFactData(
              'Sell price',
              sellPrice.isEmpty ? '-' : sellPrice,
            ),
            LibraryInspectorFactData(
              'Profit / Loss',
              profitLoss ?? '-',
            ),
            LibraryInspectorFactData(
              'Sold to',
              genericLibraryDash(ownedItem?.soldTo),
            ),
            LibraryInspectorFactData(
              'Updated',
              formatNullableDate(ownedItem?.updatedAt ?? entry.updatedAt) ?? '-',
            ),
            LibraryInspectorFactData(
              'Read status',
              genericLibraryDash(trackingStatus),
            ),
            LibraryInspectorFactData(
              'Progress',
              genericLibraryDash(trackingProgress),
            ),
            LibraryInspectorFactData(
              'Episode',
              genericLibraryDash(trackingEpisode),
            ),
            LibraryInspectorFactData(
              'Rating',
              trackingRating?.toString() ?? '-',
            ),
            LibraryInspectorFactData(
              'Features',
              genericLibraryDash(ownedItem?.features),
            ),
            LibraryInspectorFactData(
              'HDR Formats',
              ownedItem?.hdrFormats.isEmpty ?? true
                  ? '-'
                  : ownedItem!.hdrFormats.join(', '),
            ),
            LibraryInspectorFactData(
              'Purchase Store',
              genericLibraryDash(ownedItem?.purchaseStore),
            ),
            LibraryInspectorFactData(
              'Box Set',
              genericLibraryDash(ownedItem?.boxSetName),
            ),
            LibraryInspectorFactData(
              'Storage Device',
              genericLibraryDash(ownedItem?.storageDevice),
            ),
            LibraryInspectorFactData(
              'Storage Slot',
              genericLibraryDash(ownedItem?.storageSlot),
            ),
            LibraryInspectorFactData(
              'Region',
              genericLibraryDash(ownedItem?.region),
            ),
            LibraryInspectorFactData(
              'Packaging',
              genericLibraryDash(ownedItem?.packaging),
            ),
            LibraryInspectorFactData(
              'Distributor',
              genericLibraryDash(ownedItem?.distributor),
            ),
          ],
        ),
        if (trackingRating != null && trackingRating > 0) ...[
          const SizedBox(height: 10),
          _DetailStarRating(rating: trackingRating, maxRating: 10, accent: accent),
        ],
        if (ownedItem?.personalNotes != null &&
            ownedItem!.personalNotes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorFact('Notes', ownedItem!.personalNotes!),
        ],
        if (ownedItem?.tags != null && ownedItem!.tags!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
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

String? _detailTrackingEpisodeLabel(TrackingEntry? trackingEntry) {
  final seasonNumber = trackingEntry?.seasonNumber;
  final episodeNumber = trackingEntry?.episodeNumber;
  if (seasonNumber == null && episodeNumber == null) {
    return null;
  }
  if (seasonNumber != null && episodeNumber != null) {
    return 'S$seasonNumber · Ep $episodeNumber';
  }
  if (seasonNumber != null) {
    return 'S$seasonNumber';
  }
  return 'Ep ${episodeNumber!}';
}

class LibraryDetailLocalSnapshotSection extends StatelessWidget {
  const LibraryDetailLocalSnapshotSection({
    super.key,
    required this.entry,
    required this.ownedItem,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    return LibraryInspectorSection(
      title: 'Local snapshot',
      children: [
        SelectableText(
          [
            'catalog_id: ${entry.id}',
            'kind: ${entry.mediaType}',
            'owned_id: ${ownedItem?.id ?? '-'}',
            'edition_id: ${ownedItem?.editionId ?? '-'}',
            'variant_id: ${ownedItem?.variantId ?? '-'}',
            'updated_at: ${entry.updatedAt.toUtc().toIso8601String()}',
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
          style: TextStyle(
            color: appPalette(context).textMuted,
            fontSize: 12,
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
          style: TextStyle(
            color: appPalette(context).textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
