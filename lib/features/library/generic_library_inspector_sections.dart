import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/generic_library_display.dart';
import 'package:collectarr_app/features/library/library_media_field_labels.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericMetadataSection extends StatelessWidget {
  const GenericMetadataSection({
    super.key,
    required this.type,
    required this.entry,
    required this.accent,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final Color accent;

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
            LibraryInspectorFactData(
              labels.publisher,
              genericLibraryDash(entry.publisher),
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
            ),
            LibraryInspectorFactData(
              labels.variant,
              genericLibraryDash(entry.variant),
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
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final paid = formatComicMoney(entry.pricePaidCents, entry.currency);
    return LibraryInspectorSection(
      title: 'Personal',
      accentColor: accent,
      children: [
        LibraryInspectorFactGrid(
          facts: [
            LibraryInspectorFactData(
              'Status',
              genericLibraryStatusLabel(entry),
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
            LibraryInspectorFactData(
              'Updated',
              formatNullableComicDate(entry.updatedAt) ?? '-',
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
    return ColoredBox(
      color: kClzCanvas,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.workspace.icon, size: 42, color: accent),
            const SizedBox(height: 12),
            Text(
              'No ${type.singularLabel.toLowerCase()} selected',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Select an item to inspect metadata, cover, and local status.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kClzTextMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
