import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:flutter/material.dart';

final class ComicAddLinksTab extends StatelessWidget {
  const ComicAddLinksTab({
    super.key,
    required this.draft,
    required this.accent,
    this.onChanged,
  });

  final ComicAddManualDraft draft;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) => LibraryExternalLinksDraftEditor(
        links: draft.externalLinks,
        accent: accent,
        onChanged: onChanged,
      );
}
