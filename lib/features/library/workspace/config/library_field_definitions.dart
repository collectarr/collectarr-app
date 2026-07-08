import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

List<LibraryFieldDefinition<LibraryWorkspaceDto, Object?>>
    libraryWorkspaceFieldDefinitionsForKind(String kind) {
  final prefix = kind.trim().toLowerCase();
  return [
    LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
      id: LibraryFieldId<Object?>('$prefix.title'),
      label: 'Title',
      getValue: (dto) => dto.title,
    ),
    LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
      id: LibraryFieldId<Object?>('$prefix.series'),
      label: 'Series',
      getValue: (dto) => dto.seriesTitle,
    ),
    LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
      id: LibraryFieldId<Object?>('$prefix.number'),
      label: 'Number',
      getValue: (dto) => dto.itemNumber,
    ),
    LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
      id: LibraryFieldId<Object?>('$prefix.publisher'),
      label: 'Publisher',
      getValue: (dto) => dto.publisher,
    ),
    LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
      id: LibraryFieldId<Object?>('$prefix.release_date'),
      label: 'Release date',
      getValue: (dto) => dto.releaseDate,
    ),
  ];
}
