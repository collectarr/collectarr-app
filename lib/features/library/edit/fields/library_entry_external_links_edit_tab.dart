import 'package:collectarr_app/features/library/detail/library_external_links_section.dart';
import 'package:collectarr_app/features/library/edit/draft/library_user_external_links_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_editor.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

/// Shared Links tab for kinds whose user links belong to a local entry.
final class LibraryEntryExternalLinksEditTab extends StatelessWidget {
  const LibraryEntryExternalLinksEditTab({
    super.key,
    required this.catalogLinks,
    required this.userExternalLinks,
    required this.isEntry,
    required this.accent,
    required this.markDirty,
  });

  final List<TrailerLinkDto> catalogLinks;
  final LibraryUserExternalLinksDraft userExternalLinks;
  final bool isEntry;
  final Color accent;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    void markLinksChanged() {
      userExternalLinks.markChanged();
      markDirty();
    }

    return EditTabShell(
      children: [
        if (catalogLinks.isNotEmpty)
          EditSection(
            title: 'Catalog links',
            accent: accent,
            child: LibraryExternalLinksSection(
              title: 'Catalog links',
              links: catalogLinks,
              accent: accent,
            ),
          ),
        if (isEntry) ...[
          EditSection(
            title: 'User links',
            accent: accent,
            child: LibraryExternalLinksEditor(
              title: 'User links',
              items: userExternalLinks.userLinks,
              accent: accent,
              onAdd: () => userExternalLinks.add(kind: 'custom'),
              onChanged: markLinksChanged,
            ),
          ),
          EditSection(
            title: 'Trailers',
            accent: accent,
            child: LibraryExternalLinksEditor(
              title: 'Trailers',
              items: userExternalLinks.trailers,
              accent: accent,
              onAdd: () => userExternalLinks.add(kind: 'trailer'),
              onChanged: markLinksChanged,
            ),
          ),
        ] else
          EditSection(
            title: 'User links',
            accent: accent,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Add this item to your library to manage personal links.',
              ),
            ),
          ),
      ],
    );
  }
}
