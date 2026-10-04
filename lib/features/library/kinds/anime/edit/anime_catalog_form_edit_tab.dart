import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/kinds/anime/add/anime_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/anime/edit/anime_edit_draft_contract.dart';
import 'package:flutter/material.dart';

/// Renders a subset of Anime's Add schema inside the parent Edit dialog.
final class AnimeCatalogFormEditTab extends StatelessWidget {
  const AnimeCatalogFormEditTab({
    super.key,
    required this.state,
    required this.draft,
    required this.itemId,
    required this.fieldIds,
    required this.sectionLabel,
    required this.markDirty,
  });

  final LibraryEditShellState state;
  final AnimeEditDraftContract draft;
  final String itemId;
  final Set<String> fieldIds;
  final String sectionLabel;
  final VoidCallback markDirty;

  @override
  Widget build(BuildContext context) => EditTabShell(
        children: [
          AddSchemaRenderer<AnimeEditDraftContract>.embedded(
            key: ValueKey('anime-fields-$itemId-$sectionLabel'),
            schema: animeAddSchemaFor<AnimeEditDraftContract>(
              fieldIds: fieldIds,
              sectionLabel: sectionLabel,
            ),
            draft: draft,
            mediaKind: state.type.kind.apiValue,
            onChanged: markDirty,
          ),
        ],
      );
}
