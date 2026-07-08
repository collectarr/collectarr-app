import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_definition.dart'
    as column_defs;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart'
    as typed;
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

column_defs.LibraryColumnRegistry libraryColumnRegistryFromFieldDefinitions(
  CatalogMediaKind kind,
  Iterable<typed.LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>> fields,
) {
  return column_defs.LibraryColumnRegistry([
    for (final field in fields)
      column_defs.LibraryColumnDefinition(
        id: field.id.value,
        label: field.label,
        scope: column_defs.LibraryColumnScope.work,
        kinds: {kind},
        value: (LibraryWorkspaceEntry entry, _) => field.getValue(entry),
        sortable: field.sortable,
        groupable: field.groupable,
      ),
  ]);
}
