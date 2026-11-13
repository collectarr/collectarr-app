import 'package:collectarr_app/features/library/add/schema/catalog_title_field.dart';
import 'package:collectarr_app/features/library/forms/schema.dart';
import '../forms/main_form_section.dart';
import 'manual_draft.dart';

final gameToyAddSchema = gameToyManualSchema();
LibraryFormSchema<GameToyAddManualDraft> gameToyManualSchema() =>
    LibraryFormSchema(sections: [
      gameToyMainSection<GameToyAddManualDraft>(
          titleFieldId: 'catalog_title',
          fields: [
            libraryAddCatalogTitleField<GameToyAddManualDraft>(),
            for (final field in gameToyMainFields<GameToyAddManualDraft>(
                values: (draft) => draft.values))
              if (field.id != 'title') field
          ])
    ]);
