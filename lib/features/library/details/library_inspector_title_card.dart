import 'package:collectarr_app/features/library/details/library_detail_title_status_card.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:flutter/material.dart';

class LibraryEntryStatusDescriptor {
  const LibraryEntryStatusDescriptor({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

LibraryEntryStatusDescriptor libraryEntryStatusDescriptor(
  LibraryProjectionRuntime item,
) {
  if (item.source.isOwned) {
    return const LibraryEntryStatusDescriptor(
      icon: Icons.inventory_2_outlined,
      label: 'In collection',
    );
  }
  if (item.source.isWishlisted) {
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

class LibraryInspectorTitleCard extends StatelessWidget {
  const LibraryInspectorTitleCard({
    super.key,
    required this.item,
    required this.accent,
    this.eyebrow,
  });

  final LibraryProjectionRuntime item;
  final Color accent;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final dto = item.dto;
    final status = libraryEntryStatusDescriptor(item);
    return LibraryDetailTitleStatusCard(
      eyebrow: eyebrow,
      title: dto.title,
      accent: accent,
      statusIcon: status.icon,
      statusLabel: status.label,
    );
  }
}
