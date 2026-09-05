import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/owned/manga_owned_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:flutter/material.dart';

Widget? buildMangaCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditDraft draft,
  required Color accent,
  required LibraryEditScope scope,
  required CatalogItem item,
  required VoidCallback markDirty,
}) {
  if (tabId != 'owned') return null;
  final kindDraft = draft.kindDetails;
  if (kindDraft is! MangaEditDraft) {
    throw StateError('Expected MangaEditDraft for Manga owned editing');
  }
  final detailsDraft = kindDraft.toDetailsDraft();
  final details = detailsDraft.toDetails();
  if (details is! MangaOwnedDetails) {
    throw StateError('Expected MangaOwnedDetails for Manga owned editing');
  }
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
