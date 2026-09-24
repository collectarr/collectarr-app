import 'dart:async';

import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/kinds/game/add/game_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/game_catalog_form_values.dart';

final AddSchema<GameAddManualDraft> gameAddSchema = gameAddSchemaFor();

AddSchema<GameAddManualDraft> gameAddSchemaFor({
  Iterable<String>? platformOptions,
  Iterable<String>? editionOptions,
  Iterable<String>? ageRatingOptions,
  Iterable<String>? regionOptions,
  FutureOr<void> Function()? onManagePlatform,
  FutureOr<void> Function()? onManageEdition,
}) {
  GameCatalogFormValues values(GameAddManualDraft draft) => draft.values;

  return AddSchema<GameAddManualDraft>(
    title: (_) => 'Manual game',
    validate: (draft) {
      final year = draft.values.releaseYear;
      if (year != null && year < 1) return 'Release year must be positive';
      return null;
    },
    sections: [
      AddSectionSpec<GameAddManualDraft>(
        id: 'release',
        label: 'Release',
        fields: gameReleaseFields(
          values: values,
          titleLabel: 'Edition title',
          include: {
            'release_title',
            'platform',
            'region',
            'format',
            'release_date',
            'catalog_number',
            'barcode',
            'cover_image_url',
            'release_year',
            'variant',
            'back_cover_image_url',
          },
          platformOptions: platformOptions,
          regionOptions: regionOptions,
          formatOptions: editionOptions,
          onManagePlatform: onManagePlatform,
          onManageFormat: onManageEdition,
        ),
      ),
      AddSectionSpec<GameAddManualDraft>(
        id: 'metadata',
        label: 'Metadata',
        fields: gameWorkFields(
          values: values,
          ageRatingOptions: ageRatingOptions,
          include: {
            'publisher',
            'developers',
            'genres',
            'age_ratings',
            'languages',
            'country',
            'description',
          },
        ),
      ),
    ],
  );
}
