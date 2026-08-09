import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDetailActionStrip extends StatelessWidget {
  const LibraryDetailActionStrip({
    super.key,
    required this.type,
    required this.item,
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
  final LibraryProjectionRuntime item;
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
    final isOwned =
        ownedCopies.isNotEmpty || activeOwnedItem != null || item.source.isOwned;
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
                child: DropdownButtonFormField<String>(
                  initialValue: selectedOwnedItemId,
                  decoration: const InputDecoration(
                    labelText: 'Copy in collection',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: [
                    for (var index = 0; index < ownedCopies.length; index += 1)
                      DropdownMenuItem<String>(
                        value: ownedCopies[index].id,
                        child: Text(
                          buildOwnedCopyLabel(
                              ownedCopies[index], const [], index),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: onSelectOwnedItem,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onAddOwned,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                isOwned ? 'Add another copy' : 'Add to collection',
              ),
            ),
            if (item.source.isWishlisted)
              OutlinedButton.icon(
                onPressed: onRemoveWishlist,
                icon: const Icon(Icons.star),
                label: const Text('Remove wishlist'),
              )
            else if (!isOwned)
              OutlinedButton.icon(
                onPressed: onAddWishlist,
                icon: const Icon(Icons.star_border),
                label: const Text('Move to wishlist'),
              ),
            if (isOwned && onRemoveOwned != null)
              OutlinedButton.icon(
                onPressed: onRemoveOwned,
                icon: const Icon(Icons.remove_circle_outline),
                label: Text(removeLabel),
              ),
            if (onEdit != null)
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit metadata'),
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
    required this.item,
    required this.ownedItem,
    this.ownedCopies = const [],
  });

  final LibraryProjectionRuntime item;
  final OwnedItem? ownedItem;
  final List<OwnedItem> ownedCopies;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final dto = item.dto;
    final totalCopies =
        ownedCopies.isEmpty ? (ownedItem == null ? 0 : 1) : ownedCopies.length;
    final totalQuantity = ownedCopies.isEmpty
        ? (ownedItem?.quantity ?? 0)
        : ownedCopies.fold<int>(0, (sum, i) => sum + i.quantity);
    final selectedCopyIndex = ownedItem == null || ownedCopies.isEmpty
        ? null
        : ownedCopies.indexWhere((i) => i.id == ownedItem!.id);
    final facts = <({String label, String value})>[
      (label: 'Status', value: genericLibraryStatusLabel(item)),
      (
        label: 'Cover',
        value: dto.coverImageUrl == null || dto.coverImageUrl!.isEmpty
            ? 'Missing'
            : 'Ready'
      ),
      (
        label: 'Metadata',
        value: dto.publisher == null || dto.publisher!.isEmpty
            ? 'Missing'
            : 'Ready'
      ),
      (label: 'Quantity', value: totalQuantity.toString()),
      if (totalCopies > 1) (label: 'Copies', value: totalCopies.toString()),
      if (selectedCopyIndex != null && selectedCopyIndex >= 0)
        (label: 'Selected', value: 'Copy ${selectedCopyIndex + 1}'),
      (
        label: 'Updated',
        value:
            formatNullableDate(ownedItem?.updatedAt ?? dto.releaseDate) ?? '-',
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final fact in facts)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${fact.label}: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                  ),
                  Text(
                    fact.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
