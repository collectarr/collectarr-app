import 'package:collectarr_app/features/library/details/library_detail_title_status_card.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

/// The collection-status icon + label shown on inspector/detail surfaces,
/// derived from a workspace entry's ownership/wishlist state.
///
/// This derivation was duplicated verbatim across every kind's inspector panel;
/// it now lives here so the icon/label stay consistent everywhere.
class LibraryEntryStatusDescriptor {
  const LibraryEntryStatusDescriptor({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

LibraryEntryStatusDescriptor libraryEntryStatusDescriptor(
  LibraryWorkspaceEntry entry,
) {
  if (entry.isOwned) {
    return const LibraryEntryStatusDescriptor(
      icon: Icons.inventory_2_outlined,
      label: 'In collection',
    );
  }
  if (entry.isWishlisted) {
    return const LibraryEntryStatusDescriptor(
      icon: Icons.star_border,
      label: 'Wishlist',
    );
  }
  return const LibraryEntryStatusDescriptor(
    icon: Icons.star_border,
    label: 'Catalog',
  );
}

/// Shared inspector title card: renders [LibraryDetailTitleStatusCard] with the
/// collection status derived from [entry]. Replaces per-kind copies of the same
/// eyebrow + title + status-chip header.
class LibraryInspectorTitleCard extends StatelessWidget {
  const LibraryInspectorTitleCard({
    super.key,
    required this.entry,
    required this.accent,
    this.eyebrow,
  });

  final LibraryWorkspaceEntry entry;
  final Color accent;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final status = libraryEntryStatusDescriptor(entry);
    return LibraryDetailTitleStatusCard(
      eyebrow: eyebrow,
      title: entry.resolvedTitle,
      accent: accent,
      statusIcon: status.icon,
      statusLabel: status.label,
    );
  }
}
