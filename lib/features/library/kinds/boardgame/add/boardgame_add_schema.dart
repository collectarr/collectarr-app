import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/add/boardgame_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/forms/boardgame_catalog_field_specs.dart';

final AddSchema<BoardgameAddManualDraft> boardGameAddSchema =
    boardGameAddSchemaFor();

AddSchema<TDraft>
    boardGameAddSchemaFor<TDraft extends BoardGameCatalogFormDraft>({
  Set<String>? fieldIds,
  Map<String, String> sectionLabels = const {},
  Iterable<String>? publisherOptions,
  Iterable<String>? categoryOptions,
  Iterable<String>? formatOptions,
  FutureOr<void> Function()? onManagePublisher,
}) {
  BoardGameCatalogFormValues values(TDraft draft) => draft.values;

  return AddSchema(
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
    sections: filterAddSchemaSections(
      fieldIds: fieldIds,
      sectionLabels: sectionLabels,
      sections: [
        AddSectionSpec<TDraft>(
          id: 'catalog_item',
          label: 'Catalog Item',
          fields: [
            libraryAddCatalogTitleField<TDraft>(),
            ...boardGameCatalogItemFields<TDraft>(
              values: values,
              publisherOptions: publisherOptions,
              categoryOptions: categoryOptions,
              formatOptions: formatOptions,
              onManagePublisher: onManagePublisher,
            ),
          ],
          fullWidthFieldIds: const {'catalog_title'},
        ),
      ],
    ),
  );
}
