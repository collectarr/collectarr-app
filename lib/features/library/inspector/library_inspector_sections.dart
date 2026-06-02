import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/metadata/library_metadata_content.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
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

class InspectorVideoTitleMetadataSection extends StatelessWidget {
  const InspectorVideoTitleMetadataSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
    required this.ownedReleaseCount,
    this.onFilterByValue,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;
  final int ownedReleaseCount;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final metadataPresentation = _metadataPresentationForEntry(type, entry);
    final aliasValues = <String>{
      if (entry.originalTitle?.trim().isNotEmpty == true)
        entry.originalTitle!.trim(),
      if (entry.localizedTitle?.trim().isNotEmpty == true &&
          entry.localizedTitle!.trim() != entry.resolvedTitle.trim())
        entry.localizedTitle!.trim(),
      ...?entry.searchAliases,
    }.toList(growable: false);
    final creatorNames = <String>[
      for (final credit in metadataPresentation.creators)
        if (credit['name']?.toString().trim().isNotEmpty == true)
          credit['name'].toString().trim(),
    ];
    final creatorsByRole = <String, List<String>>{};
    for (final credit in metadataPresentation.creators) {
      final name = credit['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final role = credit['role']?.toString().trim();
      final key = (role != null && role.isNotEmpty) ? role : 'Creator';
      creatorsByRole.putIfAbsent(key, () => <String>[]).add(name);
    }
    final hasRoles = creatorsByRole.keys.any((r) => r != 'Creator') ||
        creatorsByRole.length > 1;
    return LibraryInspectorSection(
      title: 'Title metadata',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Display title', entry.resolvedTitle),
            if (entry.originalTitle?.trim().isNotEmpty == true)
              LibraryInspectorFactData('Original title', entry.originalTitle!),
            if (entry.publisher?.trim().isNotEmpty == true)
              LibraryInspectorFactData('Studio', entry.publisher!),
            if (_metadataFactValue(metadataPresentation, 'Runtime')
                case final runtime?)
              LibraryInspectorFactData(
                'Runtime',
                runtime,
              ),
            LibraryInspectorFactData(
              'Releases',
              entry.editions.length.toString(),
            ),
            LibraryInspectorFactData(
              'Owned releases',
              ownedReleaseCount.toString(),
            ),
          ],
        ),
        _buildEditionFormatBadges(entry),
        if (metadataPresentation.genres case final genres when genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(label: 'Genres', values: genres),
        ],
        if (creatorNames.isNotEmpty && hasRoles) ...[
          for (final entry in creatorsByRole.entries) ...[
            const SizedBox(height: 8),
            LibraryInspectorChipWrap(label: entry.key, values: entry.value),
          ],
        ] else if (creatorNames.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(label: 'Cast / credits', values: creatorNames),
        ],
        if (aliasValues.isNotEmpty) ...[
          const SizedBox(height: 8),
          LibraryInspectorChipWrap(label: 'Search aliases', values: aliasValues),
        ],
      ],
    );
  }
}

LibraryMetadataPresentation _metadataPresentationForEntry(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

String? _metadataFactValue(
  LibraryMetadataPresentation presentation,
  String label,
) {
  for (final fact in presentation.allFacts) {
    if (fact.label == label) {
      final value = fact.value.trim();
      if (value.isNotEmpty && value != '-') {
        return value;
      }
    }
  }
  return null;
}

Widget _buildEditionFormatBadges(LibraryWorkspaceEntry entry) {
  final seen = <String>{};
  final badges = <Widget>[];
  for (final edition in entry.editions) {
    final id = edition.physicalFormat;
    if (id == null || !seen.add(id)) continue;
    badges.add(
      FormatBadge.fromFormat(
        id: id,
        label: edition.physicalFormatLabel ?? id,
      ),
    );
  }
  if (badges.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Wrap(spacing: 4, runSpacing: 4, children: badges),
  );
}

List<Widget> buildVideoInspectorSections(
  BuildContext context,
  LibraryInspectorRequest request,
) {
  final ownedReleaseIds = <String>{};
  for (final edition in request.entry.editions) {
    if (edition.id == request.entry.referenceEditionId) {
      ownedReleaseIds.add(edition.id);
      continue;
    }
    for (final variant in edition.variants) {
      if (variant.id == request.entry.referenceVariantId) {
        ownedReleaseIds.add(edition.id);
        break;
      }
    }
  }
  return [
    InspectorVideoTitleMetadataSection(
      type: request.type,
      entry: request.entry,
      accent: request.accent,
      ownedReleaseCount: ownedReleaseIds.length,
      onFilterByValue: request.onFilterByValue,
    ),
  ];
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
