import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class InspectorPrimaryActions extends StatelessWidget {
  const InspectorPrimaryActions({
    super.key,
    required this.entry,
    required this.type,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
  });

  final LibraryWorkspaceEntry entry;
  final LibraryTypeConfig type;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    if (entry.isOwned) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
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
          FilledButton.icon(
            onPressed: onRemoveOwned,
            icon: const Icon(Icons.remove_circle_outline),
            label: Text('Remove ${type.singularLabel.toLowerCase()}'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAddOwned,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(
            entry.isWishlisted
                ? 'Convert wishlist to collection'
                : 'Add to collection',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
          icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
          label: Text(
            entry.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit metadata'),
        ),
      ],
    );
  }
}
