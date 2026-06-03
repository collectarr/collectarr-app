import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDetailActionStrip extends StatelessWidget {
  const LibraryDetailActionStrip({
    super.key,
    required this.type,
    required this.entry,
    this.activeOwnedItem,
    this.ownedCopies = const [],
    this.selectedOwnedItemId,
    this.onSelectOwnedItem,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? activeOwnedItem;
  final List<OwnedItem> ownedCopies;
  final String? selectedOwnedItemId;
  final ValueChanged<String?>? onSelectOwnedItem;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isOwned = ownedCopies.isNotEmpty || activeOwnedItem != null || entry.isOwned;
    final removeLabel = ownedCopies.length > 1
        ? 'Remove selected copy'
        : 'Remove ${type.singularLabel.toLowerCase()}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ownedCopies.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: ownedCopies.length < 2
                    ? Text(
                        '1 copy in collection',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    : DropdownButtonFormField<String>(
                        initialValue: selectedOwnedItemId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Active copy',
                        ),
                        items: [
                          for (var index = 0; index < ownedCopies.length; index += 1)
                            DropdownMenuItem<String>(
                              value: ownedCopies[index].id,
                              child: Text(
                                buildOwnedCopyLabel(
                                  ownedCopies[index],
                                  entry.editions,
                                  index,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: onSelectOwnedItem,
                      ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onAddOwned,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Add copy'),
              ),
            ],
          ),
          if (ownedCopies.length > 1) ...[
            const SizedBox(height: 8),
            Text(
              '${ownedCopies.length} copies in collection',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isOwned)
              FilledButton.icon(
                onPressed: onRemoveOwned,
                icon: const Icon(Icons.remove_circle_outline),
                label: Text(removeLabel),
              )
            else
              FilledButton.icon(
                onPressed: onAddOwned,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(
                  entry.isWishlisted
                      ? 'Convert wishlist to collection'
                      : 'Add to collection',
                ),
              ),
            OutlinedButton.icon(
              onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
              icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
              label: Text(
                entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
              ),
            ),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}

class LibraryDetailStatsBar extends StatelessWidget {
  const LibraryDetailStatsBar({
    super.key,
    required this.entry,
    required this.ownedItem,
    this.ownedCopies = const [],
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final totalCopies = ownedCopies.isEmpty ? (ownedItem == null ? 0 : 1) : ownedCopies.length;
    final totalQuantity = ownedCopies.isEmpty
        ? (ownedItem?.quantity ?? 0)
        : ownedCopies.fold<int>(0, (sum, item) => sum + item.quantity);
    final selectedCopyIndex = ownedItem == null || ownedCopies.isEmpty
        ? null
        : ownedCopies.indexWhere((item) => item.id == ownedItem!.id);
    final facts = <({String label, String value})>[
      (label: 'Status', value: genericLibraryStatusLabel(entry)),
      (label: 'Cover', value: entry.hasMissingCover ? 'Missing' : 'Ready'),
      (label: 'Metadata', value: entry.hasMissingMetadata ? 'Missing' : 'Ready'),
      (label: 'Quantity', value: totalQuantity.toString()),
      if (totalCopies > 1) (label: 'Copies', value: totalCopies.toString()),
      if (selectedCopyIndex != null && selectedCopyIndex >= 0)
        (label: 'Selected', value: 'Copy ${selectedCopyIndex + 1}'),
      (
        label: 'Updated',
        value: formatNullableDate(ownedItem?.updatedAt ?? entry.updatedAt) ?? '-',
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          top: BorderSide(color: palette.divider.withValues(alpha: 0.72)),
          bottom: BorderSide(color: palette.divider.withValues(alpha: 0.72)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final fact in facts)
              _LibraryDetailSummaryFact(
                label: fact.label,
                value: fact.value,
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryDetailSummaryFact extends StatelessWidget {
  const _LibraryDetailSummaryFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
