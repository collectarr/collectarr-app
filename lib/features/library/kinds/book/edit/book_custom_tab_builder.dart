import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec_renderer.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/book_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/entry/book_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_person_credits_field.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_field_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_external_links_editor.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details_draft.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildBookCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,

  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  if (!{
    'main',
    'credits',
    'entry',
    'links',
    'covers',
    'plot',
  }.contains(tabId)) {
    return null;
  }
  final kindDraft = draft.session.catalogItemSession;
  if (kindDraft is! BookEditDraft) {
    throw StateError('Expected BookEditDraft for Book editing');
  }
  if (tabId == 'credits') {
    return EditTabShell(
      children: [
        BookPersonCreditsField(
          label: 'Authors',
          role: 'Author',
          credits: kindDraft.values.authors,
          onChanged: (credits) {
            kindDraft.values.authors = credits;
            markDirty();
          },
        ),
        const SizedBox(height: 10),
        BookPersonCreditsField(
          label: 'Translators',
          role: 'Translator',
          credits: kindDraft.values.translators,
          onChanged: (credits) {
            kindDraft.values.translators = credits;
            markDirty();
          },
        ),
      ],
    );
  }
  if (tabId != 'main' &&
      tabId != 'links' &&
      tabId != 'covers' &&
      tabId != 'plot') {
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

  final fieldIds = switch (tabId) {
    'main' => bookMainFieldIds,
    'links' => bookLinkFieldIds,
    'covers' => bookCoverFieldIds,
    _ => bookPlotFieldIds,
  };
  final sectionLabels = switch (tabId) {
    'main' => const {'edition': 'Edition', 'publication': 'Publication'},
    'links' => const {'edition': 'Identifiers'},
    'covers' => const {'edition': 'Front cover', 'publication': 'Back cover'},
    _ => const {'publication': 'Plot'},
  };
  final schema = bookAddSchemaFor<BookEditDraft>(
    fieldIds: fieldIds,
    sectionLabels: sectionLabels,
    publisherOptions: _options(
      draft,
      BookVocabularyIds.publisher.value,
      BookVocabularies.publisher.builtIns,
    ),
    formatOptions: _options(
      draft,
      BookVocabularyIds.format.value,
      BookVocabularies.format.builtIns,
    ),
  );
  return EditTabShell(
    children: [
      LibraryFieldSpecRenderer<BookEditDraft>.embedded(
        key: ValueKey('book-fields-${draft.type.kind.apiValue}-$tabId'),
        schema: schema,
        draft: kindDraft,
        mediaKind: draft.type.kind.apiValue,
        onChanged: markDirty,
        onVocabularyValueChanged: ({
          required fieldId,
          required listName,
          required value,
        }) {
          draft.recordPendingVocabularyValue(
            fieldId: fieldId,
            listName: listName,
            value: value,
            options: _optionsForField(draft, fieldId),
            allowCustomValues: true,
            mediaKind: draft.type.kind.apiValue,
          );
        },
      ),
      if (tabId == 'links') ...[
        const SizedBox(height: 12),
        BookExternalLinksEditor(
          links: kindDraft.externalLinks,
          accent: accent,
          onChanged: () {
            kindDraft.markExternalLinksEdited();
            markDirty();
          },
        ),
      ],
    ],
  );
}

List<String> _options(
  LibraryEditShellState draft,
  String key,
  Iterable<String> fallback,
) =>
    draft.kindVocabularies[key]?.toList(growable: false) ??
    fallback.toList(growable: false);

List<String> _optionsForField(LibraryEditShellState draft, String fieldId) =>
    switch (fieldId) {
      'publisher' => _options(
          draft,
          BookVocabularyIds.publisher.value,
          BookVocabularies.publisher.builtIns,
        ),
      'format' => _options(
          draft,
          BookVocabularyIds.format.value,
          BookVocabularies.format.builtIns,
        ),
      'binding' => _options(
          draft,
          BookVocabularyIds.binding.value,
          BookVocabularies.binding.builtIns,
        ),
      'language' => _options(
          draft,
          BookVocabularyIds.language.value,
          BookVocabularies.language.builtIns,
        ),
      _ => const <String>[],
    };
