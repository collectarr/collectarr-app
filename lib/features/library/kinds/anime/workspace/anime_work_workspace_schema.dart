import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class AnimeWorkWorkspaceFields {
  static final title = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final studio = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.studio,
    label: 'Studio',
    getValue: (dto) => dto.studio ?? dto.publisher,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final cover =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final nativeTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.nativeTitle,
    label: 'Native Title',
    getValue: (dto) => dto.metadata?.nativeTitle,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final romajiTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.romajiTitle,
    label: 'Romaji Title',
    getValue: (dto) => dto.metadata?.romajiTitle,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final englishTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.englishTitle,
    label: 'English Title',
    getValue: (dto) => dto.metadata?.englishTitle,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final format = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.animeType,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final season = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.season,
    label: 'Season',
    getValue: (dto) => dto.metadata?.season?.label,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final seasonYear = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.seasonYear,
    label: 'Season Year',
    getValue: (dto) => dto.metadata?.seasonYear,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final episodeCount = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.episodeCount,
    label: 'Episode Count',
    getValue: (dto) => dto.episodeCount,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final episodeRuntimeMinutes =
      numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.episodeRuntimeMinutes,
    label: 'Episode Runtime (m)',
    getValue: (dto) => dto.metadata?.episodeRuntimeMinutes,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final airingStatus = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.airingStatus,
    label: 'Airing Status',
    getValue: (dto) => dto.airingStatus,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final sourceMaterial = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.sourceMaterial,
    label: 'Source Material',
    getValue: (dto) => dto.metadata?.sourceMaterial.label,
    entityScope: LibraryEntityScope.catalogItem,
  );
}

final animeWorkWorkspaceFieldDefinitions = [
  AnimeWorkWorkspaceFields.title,
  AnimeWorkWorkspaceFields.studio,
  AnimeWorkWorkspaceFields.nativeTitle,
  AnimeWorkWorkspaceFields.romajiTitle,
  AnimeWorkWorkspaceFields.englishTitle,
  AnimeWorkWorkspaceFields.format,
  AnimeWorkWorkspaceFields.season,
  AnimeWorkWorkspaceFields.seasonYear,
  AnimeWorkWorkspaceFields.episodeCount,
  AnimeWorkWorkspaceFields.episodeRuntimeMinutes,
  AnimeWorkWorkspaceFields.airingStatus,
  AnimeWorkWorkspaceFields.sourceMaterial,
  ...animeCatalogItemWorkspaceFieldDefinitions,
];

final animeWorkWorkspaceGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.studio,
    sidebarTitle: 'Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.format,
    sidebarTitle: 'Formats',
    icon: Icons.tv_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.season,
    sidebarTitle: 'Seasons',
    icon: Icons.wb_sunny_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.airingStatus,
    sidebarTitle: 'Airing Status',
    icon: Icons.play_circle_outline,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.sourceMaterial,
    sidebarTitle: 'Source Material',
    icon: Icons.import_contacts_outlined,
  ),
  ...animeCatalogItemWorkspaceGroupDefinitions,
];

final animeWorkWorkspaceSortDefinitions = [
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeWorkWorkspaceFields.studio),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeWorkWorkspaceFields.title),
  sortFromField<AnimeKind, AnimeWorkspaceDto, num>(
      AnimeWorkWorkspaceFields.seasonYear,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, num>(
      AnimeWorkWorkspaceFields.episodeCount,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeWorkWorkspaceFields.airingStatus),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeWorkWorkspaceFields.sourceMaterial),
  ...animeCatalogItemWorkspaceSortDefinitions,
];

final animeWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.cover,
  AnimeFieldIds.studio,
  AnimeFieldIds.title,
  ...animeCatalogItemWorkspaceDefaultVisibleColumns,
};

final animeWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    label: '',
    getValue: AnimeWorkWorkspaceFields.cover.getValue,
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
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeWorkWorkspaceFields.studio,
      defaultWidth: 150),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeWorkWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.format,
    group: 'Metadata',
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.season,
    group: 'Metadata',
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeWorkWorkspaceFields.seasonYear,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeWorkWorkspaceFields.episodeCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.airingStatus,
    group: 'Metadata',
    defaultWidth: 130,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.sourceMaterial,
    group: 'Metadata',
    defaultWidth: 130,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.nativeTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.romajiTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeWorkWorkspaceFields.englishTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  ...animeCatalogItemWorkspaceColumnDefinitions,
];

final animeWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  entityScope: LibraryEntityScope.catalogItem,
  fields: animeWorkWorkspaceFieldDefinitions,
  columns: animeWorkWorkspaceColumnDefinitions,
  sorts: animeWorkWorkspaceSortDefinitions,
  groups: animeWorkWorkspaceGroupDefinitions,
  primaryColumn: AnimeFieldIds.title,
  defaultVisibleColumns: animeWorkWorkspaceDefaultVisibleColumns,
  defaultSort: AnimeSortIds.studio,
  defaultGroup: AnimeGroupIds.studio,
  preferenceCodec: const AnimePreferenceCodec(),
);
