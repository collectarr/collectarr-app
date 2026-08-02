import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class InspectorPrimaryActions extends StatelessWidget {
  const InspectorPrimaryActions({
    super.key,
    required this.item,
    required this.type,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
  });

  final LibraryProjectionRuntime item;
  final LibraryTypeConfig type;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    if (dto.isOwned) {
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          OutlinedButton.icon(
            onPressed: dto.isWishlisted ? onRemoveWishlist : onAddWishlist,
            icon: Icon(dto.isWishlisted ? Icons.star : Icons.star_border),
            label: Text(
              dto.isWishlisted ? 'Remove from wishlist' : 'Move to wishlist',
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
            dto.isWishlisted
                ? 'Convert wishlist to collection'
                : 'Add to collection',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: dto.isWishlisted ? onRemoveWishlist : onAddWishlist,
                icon: Icon(dto.isWishlisted ? Icons.star : Icons.star_border),
                label: Text(
                  dto.isWishlisted ? 'Remove from wishlist' : 'Add to wishlist',
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
