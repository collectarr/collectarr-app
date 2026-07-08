import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';

List<LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>>
    libraryWorkspaceFieldDefinitionsForKind(String kind) {
  final prefix = kind.trim().toLowerCase();
  return [
    LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>(
      id: LibraryFieldId<Object?>('$prefix.title'),
      label: 'Title',
      getValue: (entry) => entry.resolvedTitle,
    ),
    LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>(
      id: LibraryFieldId<Object?>('$prefix.series'),
      label: 'Series',
      getValue: (entry) => entry.series?.seriesTitle,
    ),
    LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>(
      id: LibraryFieldId<Object?>('$prefix.number'),
      label: 'Number',
      getValue: (entry) => entry.itemNumber,
    ),
    LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>(
      id: LibraryFieldId<Object?>('$prefix.publisher'),
      label: 'Publisher',
      getValue: (entry) => entry.publisher,
    ),
    LibraryFieldDefinition<LibraryWorkspaceEntry, Object?>(
      id: LibraryFieldId<Object?>('$prefix.release_date'),
      label: 'Release date',
      getValue: (entry) => entry.releaseDate,
    ),
  ];
}
