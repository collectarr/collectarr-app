import 'package:collectarr_app/features/library/config/edit_capability.dart';
import 'package:collectarr_app/features/library/forms/prefill_catalog_controls.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/forms/catalog_form_values.dart';
import 'package:collectarr_app/features/library/kinds/game_toy/forms/main_form_section.dart';
import 'package:flutter/widgets.dart';

/// The reference pre-fill's Series and its Toy group, with the catalog key
/// each one fills on a new toy.
const _fields = [
  (id: 'series', group: 'Main', key: 'series_title'),
  (id: 'toy_type', group: 'Toy', key: 'toy_type'),
  (id: 'toy_subtype', group: 'Toy', key: 'toy_subtype'),
];

List<LibraryPrefillField> gameToyPrefillCatalogFields(
    BuildContext context, LibraryPrefillCatalogDraft draft) {
  final values = GameToyCatalogFormValues()
    ..series = draft.text('series_title')
    ..toyType = draft.text('toy_type')
    ..toySubtype = draft.text('toy_subtype');
  void sync() => draft
    ..set('series_title', values.series)
    ..set('toy_type', values.toyType)
    ..set('toy_subtype', values.toySubtype);
  final specs = {
    for (final spec in gameToyMainFields<GameToyCatalogFormValues>(
        values: (values) => values))
      spec.id: spec,
  };
  final controls = libraryPrefillCatalogControls<GameToyCatalogFormValues>(
    context: context,
    draft: draft,
    values: values,
    fields: [for (final field in _fields) specs[field.id]!],
    sync: sync,
    mediaKind: 'game_toy',
  );
  return [
    for (final field in _fields)
      LibraryPrefillField(
        id: field.id,
        label: specs[field.id]!.label,
        group: field.group,
        shownByDefault: false,
        fullWidth: false,
        keys: [field.key],
        field: controls[field.id]!,
      ),
  ];
}
