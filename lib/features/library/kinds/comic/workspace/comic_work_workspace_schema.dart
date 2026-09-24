import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:flutter/material.dart';

abstract final class ComicWorkWorkspaceFields {
  static final title = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final series = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final issueNumber = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.issueNumber,
    label: 'Issue Number',
    getValue: (dto) => dto.itemNumber,
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final writer = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.writer,
    label: 'Writer',
    getValue: (dto) => dto.writer,
    entityScope: LibraryEntityScope.work,
  );

  static final artist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.work,
  );

  static final coverArtist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.coverArtist,
    label: 'Cover Artist',
    getValue: (dto) => dto.coverArtist,
    entityScope: LibraryEntityScope.work,
  );

  static final imprint = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.imprint,
    label: 'Imprint',
    getValue: (dto) => dto.imprint,
    entityScope: LibraryEntityScope.work,
  );

  static final pageCount = numberField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.pageCount,
    label: 'Page Count',
    getValue: (dto) => dto.pageCount,
    entityScope: LibraryEntityScope.work,
  );
}

final comicWorkWorkspaceFieldDefinitions = [
  ComicWorkWorkspaceFields.title,
  ComicWorkWorkspaceFields.cover,
  ComicWorkWorkspaceFields.series,
  ComicWorkWorkspaceFields.issueNumber,
  ComicWorkWorkspaceFields.writer,
  ComicWorkWorkspaceFields.artist,
  ComicWorkWorkspaceFields.coverArtist,
  ComicWorkWorkspaceFields.imprint,
  ComicWorkWorkspaceFields.pageCount,
];

final comicWorkWorkspaceGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicWorkWorkspaceFields.series,
    sidebarTitle: 'Series',
    category: 'Main',
    icon: Icons.collections_bookmark_outlined,
    supportsJump: true,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
];

final comicWorkWorkspaceSortDefinitions = [
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicWorkWorkspaceFields.series),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicWorkWorkspaceFields.issueNumber),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicWorkWorkspaceFields.title),
];

final comicWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.cover,
  ComicFieldIds.series,
  ComicFieldIds.issueNumber,
  ComicFieldIds.title,
};

final comicWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: '',
    getValue: ComicWorkWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicWorkWorkspaceFields.series,
      defaultWidth: 160),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicWorkWorkspaceFields.issueNumber,
      defaultWidth: 80),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicWorkWorkspaceFields.writer,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicWorkWorkspaceFields.artist,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicWorkWorkspaceFields.coverArtist,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicWorkWorkspaceFields.imprint,
    group: 'Publisher',
    defaultWidth: 120,
  ),
];

final comicWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  entityScope: LibraryEntityScope.work,
  fields: comicWorkWorkspaceFieldDefinitions,
  columns: comicWorkWorkspaceColumnDefinitions,
  sorts: comicWorkWorkspaceSortDefinitions,
  groups: comicWorkWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.title,
  defaultVisibleColumns: comicWorkWorkspaceDefaultVisibleColumns,
  defaultSort: ComicSortIds.series,
  defaultGroup: ComicGroupIds.series,
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<ComicKind>(),
);
