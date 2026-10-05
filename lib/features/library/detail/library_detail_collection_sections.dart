import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_contributors.dart';
import 'package:flutter/material.dart';

class LibraryDetailPersonalSection extends StatelessWidget {
  const LibraryDetailPersonalSection({
    super.key,
    this.type,
    required this.item,
    this.libraryEntryDispatch,
    this.libraryEntrySummary,
    this.trackingSummary,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindRegistration? type;
  final LibraryProjectionView item;
  final LibraryEntryDispatch? libraryEntryDispatch;
  final LibraryEntrySummary? libraryEntrySummary;
  final TrackingSummary? trackingSummary;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final paid = formatMoney(
      libraryEntrySummary?.pricePaidCents ?? item.source.pricePaidCents,
      libraryEntrySummary?.currency ?? item.source.currency,
    );
    final currentValue = formatMoney(
      libraryEntrySummary?.marketValueCents,
      libraryEntrySummary?.currency,
    );
    final currency = libraryEntrySummary?.currency ?? item.source.currency;
    final sellPrice = formatMoney(libraryEntrySummary?.sellPriceCents, currency);
    final kindRegistration = type;
    final kindPersonalFields = kindRegistration == null
        ? const <LibraryDetailField>[]
        : libraryInspectorForKind(kindRegistration.kind)
            .buildPersonalDetailFields(
            context: context,
            item: item,
            libraryEntry: libraryEntrySummary,
            libraryEntryDispatch:
                libraryEntryDispatch ?? item.source.libraryEntryDispatch,
            currency: currency,
          );
    final profitLoss = _detailProfitLossLabel(libraryEntrySummary);
    final tracking = trackingSummary;
    final trackingStatus = tracking?.statusStorageValue;
    final trackingRating = tracking?.rating;
    final trackingProgress = _detailTrackingProgressLabel(trackingSummary);
    return LibraryDetailSection(
      title: 'Local collection',
      accentColor: accent,
      children: [
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(
                label: 'Status', value: genericLibraryStatusLabel(item)),
            LibraryDetailField(
                label: 'Entry ID',
                value: genericLibraryDash(libraryEntrySummary?.ref.key)),
            LibraryDetailField(
                label: 'Location',
                value: genericLibraryDash(item.source.locationPath)),
            LibraryDetailField(label: 'Paid', value: paid.isEmpty ? '-' : paid),
            LibraryDetailField(
                label: 'Current value',
                value: currentValue.isEmpty ? '-' : currentValue),
            ...kindPersonalFields,
            LibraryDetailField(
                label: 'Purchased',
                value: genericLibraryDash(
                  formatNullableDate(libraryEntrySummary?.purchaseDate),
                )),
            LibraryDetailField(
                label: 'Sell price',
                value: sellPrice.isEmpty ? '-' : sellPrice),
            LibraryDetailField(
                label: 'Profit / Loss', value: profitLoss ?? '-'),
            LibraryDetailField(
                label: 'Sold to',
                value: genericLibraryDash(libraryEntrySummary?.soldTo)),
            LibraryDetailField(
                label: 'Updated',
                value: formatNullableDate(libraryEntrySummary?.updatedAt) ?? '-'),
            LibraryDetailField(
                label: 'Read status',
                value: genericLibraryDash(trackingStatus)),
            LibraryDetailField(
                label: 'Progress', value: genericLibraryDash(trackingProgress)),
            LibraryDetailField(
                label: 'Rating', value: trackingRating?.toString() ?? '-'),
            LibraryDetailField(
                label: 'Purchase Store',
                value: genericLibraryDash(libraryEntrySummary?.purchaseStore)),
          ],
        ),
        if (trackingRating != null && trackingRating > 0) ...[
          const SizedBox(height: 10),
          _DetailStarRating(
              rating: trackingRating, maxRating: 10, accent: accent),
        ],
        if (libraryEntrySummary?.notes != null &&
            libraryEntrySummary!.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailFieldRow(
            field: LibraryDetailField(
              label: 'Notes',
              value: libraryEntrySummary!.notes!,
            ),
          ),
        ],
      ],
    );
  }
}

String? _detailProfitLossLabel(LibraryEntrySummary? libraryEntry) {
  final paid = libraryEntry?.pricePaidCents;
  final sold = libraryEntry?.sellPriceCents;
  if (paid == null || sold == null) {
    return null;
  }
  return formatMoney(sold - paid, libraryEntry?.currency);
}

String? _detailTrackingProgressLabel(TrackingSummary? trackingSummary) {
  final progress = trackingSummary?.progress;
  final current = progress?.current;
  final total = progress?.total;
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
                fontWeight: FontWeight.w700,
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
