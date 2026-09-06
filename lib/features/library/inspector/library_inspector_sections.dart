import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:flutter/material.dart';

class InspectorMetadataSection extends StatelessWidget {
  const InspectorMetadataSection({
    super.key,
    required this.type,
    required this.item,
    required this.accent,
    this.onFilterByValue,
  });

  final LibraryKindRuntime type;
  final LibraryProjectionRuntime item;
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
    required this.item,
    this.ownedItem,
    this.trackingEntry,
    required this.accent,
    this.valueSnapshot,
    this.onFilterByValue,
  });

  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final Color accent;
  final LibraryValueSnapshot? valueSnapshot;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final adapter = dto is WorkspaceDtoAdapter ? dto : null;
    final details = ownedItem?.details;
    final ownedComicDetails = details is ComicOwnedDetails ? details : null;
    final catalogEditions = item.source.catalogItem?.editions ?? const [];
    final snapshot = valueSnapshot ??
        LibraryValueSnapshot.fromItem(
          item,
          ownedItem: ownedItem,
          providerName: item.source.ownedItem?.marketValueCents != null
              ? 'Provider snapshot'
              : null,
        );
    final paid = formatMoney(
        ownedItem?.pricePaidCents ?? item.source.pricePaidCents,
        ownedItem?.currency ?? adapter?.currency);
    final ownedCopyTypeLabel = libraryOwnedCopyTypeLabel(
      ownedItem,
      catalogEditions,
      fallbackLabel: adapter?.variant,
    );
    final ownedIsDigital = resolveOwnedDigitalFlag(
      ownedItem,
      catalogEditions,
      fallbackLabel: adapter?.variant,
    );
    final trackingRating = trackingEntry?.rating ?? ownedItem?.rating;
    final trackingStatus =
        trackingEntry?.statusStorageValue ?? ownedItem?.readStatus;
    final trackingStartedAt = trackingEntry?.startedAt ?? ownedItem?.startedAt;
    final trackingFinishedAt =
        trackingEntry?.finishedAt ?? ownedItem?.finishedAt;
    final ownedTags = ownedItem?.tags;
    final List<String> tagList =
        (ownedTags != null && ownedTags.trim().isNotEmpty)
            ? ownedTags
                .split(',')
                .map((t) => t.trim())
                .where((t) => t.isNotEmpty)
                .toList()
            : (item.source.tags != null
                ? <String>[item.source.tags!]
                : const <String>[]);
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
            if (ownedIsDigital != true)
              LibraryDetailField(
                  label: 'Condition',
                  value: genericLibraryDash(item.source.condition)),
            if (ownedIsDigital != true)
              LibraryDetailField(
                  label: 'Grade', value: genericLibraryDash(item.source.grade)),
            LibraryDetailField(
                label: 'Quantity',
                value:
                    ownedItem == null ? '-' : ownedItem!.quantity.toString()),
            if (ownedIsDigital != true)
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
            if (ownedComicDetails?.coverPriceCents != null)
              LibraryDetailField(
                label: 'Cover price',
                value: formatMoney(
                  ownedComicDetails!.coverPriceCents,
                  ownedItem?.currency ?? adapter?.currency,
                ),
              ),
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
        if (item.source.personalNotes != null &&
            item.source.personalNotes!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.source.personalNotes!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: appPalette(context).textMuted,
                ),
          ),
        ],
        if (tagList.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryDetailChipGroupWidget(
            label: 'Tags',
            values: tagList,
            onValueTap: onFilterByValue,
          ),
        ],
      ],
    );
  }
}
