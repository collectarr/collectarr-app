import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/generic/library_display.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class LibraryDetailActionStrip extends StatelessWidget {
  const LibraryDetailActionStrip({
    super.key,
    required this.type,
    required this.entry,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (entry.isOwned)
          FilledButton.icon(
            onPressed: onRemoveOwned,
            icon: const Icon(Icons.remove_circle_outline),
            label: Text('Remove ${type.singularLabel.toLowerCase()}'),
          )
        else
          FilledButton.icon(
            onPressed: onAddOwned,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add to collection'),
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
    );
  }
}

class LibraryDetailStatsBar extends StatelessWidget {
  const LibraryDetailStatsBar({
    super.key,
    required this.entry,
    required this.ownedItem,
  });

  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LibraryStatPill(
          label: 'Status',
          value: genericLibraryStatusLabel(entry),
        ),
        LibraryStatPill(
          label: 'Cover',
          value: entry.hasMissingCover ? 'Missing' : 'Ready',
        ),
        LibraryStatPill(
          label: 'Metadata',
          value: entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
        LibraryStatPill(
          label: 'Quantity',
          value: ownedItem == null ? '0' : ownedItem!.quantity.toString(),
        ),
        LibraryStatPill(
          label: 'Updated',
          value: formatNullableDate(entry.updatedAt) ?? '-',
        ),
      ],
    );
  }
}
