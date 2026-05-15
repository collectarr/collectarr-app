import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericInspectorPrimaryActions extends StatelessWidget {
  const GenericInspectorPrimaryActions({
    super.key,
    required this.entry,
    required this.type,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
  });

  final LibraryWorkspaceEntry entry;
  final LibraryTypeConfig type;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;

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
          label: const Text('Add to collection'),
        ),
        const SizedBox(height: 8),
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
