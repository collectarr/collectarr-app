import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryDetailPersonalSection extends StatelessWidget {
  const LibraryDetailPersonalSection({
    super.key,
    required this.entry,
    required this.ownedItem,
    required this.accent,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final paid = formatMoney(entry.pricePaidCents, entry.currency);
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
                formatNullableDate(ownedItem?.purchaseDate),
              ),
            ),
            LibraryInspectorFactData(
              'Updated',
              formatNullableDate(entry.updatedAt) ?? '-',
            ),
            LibraryInspectorFactData(
              'Read status',
              genericLibraryDash(ownedItem?.readStatus),
            ),
            LibraryInspectorFactData(
              'Rating',
              ownedItem?.rating?.toString() ?? '-',
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
                color: kClzTextMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
