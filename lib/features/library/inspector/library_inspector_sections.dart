import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter/material.dart';

class InspectorMetadataSection extends StatelessWidget {
  const InspectorMetadataSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindModule type;
  final LibraryProjectionView item;
  final Color accent;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return LibraryMetadataContent(
      type: type,
      item: item,
      onFilterByValue: onFilterByValue,
    );
  }
}

class InspectorPersonalSection extends StatelessWidget {
  const InspectorPersonalSection({
    super.key,
    required this.type,
    required this.item,
    this.ownedItem,
    this.typedOwnedItem,
    this.trackingLifecycle,
    required this.accent,
    this.valueSnapshot,
    this.onFilterByValue,
  });

  final LibraryKindModule type;
  final LibraryProjectionView item;
  final OwnedItemSummary? ownedItem;
  final Object? typedOwnedItem;
  final TrackingLifecycle? trackingLifecycle;
  final Color accent;
  final LibraryValueSnapshot? valueSnapshot;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final existingOwnedItem = ownedItem;
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final catalogEditions = item.source.catalogTransport?.mapTransport(
          (transport) => transport.editions,
        ) ??
        const [];
    final snapshot = valueSnapshot ??
        LibraryValueSnapshot.fromItem(
          item,
          purchasePriceCents: item.source.pricePaidCents,
          soldPriceCents: item.source.sellPriceCents,
          manualEstimatedValueCents: item.source.marketValueCents,
          ownedCurrency: item.source.currency,
          providerName:
              item.source.marketValueCents != null ? 'Provider snapshot' : null,
        );
    final paid = formatMoney(
        ownedItem?.pricePaidCents ?? item.source.pricePaidCents,
        ownedItem?.currency ?? adapter?.currency);
    final ownedCopyTypeLabel = libraryOwnedCopyTypeLabel(
      existingOwnedItem == null ? null : existingOwnedItem,
      catalogEditions,
      digitalFlagResolver: type.edit.resolveOwnedDigitalFlag,
      fallbackLabel: adapter?.variant,
    );
    final tracking = trackingLifecycle;
    final trackingRating = tracking?.rating;
    final trackingStatus = tracking?.statusStorageValue;
    final trackingStartedAt = tracking?.startedAt;
    final trackingFinishedAt = tracking?.finishedAt;
    final kindPersonalFields = type.inspector.buildPersonalDetailFields(
      context: context,
      item: item,
      ownedItem: item.source.ownedSummary,
      typedOwnedItem: typedOwnedItem ?? item.source.typedOwnedItem,
      currency: ownedItem?.currency ?? adapter?.currency,
    );
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
            LibraryDetailField(
                label: 'Status', value: genericLibraryStatusLabel(item)),
            if (ownedCopyTypeLabel != null)
              LibraryDetailField(label: 'Ownership', value: ownedCopyTypeLabel),
            if (trackingStatus != null && trackingStatus.trim().isNotEmpty)
              LibraryDetailField(label: 'Tracking', value: trackingStatus),
            if (trackingStartedAt != null)
              LibraryDetailField(
                  label: 'Started',
                  value: formatNullableDate(trackingStartedAt) ?? '-'),
            if (trackingFinishedAt != null)
              LibraryDetailField(
                  label: 'Finished',
                  value: formatNullableDate(trackingFinishedAt) ?? '-'),
            LibraryDetailField(
                label: 'Quantity',
                value:
                    ownedItem == null ? '-' : ownedItem!.quantity.toString()),
            LibraryDetailField(
                label: 'Location',
                value: genericLibraryDash(item.source.locationPath)),
            LibraryDetailField(label: 'Paid', value: paid.isEmpty ? '-' : paid),
            if (snapshot.providerValueCents != null)
              LibraryDetailField(
                  label: 'Provider value',
                  value: formatMoney(
                    snapshot.providerValueCents,
                    snapshot.currency,
                  )),
            if (snapshot.manualEstimatedValueCents != null)
              LibraryDetailField(
                  label: 'Manual value',
                  value: formatMoney(
                    snapshot.manualEstimatedValueCents,
                    snapshot.currency,
                  )),
            ...kindPersonalFields,
            if (ownedItem?.soldAt != null)
              LibraryDetailField(
                label: 'Sold',
                value: formatNullableDate(ownedItem!.soldAt) ?? '-',
              ),
            if (ownedItem?.soldTo != null &&
                ownedItem!.soldTo!.trim().isNotEmpty)
              LibraryDetailField(
                label: 'Sold to',
                value: ownedItem!.soldTo!,
              ),
            if (ownedItem?.sellPriceCents != null)
              LibraryDetailField(
                label: 'Sell price',
                value: formatMoney(ownedItem!.sellPriceCents,
                    ownedItem?.currency ?? adapter?.currency),
              ),
            if (ownedItem?.sellPriceCents != null)
              LibraryDetailField(
                label: 'Profit / Loss',
                value: formatMoney(
                  ownedItem!.sellPriceCents! - (ownedItem!.pricePaidCents ?? 0),
                  ownedItem?.currency ?? adapter?.currency,
                ),
              ),
          ],
        ),
        if (item.source.ownedSummary?.notes?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            item.source.ownedSummary!.notes!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                ),
          ),
        ],
      ],
    );
  }
}
