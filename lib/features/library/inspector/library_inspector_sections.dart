import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_row.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:flutter/material.dart';

class InspectorMetadataSection extends StatelessWidget {
  const InspectorMetadataSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return LibraryMetadataContent(
      type: type,
      entry: entry,
      onFilterByValue: onFilterByValue,
    );
  }
}

class InspectorPersonalSection extends StatelessWidget {
  const InspectorPersonalSection({
    super.key,
    required this.entry,
    required this.ownedItem,
    this.trackingEntry,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final valueSnapshot = LibraryValueSnapshot.fromEntry(
      entry,
      ownedItem: ownedItem,
      providerName: entry.marketValueCents != null ? 'Provider snapshot' : null,
    );
    final paid = formatMoney(entry.pricePaidCents, entry.currency);
    final ownedCopyTypeLabel = libraryOwnedCopyTypeLabel(
      ownedItem,
      entry.editions,
      fallbackLabel: entry.variant,
    );
    final ownedIsDigital = resolveOwnedDigitalFlag(
      ownedItem,
      entry.editions,
      fallbackLabel: entry.variant,
    );
    final trackingRating = trackingEntry?.rating ?? ownedItem?.rating;
    final trackingStatus =
        trackingEntry?.mediaTracking.statusLabel == 'Not tracked'
            ? ownedItem?.readStatus
            : trackingEntry?.mediaTracking.statusLabel ?? ownedItem?.readStatus;
    final trackingStartedAt = trackingEntry?.startedAt ?? ownedItem?.startedAt;
    final trackingFinishedAt =
        trackingEntry?.finishedAt ?? ownedItem?.finishedAt;
    return LibraryDetailSection(
      title: 'Personal',
      accentColor: accent,
      children: [
        if (trackingRating != null && trackingRating > 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MediaRatingDisplay(rating: trackingRating),
          ),
        ],
        LibraryDetailFieldTable(
          fields: [
            LibraryDetailField(label: 'Status', value: genericLibraryStatusLabel(entry)),
            if (ownedCopyTypeLabel != null)
              LibraryDetailField(label: 'Ownership', value: ownedCopyTypeLabel),
            if (trackingStatus != null && trackingStatus.trim().isNotEmpty)
              LibraryDetailField(label: 'Tracking', value: trackingStatus),
            if (trackingStartedAt != null)
              LibraryDetailField(label: 'Started', value: formatNullableDate(trackingStartedAt) ?? '-'),
            if (trackingFinishedAt != null)
              LibraryDetailField(label: 'Finished', value: formatNullableDate(trackingFinishedAt) ?? '-'),
            if (ownedIsDigital != true)
              LibraryDetailField(label: 'Condition', value: genericLibraryDash(entry.condition)),
            if (ownedIsDigital != true)
              LibraryDetailField(label: 'Grade', value: genericLibraryDash(entry.grade)),
            LibraryDetailField(label: 'Quantity', value: ownedItem == null ? '-' : ownedItem!.quantity.toString()),
            if (ownedIsDigital != true)
              LibraryDetailField(label: 'Location', value: genericLibraryDash(entry.locationPath)),
            LibraryDetailField(label: 'Paid', value: paid.isEmpty ? '-' : paid),
            if (valueSnapshot.providerValueCents != null)
              LibraryDetailField(label: 'Provider value', value: formatMoney(
                  valueSnapshot.providerValueCents,
                  valueSnapshot.currency,
                )),
            if (valueSnapshot.manualEstimatedValueCents != null)
              LibraryDetailField(label: 'Manual value', value: formatMoney(
                  valueSnapshot.manualEstimatedValueCents,
                  valueSnapshot.currency,
                )),
            if (valueSnapshot.currentValueCents != null)
              LibraryDetailField(label: 'Current value', value: formatMoney(
                  valueSnapshot.currentValueCents,
                  valueSnapshot.currency,
                )),
            if (valueSnapshot.insuranceValueCents != null)
              LibraryDetailField(label: 'Insurance', value: formatMoney(
                  valueSnapshot.insuranceValueCents,
                  valueSnapshot.currency,
                )),
            LibraryDetailField(label: 'Purchased', value: genericLibraryDash(
                formatNullableDate(ownedItem?.purchaseDate),
              )),
            if (ownedIsDigital != true && ownedItem?.coverPriceCents != null)
              LibraryDetailField(label: 'Cover price', value: formatMoney(ownedItem!.coverPriceCents, ownedItem!.currency)),
            if (ownedItem?.isSold ?? false) ...[
              LibraryDetailField(label: 'Sold', value: formatNullableDate(ownedItem?.soldAt) ?? 'Yes'),
              LibraryDetailField(label: 'Sell price', value: ownedItem?.sellPriceCents != null
                    ? formatMoney(
                        ownedItem!.sellPriceCents, ownedItem!.currency)
                    : '-'),
              if (valueSnapshot.profitLossCents != null)
                LibraryDetailField(label: 'Profit / Loss', value: formatMoney(
                    valueSnapshot.profitLossCents,
                    valueSnapshot.currency,
                  )),
              LibraryDetailField(label: 'Sold to', value: genericLibraryDash(ownedItem?.soldTo)),
            ],
            LibraryDetailField(label: 'Updated', value: formatNullableDate(entry.updatedAt) ?? '-'),
          ],
        ),
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

class EmptyInspector extends StatelessWidget {
  const EmptyInspector({
    super.key,
    required this.type,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Center(
      child: Text(
        'No ${type.singularLabel.toLowerCase()} selected',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.textMuted,
            ),
      ),
    );
  }
}

