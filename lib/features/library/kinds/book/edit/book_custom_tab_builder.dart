import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/owned/book_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/ownership/book_owned_details.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';

Widget? buildBookCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required LibraryMetadataItem item,
  required VoidCallback markDirty,
}) {
  if (tabId != 'owned') return null;
  final kindDraft = draft.kindDetails;
  if (kindDraft is! BookEditDraft) {
    throw StateError('Expected BookEditDraft for Book owned editing');
  }
  final details = kindDraft.toDetailsDraft().toDetails();
  if (details is! BookOwnedDetails) {
    throw StateError('Expected BookOwnedDetails for Book owned editing');
  }
  return EditSchemaRenderer<BookOwnedDetails, BookEditDraft>(
    schema: bookOwnedEditSchema,
    model: details,
    draft: kindDraft,
    showTabBar: false,
    showFooter: false,
    onSave: (_) {},
    onCancel: () {},
  );
}
