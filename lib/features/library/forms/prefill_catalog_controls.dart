import 'package:collectarr_app/features/library/config/edit_capability.dart';
import 'package:collectarr_app/features/library/forms/field_spec.dart';
import 'package:collectarr_app/features/library/forms/field_spec_control_builder.dart';
import 'package:flutter/widgets.dart';

/// The edit form's controls for catalog [fields], bound to the kind's form
/// [values] for Pre-fill Settings; [sync] copies a change into the pre-fill
/// draft. Keyed by field id.
Map<String, Widget> libraryPrefillCatalogControls<TValues>({
  required BuildContext context,
  required LibraryPrefillCatalogDraft draft,
  required TValues values,
  required List<LibraryFieldSpec<TValues>> fields,
  required VoidCallback sync,
  required String mediaKind,
}) {
  final builder = LibraryFieldSpecControlBuilder<TValues>(
    context: context,
    draft: values,
    mode: LibraryFieldSpecControlMode.edit,
    controllerFor: draft.controller,
    onChanged: sync,
    mediaKind: mediaKind,
  );
  return {for (final field in fields) field.id: builder.build(field)};
}
