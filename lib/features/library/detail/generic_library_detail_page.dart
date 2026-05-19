import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/ui/clz_style.dart';
import 'package:collectarr_app/features/library/detail/generic_library_detail_header.dart';
import 'package:collectarr_app/features/library/detail/generic_library_detail_sections.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericLibraryDetailPage extends StatelessWidget {
  const GenericLibraryDetailPage({
    super.key,
    required this.type,
    required this.entry,
    required this.ownedItem,
    required this.accent,
    required this.onAddOwned,
    required this.onRemoveOwned,
    required this.onAddWishlist,
    required this.onRemoveWishlist,
    required this.onEdit,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceEntry entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kClzComicsTheme,
      child: Scaffold(
        backgroundColor: kClzCanvas,
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          title: Text(entry.title),
          actions: [
            IconButton(
              tooltip: 'Edit metadata and collection fields',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: entry.isWishlisted
                  ? 'Remove from wishlist'
                  : 'Move to wishlist',
              onPressed: entry.isWishlisted ? onRemoveWishlist : onAddWishlist,
              icon: Icon(entry.isWishlisted ? Icons.star : Icons.star_border),
            ),
            IconButton(
              tooltip: entry.isOwned
                  ? 'Remove from collection'
                  : 'Add to collection',
              onPressed: entry.isOwned ? onRemoveOwned : onAddOwned,
              icon: Icon(
                entry.isOwned
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GenericDetailHero(
              type: type,
              entry: entry,
              ownedItem: ownedItem,
              accent: accent,
            ),
            const SizedBox(height: 12),
            GenericDetailActionStrip(
              type: type,
              entry: entry,
              onAddOwned: onAddOwned,
              onRemoveOwned: onRemoveOwned,
              onAddWishlist: onAddWishlist,
              onRemoveWishlist: onRemoveWishlist,
              onEdit: onEdit,
            ),
            const SizedBox(height: 16),
            GenericDetailStatsBar(entry: entry, ownedItem: ownedItem),
            const SizedBox(height: 16),
            GenericDetailMetadataSection(
              type: type,
              entry: entry,
              accent: accent,
            ),
            GenericDetailCoverStatusSection(entry: entry, accent: accent),
            GenericDetailPersonalSection(
              entry: entry,
              ownedItem: ownedItem,
              accent: accent,
            ),
            GenericDetailProviderSection(type: type, accent: accent),
            GenericDetailLocalSnapshotSection(
              entry: entry,
              ownedItem: ownedItem,
            ),
          ],
        ),
      ),
    );
  }
}
