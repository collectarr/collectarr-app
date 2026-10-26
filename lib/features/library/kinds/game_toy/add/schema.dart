import 'package:collectarr_app/features/library/add/schema/library_add_catalog_title_field.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import '../forms/main_form.dart';
import 'manual_draft.dart';

final gameToyAddSchema = gameToyManualSchema();
LibraryFormSchema<GameToyAddManualDraft> gameToyManualSchema() =>
    LibraryFormSchema(
        validate: (draft) =>
            draft.catalogTitle.trim().isEmpty ? 'Enter a title' : null,
        sections: [
          gameToyMainSection<GameToyAddManualDraft>(
              titleFieldId: 'catalog_title',
              fields: [
                libraryAddCatalogTitleField<GameToyAddManualDraft>(),
                for (final field in gameToyMainFields<GameToyAddManualDraft>(
                    values: (draft) => draft.values))
                  if (field.id != 'title') field
              ])
        ]);
