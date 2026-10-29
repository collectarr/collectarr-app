import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:flutter/material.dart';

extension ComicLinksTab on ComicEditHost {
  Widget buildComicLinksTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'External Links',
          accent: comicAccent,
          child: LibraryExternalLinksDraftEditor(
            links: comicLinks,
            accent: comicAccent,
            addLabel: 'New Link',
            onChanged: () => comicMutateState(() {}),
          ),
        ),
      ],
    );
  }
}
