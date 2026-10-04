import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:flutter/material.dart';

final class BoardgameAddLinksTab extends StatefulWidget {
  const BoardgameAddLinksTab({
    super.key,
    required this.draft,
    required this.accent,
    this.onChanged,
  });

  final BoardgameAddManualDraft draft;
  final Color accent;
  final VoidCallback? onChanged;

  @override
  State<BoardgameAddLinksTab> createState() => _BoardgameAddLinksTabState();
}

final class _BoardgameAddLinksTabState extends State<BoardgameAddLinksTab> {
  @override
  Widget build(BuildContext context) => LibraryExternalLinksDraftEditor(
        links: widget.draft.externalLinks,
        accent: widget.accent,
        onChanged: widget.onChanged,
      );
}
