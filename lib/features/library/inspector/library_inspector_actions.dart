import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorPrimaryActions extends StatelessWidget {
  const InspectorPrimaryActions({
    super.key,
    required this.item,
    required this.type,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
  });

  final LibraryProjectionView item;
  final LibraryKindRegistration type;
  final VoidCallback? onAddEntry;
  final VoidCallback? onRemoveEntry;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    if (item.source.isEntry) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          OutlinedButton.icon(
            onPressed:
                item.source.isWishlisted ? onRemoveWishlist : onAddWishlist,
            icon:
                Icon(item.source.isWishlisted ? Icons.star : Icons.star_border),
            label: Text(
              item.source.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
            ),
          ),
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
          FilledButton.icon(
            onPressed: onRemoveEntry,
            icon: const Icon(Icons.remove_circle_outline),
            label: Text('Remove ${type.identity.singularLabel.toLowerCase()}'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAddEntry,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(
            item.source.isWishlisted
                ? 'Convert wishlist to collection'
                : 'Add to collection',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    item.source.isWishlisted ? onRemoveWishlist : onAddWishlist,
                icon: Icon(
                    item.source.isWishlisted ? Icons.star : Icons.star_border),
                label: Text(
                  item.source.isWishlisted
                      ? 'Remove from wishlist'
                      : 'Add to wishlist',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
