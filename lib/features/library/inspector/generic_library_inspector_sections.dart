import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/generic_library_display.dart';
import 'package:collectarr_app/features/library/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericMetadataSection extends StatelessWidget {
  const GenericMetadataSection({
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

  VoidCallback? _tapFor(String? value) {
    if (onFilterByValue == null || value == null || value.trim().isEmpty) {
      return null;
    }
    return () => onFilterByValue!(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final labels = libraryMediaFieldLabels(type);
    return LibraryInspectorSection(
      title: 'Metadata',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData('Kind', type.singularLabel),
            if (entry.seriesTitle != null)
              LibraryInspectorFactData(
                'Series',
                entry.seriesTitle!,
                onTap: _tapFor(entry.seriesTitle),
              ),
            if (entry.volumeName != null || entry.volumeNumber != null)
              LibraryInspectorFactData(
                'Volume',
                entry.volumeName ??
                    'Vol. ${entry.volumeNumber}',
              ),
            if (entry.seasonNumber != null)
              LibraryInspectorFactData(
                'Season',
                'Season ${entry.seasonNumber}',
              ),
            if (entry.episodeNumber != null)
              LibraryInspectorFactData(
                'Episode',
                'Ep. ${entry.episodeNumber}',
              ),
            LibraryInspectorFactData(
              labels.publisher,
              genericLibraryDash(entry.publisher),
              onTap: _tapFor(entry.publisher),
            ),
            LibraryInspectorFactData(
              'Released',
              genericLibraryDash(
                formatNullableComicDate(entry.releaseDate) ??
                    entry.releaseYear?.toString(),
              ),
            ),
            LibraryInspectorFactData(
              labels.number,
              genericLibraryDash(entry.itemNumber),
              onTap: _tapFor(entry.itemNumber),
            ),
            LibraryInspectorFactData(
              labels.variant,
              genericLibraryDash(entry.variant),
              onTap: _tapFor(entry.variant),
            ),
            LibraryInspectorFactData(
              labels.barcode,
              genericLibraryDash(entry.barcode),
            ),
            LibraryInspectorFactData(
              'Cover',
              entry.hasMissingCover ? 'Missing' : 'Ready',
            ),
            LibraryInspectorFactData(
              'Metadata',
              entry.hasMissingMetadata ? 'Missing' : 'Ready',
            ),
          ],
        ),
      ],
    );
  }
}

class GenericPersonalSection extends StatelessWidget {
  const GenericPersonalSection({
    super.key,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    this.kind,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final String? kind;

  bool get _isComicKind => kind == 'comic' || kind == 'manga';

  @override
  Widget build(BuildContext context) {
    final paid = formatComicMoney(entry.pricePaidCents, entry.currency);
    return LibraryInspectorSection(
      title: 'Personal',
      accentColor: accent,
      children: [
        if (ownedItem?.rating != null && ownedItem!.rating! > 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MediaRatingDisplay(rating: ownedItem!.rating!),
          ),
        ],
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData(
              'Status',
              genericLibraryStatusLabel(entry),
            ),
            if (ownedItem?.readStatus != null &&
                ownedItem!.readStatus!.trim().isNotEmpty)
              LibraryInspectorFactData('Tracking', ownedItem!.readStatus!),
            if (ownedItem?.startedAt != null)
              LibraryInspectorFactData(
                'Started',
                formatNullableComicDate(ownedItem?.startedAt) ?? '-',
              ),
            if (ownedItem?.finishedAt != null)
              LibraryInspectorFactData(
                'Finished',
                formatNullableComicDate(ownedItem?.finishedAt) ?? '-',
              ),
            LibraryInspectorFactData(
              'Condition',
              genericLibraryDash(entry.condition),
            ),
            LibraryInspectorFactData('Grade', genericLibraryDash(entry.grade)),
            LibraryInspectorFactData(
              'Quantity',
              ownedItem == null ? '-' : ownedItem!.quantity.toString(),
            ),
            LibraryInspectorFactData(
              'Storage',
              genericLibraryDash(entry.storageBox),
            ),
            LibraryInspectorFactData('Paid', paid.isEmpty ? '-' : paid),
            LibraryInspectorFactData(
              'Purchased',
              genericLibraryDash(
                formatNullableComicDate(ownedItem?.purchaseDate),
              ),
            ),
            if (ownedItem?.isSold ?? false) ...[
              LibraryInspectorFactData(
                'Sold',
                formatNullableComicDate(ownedItem?.soldAt) ?? 'Yes',
              ),
              LibraryInspectorFactData(
                'Sell price',
                ownedItem?.sellPriceCents != null
                    ? formatComicMoney(
                        ownedItem!.sellPriceCents, ownedItem!.currency)
                    : '-',
              ),
              LibraryInspectorFactData(
                'Sold to',
                genericLibraryDash(ownedItem?.soldTo),
              ),
            ],
            LibraryInspectorFactData(
              'Updated',
              formatNullableComicDate(entry.updatedAt) ?? '-',
            ),
            if (_isComicKind && ownedItem != null) ...[
              if (ownedItem!.rawOrSlabbed != null &&
                  ownedItem!.rawOrSlabbed!.trim().isNotEmpty)
                LibraryInspectorFactData(
                  'Raw / Slabbed',
                  ownedItem!.rawOrSlabbed!,
                ),
              if (ownedItem!.gradingCompany != null &&
                  ownedItem!.gradingCompany!.trim().isNotEmpty)
                LibraryInspectorFactData(
                  'Grading co.',
                  ownedItem!.gradingCompany!,
                ),
              if (ownedItem!.signedBy != null &&
                  ownedItem!.signedBy!.trim().isNotEmpty)
                LibraryInspectorFactData('Signed by', ownedItem!.signedBy!),
              if (ownedItem!.keyComic)
                LibraryInspectorFactData(
                  'Key',
                  ownedItem!.keyReason ?? 'Yes',
                ),
              if (ownedItem!.coverPriceCents != null)
                LibraryInspectorFactData(
                  'Cover price',
                  formatComicMoney(ownedItem!.coverPriceCents, null),
                ),
            ],
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

class GenericEmptyInspector extends StatelessWidget {
  const GenericEmptyInspector({
    super.key,
    required this.type,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LibraryEmptyInspector(
      icon: type.workspace.icon,
      label: type.singularLabel.toLowerCase(),
      accent: accent,
      mutedTextColor: kClzTextMuted,
      backgroundColor: kClzCanvas,
    );
  }
}
