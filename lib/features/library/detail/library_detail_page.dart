import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/detail/library_detail_actions.dart';
import 'package:collectarr_app/features/library/detail/library_detail_catalog_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_collection_sections.dart';
import 'package:collectarr_app/features/library/detail/library_detail_hero.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LibraryDetailPage extends StatelessWidget {
  const LibraryDetailPage({
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
    this.onFilterByValue,
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
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: kLibraryTheme,
      child: Scaffold(
        backgroundColor: kAppCanvas,
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
            LibraryDetailHero(
              type: type,
              entry: entry,
              ownedItem: ownedItem,
              accent: accent,
            ),
            const SizedBox(height: 12),
            LibraryDetailActionStrip(
              type: type,
              entry: entry,
              onAddOwned: onAddOwned,
              onRemoveOwned: onRemoveOwned,
              onAddWishlist: onAddWishlist,
              onRemoveWishlist: onRemoveWishlist,
              onEdit: onEdit,
            ),
            const SizedBox(height: 16),
            LibraryDetailStatsBar(entry: entry, ownedItem: ownedItem),
            const SizedBox(height: 16),
            LibraryDetailMetadataSection(
              type: type,
              entry: entry,
              accent: accent,
              onFilterByValue: onFilterByValue,
            ),
            LibraryDetailContextSection(
              type: type,
              entry: entry,
              accent: accent,
              onFilterByValue: onFilterByValue,
            ),
            LibraryDetailCreditsSection(
              type: type,
              entry: entry,
              accent: accent,
              onFilterByValue: onFilterByValue,
            ),
            LibraryDetailProvenanceSection(
              type: type,
              entry: entry,
              accent: accent,
            ),
            LibraryDetailMetadataHealthSection(
              entry: entry,
              accent: accent,
            ),
            LibraryDetailCoverStatusSection(entry: entry, accent: accent),
            LibraryDetailPersonalSection(
              entry: entry,
              ownedItem: ownedItem,
              accent: accent,
            ),
            LibraryDetailProviderSection(type: type, accent: accent),
            LibraryDetailLocalSnapshotSection(
              entry: entry,
              ownedItem: ownedItem,
            ),
          ],
        ),
      ),
    );
  }
}
