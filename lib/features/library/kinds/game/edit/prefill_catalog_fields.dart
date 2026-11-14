import 'package:collectarr_app/features/library/config/edit_capability.dart';
import 'package:collectarr_app/features/library/forms/prefill_catalog_controls.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_field_specs.dart';
import 'package:collectarr_app/features/library/kinds/game/forms/catalog_form_values.dart';
import 'package:flutter/widgets.dart';

/// The reference Games pre-fill's Main and Edition fields, with the catalog
/// keys each one fills on a new game.
const _fields = [
  (id: GameMainFieldIds.series, group: 'Main', keys: ['series_title']),
  (id: GameMainFieldIds.platform, group: 'Main', keys: ['platforms']),
  (id: GameMainFieldIds.genre, group: 'Main', keys: ['genres']),
  (
    id: GameMainFieldIds.audienceRating,
    group: 'Main',
    keys: ['audience_rating']
  ),
  (id: GameMainFieldIds.edition, group: 'Edition', keys: ['edition_title']),
  (
    id: GameMainFieldIds.format,
    group: 'Edition',
    keys: ['physical_format', 'physical_format_label']
  ),
  (id: GameMainFieldIds.region, group: 'Edition', keys: ['release_region']),
];

List<LibraryPrefillField> gamePrefillCatalogFields(
    BuildContext context, LibraryPrefillCatalogDraft draft) {
  final values = GameCatalogFormValues(
    platform: draft.list('platforms').firstOrNull ?? '',
    series: draft.text('series_title'),
    genres: draft.list('genres'),
    audienceRating: draft.text('audience_rating'),
    editionTitle: draft.text('edition_title'),
    format: draft.text('physical_format_label'),
    region: draft.text('release_region'),
  );
  void sync() => draft
    ..set('platforms', [
      if (values.platform.trim().isNotEmpty) values.platform.trim(),
    ])
    ..set('series_title', values.series)
    ..set('genres', values.genres)
    ..set('audience_rating', values.audienceRating)
    ..set('edition_title', values.editionTitle)
    ..set('physical_format', values.format)
    ..set('physical_format_label', values.format)
    ..set('release_region', values.region);
  final specs = {
    for (final spec
        in gameMainFields<GameCatalogFormValues>(values: (values) => values))
      spec.id: spec,
  };
  final controls = libraryPrefillCatalogControls<GameCatalogFormValues>(
    context: context,
    draft: draft,
    values: values,
    fields: [for (final field in _fields) specs[field.id]!],
    sync: sync,
    mediaKind: 'game',
  );
  return [
    for (final field in _fields)
      LibraryPrefillField(
        id: field.id,
        label: specs[field.id]!.label,
        group: field.group,
        shownByDefault: false,
        fullWidth: field.id == GameMainFieldIds.genre,
        keys: field.keys,
        field: controls[field.id]!,
      ),
  ];
}
