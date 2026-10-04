import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema_renderer.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/entry/game_entry_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/game/entries/game_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_field_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/edit/game_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/vocabulary/game_vocabularies.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:flutter/material.dart';

Widget? buildGameCustomTabView({
  required String tabId,
  required BuildContext context,
  required LibraryEditShellState draft,
  required Color accent,
  required LibraryEntityScope scope,
  required CatalogSearchCandidate item,
  required VoidCallback markDirty,
}) {
  final kindDraft = draft.session.catalogItemSession;
  if (kindDraft is! GameEditDraft) {
    throw StateError('Expected GameEditDraft for Game editing');
  }

  if (tabId == 'entry') {
    final detailsDraft = kindDraft.toDetailsDraft() as GameEntryDetailsDraft;
    final details = detailsDraft.toDetails();
    return EditSchemaRenderer<GameEntryDetails, GameEditDraft>.embedded(
      schema: gameEntryEditSchema,
      model: details,
      draft: kindDraft,
      mediaKind: draft.type.kind.apiValue,
      showTabBar: false,
    );
  }

  final fieldIds = switch (tabId) {
    'main' => gameMainFieldIds,
    'edition' => gameEditionFieldIds,
    'synopsis' => gameDescriptionFieldIds,
    'cover' => gameCoverFieldIds,
    _ => null,
  };
  if (fieldIds == null) return null;

  final sectionLabels = switch (tabId) {
    'main' => const {
        'catalog_item': 'Main',
        'game_details': 'Game details',
      },
    'edition' => const {'catalog_item': 'Edition'},
    'synopsis' => const {'game_details': 'Description'},
    _ => const {'catalog_item': 'Covers'},
  };
  final platformOptions = _options(
    draft,
    GameVocabularyIds.platform.value,
    GameVocabularies.platform.builtIns,
  );
  final regionOptions = _options(
    draft,
    GameVocabularyIds.region.value,
    GameVocabularies.region.builtIns,
  );
  final editionOptions = draft.physicalFormats.isNotEmpty
      ? [for (final format in draft.physicalFormats) format.label]
      : _options(
          draft,
          GameVocabularyIds.edition.value,
          GameVocabularies.edition.builtIns,
        );
  final ageRatingOptions = _options(
    draft,
    GameVocabularyIds.ageRating.value,
    GameVocabularies.ageRating.builtIns,
  );
  final schema = gameAddSchemaFor<GameEditDraft>(
    fieldIds: fieldIds,
    sectionLabels: sectionLabels,
    platformOptions: platformOptions,
    regionOptions: regionOptions,
    editionOptions: editionOptions,
    ageRatingOptions: ageRatingOptions,
    physicalFormatIdForValue: (value) =>
        _physicalFormatId(value, draft.physicalFormats),
  );

  return EditTabShell(
    children: [
      AddSchemaRenderer<GameEditDraft>.embedded(
        key: ValueKey('game-fields-${draft.type.kind.apiValue}-$tabId'),
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
        onVocabularyValuesChanged: ({
          required fieldId,
          required listName,
          required values,
        }) {
          draft.recordPendingVocabularyValues(
            fieldId: fieldId,
            listName: listName,
            values: values,
            options: _optionsForField(draft, fieldId),
            allowCustomValues: true,
            mediaKind: draft.type.kind.apiValue,
          );
        },
      ),
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

List<String> _optionsForField(
  LibraryEditShellState draft,
  String fieldId,
) =>
    switch (fieldId) {
      'platforms' => _options(
          draft,
          GameVocabularyIds.platform.value,
          GameVocabularies.platform.builtIns,
        ),
      'age_ratings' => _options(
          draft,
          GameVocabularyIds.ageRating.value,
          GameVocabularies.ageRating.builtIns,
        ),
      'region' => _options(
          draft,
          GameVocabularyIds.region.value,
          GameVocabularies.region.builtIns,
        ),
      'format' when draft.physicalFormats.isNotEmpty => [
          for (final format in draft.physicalFormats) format.label,
        ],
      'format' => _options(
          draft,
          GameVocabularyIds.edition.value,
          GameVocabularies.edition.builtIns,
        ),
      _ => const <String>[],
    };

String? _physicalFormatId(
  String value,
  List<PhysicalMediaFormat> formats,
) {
  final matching = physicalMediaFormatByLabelOrId(value, formats: formats);
  return matching?.id;
}
