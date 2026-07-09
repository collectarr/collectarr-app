import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart'
    as comic_workspace;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';

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

const mangaLibrarySortColumns = [
  LibrarySortColumn.series,
  LibrarySortColumn.publisher,
  LibrarySortColumn.status,
  LibrarySortColumn.title,
  LibrarySortColumn.releaseDate,
  LibrarySortColumn.country,
  LibrarySortColumn.language,
  LibrarySortColumn.ageRating,
  LibrarySortColumn.collectionStatus,
  LibrarySortColumn.added,
  LibrarySortColumn.updated,
];

const mangaLibraryTableColumns = [
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.country,
  LibraryTableColumn.language,
  LibraryTableColumn.ageRating,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
];

const mangaLibraryDefaultVisibleColumns = {
  LibraryTableColumn.status,
  LibraryTableColumn.cover,
  LibraryTableColumn.title,
  LibraryTableColumn.publisher,
  LibraryTableColumn.releaseDate,
  LibraryTableColumn.country,
  LibraryTableColumn.language,
  LibraryTableColumn.ageRating,
  LibraryTableColumn.wishlist,
  LibraryTableColumn.updated,
};
