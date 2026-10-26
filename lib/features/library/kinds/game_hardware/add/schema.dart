import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:flutter/widgets.dart';
import '../forms/main_form.dart';
import 'manual_draft.dart';

final gameHardwareAddSchema = gameHardwareManualSchema();
LibraryFormSchema<GameHardwareAddManualDraft> gameHardwareManualSchema(
        {Widget Function(BuildContext, GameHardwareAddManualDraft)?
            serialNumberBuilder}) =>
    LibraryFormSchema(
        validate: (draft) =>
            draft.catalogTitle.trim().isEmpty ? 'Enter a title' : null,
        sections: [
          gameHardwareMainSection<GameHardwareAddManualDraft>(
              titleFieldId: 'catalog_title',
              fields: [
                libraryAddCatalogTitleField<GameHardwareAddManualDraft>(),
                for (final field
                    in gameHardwareMainFields<GameHardwareAddManualDraft>(
                        values: (draft) => draft.values,
                        serialNumberBuilder: serialNumberBuilder))
                  if (field.id != 'title') field
              ])
        ]);
