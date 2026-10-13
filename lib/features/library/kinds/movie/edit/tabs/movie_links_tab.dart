import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/edit/draft/library_user_external_links_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_entry_external_links_edit_tab.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_metadata.dart';
import 'package:flutter/material.dart';

class MovieEditLinksTab extends StatelessWidget {
  const MovieEditLinksTab({
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
    final catalogLinks = item.kindCapability
        .mapTransport(
          (transport) => MovieCatalogMetadata.fromJson(transport.kindData),
        )
        .links
        .where((link) => link.isExternalLink)
        .toList(growable: false);
    return LibraryEntryExternalLinksEditTab(
      catalogLinks: catalogLinks,
      userExternalLinks: userExternalLinks,
      isEntry: isEntry,
      accent: accent,
      markDirty: markDirty,
    );
  }
}
