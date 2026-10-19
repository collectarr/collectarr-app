import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_main_form_section.dart';

/// Manual Add Main tab: the editor's Main composition with the shared
/// catalog title field.
final LibraryFormSchema<GameAddManualDraft> gameAddSchema = LibraryFormSchema(
  title: (_) => 'Manual game',
  validate: (draft) {
    if (draft.values.releaseDateParts?.year case final year? when year < 1) {
      return 'Release year must be greater than zero';
    }
    return null;
  },
  sections: [
    gameMainFormSection<GameAddManualDraft>(
      titleFieldId: 'catalog_title',
      fields: [
        libraryAddCatalogTitleField<GameAddManualDraft>(
            actions: gameTitleActions, required: false),
        for (final field
            in gameMainFields<GameAddManualDraft>(values: (d) => d.values))
          if (field.id != GameMainFieldIds.title) field,
      ],
    ),
  ],
);
