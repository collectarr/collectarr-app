import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MangaCatalogItemWorkspaceFields {
  static final title = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final series = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final volumeNumber = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.volumeNumber,
    label: 'Volume Number',
    getValue: (dto) => dto.itemNumber,
  );

  static final cover =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final nativeTitle = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.nativeTitle,
    label: 'Native Title',
    getValue: (dto) => dto.metadata?.nativeTitle,
  );

  static final romajiTitle = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.romajiTitle,
    label: 'Romaji Title',
    getValue: (dto) => dto.metadata?.romajiTitle,
  );

  static final englishTitle = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.englishTitle,
    label: 'English Title',
    getValue: (dto) => dto.metadata?.englishTitle,
  );

  static final demographic = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.demographic,
    label: 'Demographic',
    getValue: (dto) => dto.metadata?.demographic.label,
  );

  static final serializationPlatform = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.serializationPlatform,
    label: 'Serialization',
    getValue: (dto) => dto.metadata?.serializationPlatform,
  );

  static final publicationStatus = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publicationStatus,
    label: 'Publication Status',
    getValue: (dto) => dto.metadata?.publicationStatus.label,
  );

  static final originalPublisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.originalPublisher,
    label: 'Original Publisher',
    getValue: (dto) => dto.metadata?.originalPublisher,
  );

  static final localizedPublisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.localizedPublisher,
    label: 'Localized Publisher',
    getValue: (dto) => dto.metadata?.localizedPublisher,
  );

  static final totalVolumes = numberField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.totalVolumes,
    label: 'Total Volumes',
    getValue: (dto) => dto.metadata?.totalVolumes,
  );

  static final chapterCount = numberField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.chapterCount,
    label: 'Chapter Count',
    getValue: (dto) => dto.metadata?.chapterCount,
  );

  static final editionFormat = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.editionFormat,
    label: 'Edition Format',
    getValue: (dto) => dto.metadata?.editionFormat.label,
  );

  static final readingDirection = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.readingDirection,
    label: 'Reading Direction',
    getValue: (dto) => dto.metadata?.readingDirection.label,
  );

  static final translator = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.translator,
    label: 'Translator',
    getValue: (dto) => dto.metadata?.translator,
  );
}

final mangaCatalogItemWorkspaceFieldDefinitions = [
  MangaCatalogItemWorkspaceFields.cover,
  MangaCatalogItemWorkspaceFields.title,
  MangaCatalogItemWorkspaceFields.series,
  MangaCatalogItemWorkspaceFields.volumeNumber,
  MangaCatalogItemWorkspaceFields.nativeTitle,
  MangaCatalogItemWorkspaceFields.romajiTitle,
  MangaCatalogItemWorkspaceFields.englishTitle,
  MangaCatalogItemWorkspaceFields.demographic,
  MangaCatalogItemWorkspaceFields.serializationPlatform,
  MangaCatalogItemWorkspaceFields.publicationStatus,
  MangaCatalogItemWorkspaceFields.originalPublisher,
  MangaCatalogItemWorkspaceFields.localizedPublisher,
  MangaCatalogItemWorkspaceFields.totalVolumes,
  MangaCatalogItemWorkspaceFields.chapterCount,
  MangaCatalogItemWorkspaceFields.editionFormat,
  MangaCatalogItemWorkspaceFields.readingDirection,
  MangaCatalogItemWorkspaceFields.translator,
  ...mangaAdditionalCatalogItemWorkspaceFieldDefinitions,
];

final mangaCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.demographic,
    sidebarTitle: 'Demographics',
    icon: Icons.people_outline,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.publicationStatus,
    sidebarTitle: 'Status',
    icon: Icons.flag_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.editionFormat,
    sidebarTitle: 'Formats',
    icon: Icons.book_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.readingDirection,
    sidebarTitle: 'Reading Direction',
    icon: Icons.import_contacts_outlined,
  ),
  ...mangaAdditionalCatalogItemWorkspaceGroupDefinitions,
];

final mangaCatalogItemWorkspaceSortDefinitions = [
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.series),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.volumeNumber),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.title),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.demographic),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.publicationStatus),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaCatalogItemWorkspaceFields.editionFormat),
  sortFromField<MangaKind, MangaWorkspaceDto, num>(
      MangaCatalogItemWorkspaceFields.totalVolumes),
  ...mangaAdditionalCatalogItemWorkspaceSortDefinitions,
];

final mangaCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.cover,
  MangaFieldIds.series,
  MangaFieldIds.title,
  ...mangaAdditionalCatalogItemWorkspaceDefaultVisibleColumns,
};

final mangaCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: '',
    getValue: MangaCatalogItemWorkspaceFields.cover.getValue,
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
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaCatalogItemWorkspaceFields.series,
      defaultWidth: 160),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.demographic,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.publicationStatus,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.editionFormat,
    group: 'Edition',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.readingDirection,
    group: 'Edition',
    defaultWidth: 150,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, num?>(
    MangaCatalogItemWorkspaceFields.totalVolumes,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, num?>(
    MangaCatalogItemWorkspaceFields.chapterCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.nativeTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.romajiTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.englishTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.originalPublisher,
    group: 'Metadata',
    defaultWidth: 140,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.localizedPublisher,
    group: 'Edition',
    defaultWidth: 140,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaCatalogItemWorkspaceFields.translator,
    group: 'Edition',
    defaultWidth: 140,
  ),
  ...mangaAdditionalCatalogItemWorkspaceColumnDefinitions,
];

final mangaCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  fields: mangaCatalogItemWorkspaceFieldDefinitions,
  columns: mangaCatalogItemWorkspaceColumnDefinitions,
  sorts: mangaCatalogItemWorkspaceSortDefinitions,
  groups: mangaCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: MangaFieldIds.title,
  defaultVisibleColumns: mangaCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: MangaSortIds.series,
  defaultGroup: MangaGroupIds.series,
);
