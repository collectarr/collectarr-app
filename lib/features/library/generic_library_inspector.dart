import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/library/generic_library_detail_page.dart';
import 'package:collectarr_app/features/library/generic_library_inspector_header.dart';
import 'package:collectarr_app/features/library/generic_library_inspector_sections.dart';
import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';

class GenericLibraryInspector extends StatelessWidget {
  const GenericLibraryInspector({
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
  final LibraryWorkspaceEntry? entry;
  final OwnedItem? ownedItem;
  final Color accent;
  final VoidCallback? onAddOwned;
  final VoidCallback? onRemoveOwned;
  final VoidCallback? onAddWishlist;
  final VoidCallback? onRemoveWishlist;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final selected = entry;
    if (selected == null) {
      return GenericEmptyInspector(type: type, accent: accent);
    }
    return Stack(
      children: [
        Positioned.fill(
          child: GenericInspectorBackdrop(entry: selected),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xBA111111)),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              GenericInspectorActionBar(
                type: type,
                entry: selected,
                onToggleOwned: selected.isOwned ? onRemoveOwned : onAddOwned,
                onToggleWishlist:
                    selected.isWishlisted ? onRemoveWishlist : onAddWishlist,
                onEdit: onEdit,
                onOpenDetails: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GenericLibraryDetailPage(
                      type: type,
                      entry: selected,
                      ownedItem: ownedItem,
                      accent: accent,
                      onAddOwned: onAddOwned,
                      onRemoveOwned: onRemoveOwned,
                      onAddWishlist: onAddWishlist,
                      onRemoveWishlist: onRemoveWishlist,
                      onEdit: onEdit,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              GenericInspectorHero(
                type: type,
                entry: selected,
                ownedItem: ownedItem,
                accent: accent,
              ),
              const SizedBox(height: 10),
              GenericInspectorPrimaryActions(
                entry: selected,
                type: type,
                onAddOwned: onAddOwned,
                onRemoveOwned: onRemoveOwned,
                onAddWishlist: onAddWishlist,
                onRemoveWishlist: onRemoveWishlist,
                onEdit: onEdit,
              ),
              const SizedBox(height: 10),
              GenericMetadataSection(
                type: type,
                entry: selected,
                accent: accent,
              ),
              GenericPersonalSection(
                entry: selected,
                ownedItem: ownedItem,
                accent: accent,
              ),
              if (selected.synopsis != null &&
                  selected.synopsis!.trim().isNotEmpty)
                LibraryInspectorSection(
                  title: 'Summary',
                  accentColor: accent,
                  children: [
                    Text(
                      selected.synopsis!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              if (type.supportedMetadataProviders.isNotEmpty)
                LibraryInspectorSection(
                  title: 'Providers',
                  accentColor: accent,
                  children: [
                    LibraryInspectorChipWrap(
                      values: [
                        for (final provider in type.supportedMetadataProviders)
                          provider.label,
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
