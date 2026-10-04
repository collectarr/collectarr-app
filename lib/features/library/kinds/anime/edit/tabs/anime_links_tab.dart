import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/detail/library_external_links_section.dart';
import 'package:collectarr_app/features/library/edit/draft/library_user_external_links_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_edit_field_groups.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_metadata.dart';
import 'package:flutter/material.dart';

class AnimeEditLinksTab extends StatelessWidget {
  const AnimeEditLinksTab({
    super.key,
    required this.item,
    required this.accent,
    required this.userExternalLinks,
    required this.isEntry,
    required this.markDirty,
  });

  final CatalogSearchCandidate item;
  final Color accent;
  final LibraryUserExternalLinksDraft userExternalLinks;
  final bool isEntry;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) {
    void markLinksChanged() {
      userExternalLinks.markChanged();
      markDirty();
    }

    final catalogLinks = item.kindCapability.mapTransport(
      (transport) => AnimeMetadata.fromJson(transport.kindData).links,
    );
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
