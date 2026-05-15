import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/comics/comics_shelf_helpers.dart';
import 'package:collectarr_app/features/library/generic_library_display.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericDetailActionStrip extends StatelessWidget {
  const GenericDetailActionStrip({
    super.key,
    required this.type,
    required this.entry,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;

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
      ],
    );
  }
}

class GenericDetailStatsBar extends StatelessWidget {
  const GenericDetailStatsBar({
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
        GenericLibraryStatPill(
          label: 'Status',
          value: genericLibraryStatusLabel(entry),
        ),
        GenericLibraryStatPill(
          label: 'Cover',
          value: entry.hasMissingCover ? 'Missing' : 'Ready',
        ),
        GenericLibraryStatPill(
          label: 'Metadata',
          value: entry.hasMissingMetadata ? 'Missing' : 'Ready',
        ),
        GenericLibraryStatPill(
          label: 'Quantity',
          value: ownedItem == null ? '0' : ownedItem!.quantity.toString(),
        ),
        GenericLibraryStatPill(
          label: 'Updated',
          value: formatNullableComicDate(entry.updatedAt) ?? '-',
        ),
      ],
    );
  }
}
