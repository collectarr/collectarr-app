import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart'
    as comic_workspace;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';

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

final mangaLibraryGroupDefinitions =
    comic_workspace.comicLibraryGroupDefinitions;

final mangaLibrarySortDefinitions = comic_workspace.comicLibrarySortDefinitions;

final mangaLibraryColumnDefinitions = [
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('status'),
    label: 'Status',
    getValue: (entry) =>
        entry.isWishlisted ? 'wishlist' : (entry.isOwned ? 'owned' : null),
    cellValue: (entry) => Text(
      entry.isWishlisted ? 'Wishlist' : (entry.isOwned ? 'Owned' : ''),
    ),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('cover'),
    label: '',
    getValue: (entry) => entry.coverImageUrl,
    cellValue: (entry) => entry.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            entry.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('title'),
    label: 'Title',
    getValue: (entry) => entry.title,
    cellValue: (entry) => Text(entry.title),
    defaultWidth: 260,
    maxWidth: 520,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('publisher'),
    label: 'Publisher',
    getValue: (entry) => entry.publisher,
    cellValue: (entry) => Text(entry.publisher ?? ''),
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('release_date'),
    label: 'Release Date',
    getValue: (entry) => entry.releaseDate,
    cellValue: (entry) => Text(_formatDate(entry.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('country'),
    label: 'Country',
    getValue: (entry) => entry.country,
    cellValue: (entry) => Text(entry.country ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('language'),
    label: 'Language',
    getValue: (entry) => entry.language,
    cellValue: (entry) => Text(entry.language ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('age_rating'),
    label: 'Age Rating',
    getValue: (entry) => entry.ageRating,
    cellValue: (entry) => Text(entry.ageRating ?? ''),
    group: 'Edition',
    defaultWidth: 100,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('wishlist'),
    label: 'Wishlist',
    getValue: (entry) => entry.isWishlisted,
    cellValue: (entry) => Text(entry.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>(
    id: LibraryFieldId<Object?>('updated'),
    label: 'Updated',
    getValue: (entry) => entry.updatedAt,
    cellValue: (entry) => Text(_formatDate(entry.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
];

const mangaLibraryDefaultVisibleColumnIds = {
  'status',
  'cover',
  'title',
  'publisher',
  'release_date',
  'country',
  'language',
  'age_rating',
  'wishlist',
  'updated',
};

const mangaDefaultSortId = 'title';
const mangaDefaultGroupId = 'series';

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
