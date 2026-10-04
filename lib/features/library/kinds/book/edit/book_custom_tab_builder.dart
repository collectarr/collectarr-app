import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/entry/book_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildBookCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  if (tabId != 'entry') return null;
  final kindDraft = draft.session.catalogItemSession;
  if (kindDraft is! BookEditDraft) {
    throw StateError('Expected BookEditDraft for Book entry editing');
  }
  final detailsDraft = kindDraft.toDetailsDraft() as BookEntryDetailsDraft;
  final details = detailsDraft.toDetails();
  return EditSchemaRenderer<BookEntryDetails, BookEditDraft>.embedded(
    schema: bookEntryEditSchema,
    model: details,
    draft: kindDraft,
    mediaKind: draft.type.kind.apiValue,
    showTabBar: false,
  );
}
