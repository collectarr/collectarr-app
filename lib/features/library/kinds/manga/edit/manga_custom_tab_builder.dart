import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/owned/manga_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildMangaCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  if (tabId != 'owned') return null;
  final kindDraft = draft.kindDetails;
  if (kindDraft is! MangaEditDraft) {
    throw StateError('Expected MangaEditDraft for Manga owned editing');
  }
  final detailsDraft = kindDraft.toDetailsDraft() as MangaOwnedDetailsDraft;
  final details = detailsDraft.toDetails();
  return EditSchemaRenderer<MangaOwnedDetails, MangaEditDraft>(
    schema: mangaOwnedEditSchema,
    model: details,
    draft: kindDraft,
    showTabBar: false,
    showFooter: false,
    onSave: (_) {},
    onCancel: () {},
  );
}
