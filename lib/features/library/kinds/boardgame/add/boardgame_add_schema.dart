import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_field_specs.dart';

final AddSchema<BoardgameAddManualDraft> boardGameAddSchema = AddSchema(
  title: (_) => 'Manual board game',
  validate: (draft) {
    final values = draft.values;
    if (values.yearPublished != null && values.yearPublished! < 1) {
      return 'Year published must be greater than zero';
    }
    if (values.releaseDate != null && values.releaseDate!.year < 1) {
      return 'Release date is invalid';
    }
    if (values.minPlayers != null &&
        values.maxPlayers != null &&
        values.minPlayers! > values.maxPlayers!) {
      return 'Minimum players cannot exceed maximum players';
    }
    return null;
  },
  sections: [
    AddSectionSpec<BoardgameAddManualDraft>(
      id: 'catalog_item',
      label: 'Catalog Item',
      fields: [
        libraryAddCatalogTitleField<BoardgameAddManualDraft>(),
        ...boardGameCatalogItemFields(values: (draft) => draft.values),
      ],
      fullWidthFieldIds: const {'catalog_title'},
    ),
  ],
);
