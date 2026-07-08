import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart'
    as comic_workspace;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

final mangaLibraryFieldDefinitions = [
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('manga.title'),
    label: 'Title',
    getValue: (dto) => dto.title,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('manga.series'),
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('manga.number'),
    label: 'Number',
    getValue: (dto) => dto.itemNumber,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('manga.publisher'),
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  ),
  LibraryFieldDefinition<LibraryWorkspaceDto, Object?>(
    id: LibraryFieldId<Object?>('manga.release_date'),
    label: 'Release date',
    getValue: (dto) => dto.releaseDate,
  ),
];

const mangaLibraryGroupModes = comic_workspace.comicLibraryGroupModes;

const mangaLibraryGroupModeDefinitions =
    comic_workspace.comicLibraryGroupModeDefinitions;

const mangaLibrarySortColumnDefinitions =
    comic_workspace.comicLibrarySortColumnDefinitions;
