import 'package:collectarr_app/features/library/add/schema/catalog_title_field.dart';
import 'package:collectarr_app/features/library/forms/schema.dart';
import 'package:flutter/widgets.dart';
import '../forms/main_form.dart';
import 'manual_draft.dart';

final gameHardwareAddSchema = gameHardwareManualSchema();
LibraryFormSchema<GameHardwareAddManualDraft> gameHardwareManualSchema(
        {Widget Function(BuildContext, GameHardwareAddManualDraft)?
            serialNumberBuilder}) =>
    LibraryFormSchema(sections: [
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
