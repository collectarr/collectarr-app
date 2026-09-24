import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MangaWorkWorkspaceFields {
  static final title = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final series = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final volumeNumber = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.volumeNumber,
    label: 'Volume Number',
    getValue: (dto) => dto.itemNumber,
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final nativeTitle = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.nativeTitle,
    label: 'Native Title',
    getValue: (dto) => dto.metadata?.nativeTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final romajiTitle = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.romajiTitle,
    label: 'Romaji Title',
    getValue: (dto) => dto.metadata?.romajiTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final englishTitle = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.englishTitle,
    label: 'English Title',
    getValue: (dto) => dto.metadata?.englishTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final demographic = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.demographic,
    label: 'Demographic',
    getValue: (dto) => dto.metadata?.demographic.label,
    entityScope: LibraryEntityScope.work,
  );

  static final serializationPlatform = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.serializationPlatform,
    label: 'Serialization',
    getValue: (dto) => dto.metadata?.serializationPlatform,
    entityScope: LibraryEntityScope.work,
  );

  static final publicationStatus = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publicationStatus,
    label: 'Publication Status',
    getValue: (dto) => dto.metadata?.publicationStatus.label,
    entityScope: LibraryEntityScope.work,
  );

  static final originalPublisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.originalPublisher,
    label: 'Original Publisher',
    getValue: (dto) => dto.metadata?.originalPublisher,
    entityScope: LibraryEntityScope.work,
  );

  static final localizedPublisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.localizedPublisher,
    label: 'Localized Publisher',
    getValue: (dto) => dto.metadata?.localizedPublisher,
    entityScope: LibraryEntityScope.work,
  );

  static final totalVolumes = numberField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.totalVolumes,
    label: 'Total Volumes',
    getValue: (dto) => dto.metadata?.totalVolumes,
    entityScope: LibraryEntityScope.work,
  );

  static final chapterCount = numberField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.chapterCount,
    label: 'Chapter Count',
    getValue: (dto) => dto.metadata?.chapterCount,
    entityScope: LibraryEntityScope.work,
  );

  static final editionFormat = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.editionFormat,
    label: 'Edition Format',
    getValue: (dto) => dto.metadata?.editionFormat.label,
    entityScope: LibraryEntityScope.work,
  );

  static final readingDirection = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.readingDirection,
    label: 'Reading Direction',
    getValue: (dto) => dto.metadata?.readingDirection.label,
    entityScope: LibraryEntityScope.work,
  );

  static final translator = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.translator,
    label: 'Translator',
    getValue: (dto) => dto.metadata?.translator,
    entityScope: LibraryEntityScope.work,
  );
}

final mangaWorkWorkspaceFieldDefinitions = [
  MangaWorkWorkspaceFields.cover,
  MangaWorkWorkspaceFields.title,
  MangaWorkWorkspaceFields.series,
  MangaWorkWorkspaceFields.volumeNumber,
  MangaWorkWorkspaceFields.nativeTitle,
  MangaWorkWorkspaceFields.romajiTitle,
  MangaWorkWorkspaceFields.englishTitle,
  MangaWorkWorkspaceFields.demographic,
  MangaWorkWorkspaceFields.serializationPlatform,
  MangaWorkWorkspaceFields.publicationStatus,
  MangaWorkWorkspaceFields.originalPublisher,
  MangaWorkWorkspaceFields.localizedPublisher,
  MangaWorkWorkspaceFields.totalVolumes,
  MangaWorkWorkspaceFields.chapterCount,
  MangaWorkWorkspaceFields.editionFormat,
  MangaWorkWorkspaceFields.readingDirection,
  MangaWorkWorkspaceFields.translator,
];

final mangaWorkWorkspaceGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.demographic,
    sidebarTitle: 'Demographics',
    icon: Icons.people_outline,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.publicationStatus,
    sidebarTitle: 'Status',
    icon: Icons.flag_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.editionFormat,
    sidebarTitle: 'Formats',
    icon: Icons.book_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.readingDirection,
    sidebarTitle: 'Reading Direction',
    icon: Icons.import_contacts_outlined,
  ),
];

final mangaWorkWorkspaceSortDefinitions = [
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaWorkWorkspaceFields.series),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaWorkWorkspaceFields.volumeNumber),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaWorkWorkspaceFields.title),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaWorkWorkspaceFields.demographic),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaWorkWorkspaceFields.publicationStatus),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaWorkWorkspaceFields.editionFormat),
  sortFromField<MangaKind, MangaWorkspaceDto, num>(
      MangaWorkWorkspaceFields.totalVolumes),
];

final mangaWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.cover,
  MangaFieldIds.series,
  MangaFieldIds.title,
};

final mangaWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: '',
    getValue: MangaWorkWorkspaceFields.cover.getValue,
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
      MangaWorkWorkspaceFields.series,
      defaultWidth: 160),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.demographic,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.publicationStatus,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.editionFormat,
    group: 'Edition',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.readingDirection,
    group: 'Edition',
    defaultWidth: 150,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, num?>(
    MangaWorkWorkspaceFields.totalVolumes,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, num?>(
    MangaWorkWorkspaceFields.chapterCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.nativeTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.romajiTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.englishTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.originalPublisher,
    group: 'Metadata',
    defaultWidth: 140,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.localizedPublisher,
    group: 'Edition',
    defaultWidth: 140,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaWorkWorkspaceFields.translator,
    group: 'Edition',
    defaultWidth: 140,
  ),
];

final mangaWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  entityScope: LibraryEntityScope.work,
  fields: mangaWorkWorkspaceFieldDefinitions,
  columns: mangaWorkWorkspaceColumnDefinitions,
  sorts: mangaWorkWorkspaceSortDefinitions,
  groups: mangaWorkWorkspaceGroupDefinitions,
  primaryColumn: MangaFieldIds.title,
  defaultVisibleColumns: mangaWorkWorkspaceDefaultVisibleColumns,
  defaultSort: MangaSortIds.series,
  defaultGroup: MangaGroupIds.series,
  preferenceCodec: const MangaPreferenceCodec(),
);
