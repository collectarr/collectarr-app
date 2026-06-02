import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
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
    return LibraryInspectorSection(
      title: 'Metadata',
      accentColor: accent,
      children: [
        LibraryMetadataContent(
          type: type,
          entry: entry,
          onFilterByValue: onFilterByValue,
        ),
      ],
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
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final paid = formatMoney(entry.pricePaidCents, entry.currency);
    final profitLoss = _profitLossLabel(ownedItem);
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
    final trackingStatus = trackingEntry?.mediaTracking.statusLabel == 'Not tracked'
      ? ownedItem?.readStatus
      : trackingEntry?.mediaTracking.statusLabel ?? ownedItem?.readStatus;
    final trackingStartedAt = trackingEntry?.startedAt ?? ownedItem?.startedAt;
    final trackingFinishedAt =
        trackingEntry?.finishedAt ?? ownedItem?.finishedAt;
    return LibraryInspectorSection(
      title: 'Personal',
      accentColor: accent,
      children: [
        if (trackingRating != null && trackingRating > 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MediaRatingDisplay(rating: trackingRating),
          ),
        ],
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData(
              'Status',
              genericLibraryStatusLabel(entry),
            ),
            if (ownedCopyTypeLabel != null)
              LibraryInspectorFactData('Ownership', ownedCopyTypeLabel),
            if (trackingStatus != null && trackingStatus.trim().isNotEmpty)
              LibraryInspectorFactData('Tracking', trackingStatus),
            if (trackingStartedAt != null)
              LibraryInspectorFactData(
                'Started',
                formatNullableDate(trackingStartedAt) ?? '-',
              ),
            if (trackingFinishedAt != null)
              LibraryInspectorFactData(
                'Finished',
                formatNullableDate(trackingFinishedAt) ?? '-',
              ),
            if (ownedIsDigital != true)
              LibraryInspectorFactData(
                'Condition',
                genericLibraryDash(entry.condition),
              ),
            if (ownedIsDigital != true)
              LibraryInspectorFactData('Grade', genericLibraryDash(entry.grade)),
            LibraryInspectorFactData(
              'Quantity',
              ownedItem == null ? '-' : ownedItem!.quantity.toString(),
            ),
            if (ownedIsDigital != true)
              LibraryInspectorFactData(
                'Location',
                genericLibraryDash(entry.locationPath),
              ),
            LibraryInspectorFactData('Paid', paid.isEmpty ? '-' : paid),
            LibraryInspectorFactData(
              'Purchased',
              genericLibraryDash(
                formatNullableDate(ownedItem?.purchaseDate),
              ),
            ),
            if (ownedIsDigital != true && ownedItem?.coverPriceCents != null)
              LibraryInspectorFactData(
                'Cover price',
                formatMoney(ownedItem!.coverPriceCents, ownedItem!.currency),
              ),
            if (ownedItem?.isSold ?? false) ...[
              LibraryInspectorFactData(
                'Sold',
                formatNullableDate(ownedItem?.soldAt) ?? 'Yes',
              ),
              LibraryInspectorFactData(
                'Sell price',
                ownedItem?.sellPriceCents != null
                    ? formatMoney(
                        ownedItem!.sellPriceCents, ownedItem!.currency)
                    : '-',
              ),
              if (profitLoss != null)
                LibraryInspectorFactData('Profit / Loss', profitLoss),
              LibraryInspectorFactData(
                'Sold to',
                genericLibraryDash(ownedItem?.soldTo),
              ),
            ],
            LibraryInspectorFactData(
              'Updated',
              formatNullableDate(entry.updatedAt) ?? '-',
            ),
          ],
        ),
        if (ownedItem?.personalNotes != null &&
            ownedItem!.personalNotes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorFact('Notes', ownedItem!.personalNotes!),
        ],
        if (ownedItem?.tags != null && ownedItem!.tags!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(
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

String? _profitLossLabel(OwnedItem? ownedItem) {
  final paid = ownedItem?.pricePaidCents;
  final sold = ownedItem?.sellPriceCents;
  if (paid == null || sold == null) {
    return null;
  }
  return formatMoney(sold - paid, ownedItem?.currency);
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
    return LibraryEmptyInspector(
      icon: type.workspace.icon,
      label: type.singularLabel.toLowerCase(),
      accent: accent,
      mutedTextColor: palette.textMuted,
      backgroundColor: palette.panel,
    );
  }
}
