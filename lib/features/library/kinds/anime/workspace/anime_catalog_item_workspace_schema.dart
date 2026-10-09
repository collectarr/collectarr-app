import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/anime/config/anime_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_catalog_item_workspace_fields.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class AnimeCatalogItemWorkspaceFields {
  static final title = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.title,
    metadata: AnimeWorkspaceFieldMetadata.title,
    getValue: (dto) => dto.title,
  );

  static final studio = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.studio,
    metadata: AnimeWorkspaceFieldMetadata.studio,
    getValue: (dto) => dto.studio ?? dto.publisher,
  );

  static final cover =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    metadata: AnimeWorkspaceFieldMetadata.cover,
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final nativeTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.nativeTitle,
    metadata: AnimeFieldIdentities.nativeTitle,
    getValue: (dto) => dto.metadata.nativeTitle,
  );

  static final romajiTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.romajiTitle,
    metadata: AnimeFieldIdentities.romajiTitle,
    getValue: (dto) => dto.metadata.romajiTitle,
  );

  static final englishTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.englishTitle,
    metadata: AnimeFieldIdentities.englishTitle,
    getValue: (dto) => dto.metadata.englishTitle,
  );

  static final format = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.format,
    metadata: AnimeFieldIdentities.format,
    getValue: (dto) => dto.animeType,
  );

  static final season = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.season,
    metadata: AnimeWorkspaceFieldMetadata.season,
    getValue: (dto) => dto.metadata.season?.label,
  );

  static final seasonYear = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.seasonYear,
    metadata: AnimeWorkspaceFieldMetadata.seasonYear,
    getValue: (dto) => dto.metadata.seasonYear,
  );

  static final episodeCount = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.episodeCount,
    metadata: AnimeWorkspaceFieldMetadata.episodeCount,
    getValue: (dto) => dto.episodeCount,
  );

  static final episodeRuntimeMinutes =
      numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.episodeRuntimeMinutes,
    metadata: AnimeWorkspaceFieldMetadata.episodeRuntimeMinutes,
    getValue: (dto) => dto.metadata.episodeRuntimeMinutes,
  );

  static final airingStatus = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.airingStatus,
    metadata: AnimeWorkspaceFieldMetadata.airingStatus,
    getValue: (dto) => dto.airingStatus,
  );

  static final sourceMaterial = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.sourceMaterial,
    metadata: AnimeWorkspaceFieldMetadata.sourceMaterial,
    getValue: (dto) => dto.metadata.sourceMaterial.label,
  );
}

final animeCatalogItemWorkspaceFieldDefinitions = [
  AnimeCatalogItemWorkspaceFields.title,
  AnimeCatalogItemWorkspaceFields.studio,
  AnimeCatalogItemWorkspaceFields.nativeTitle,
  AnimeCatalogItemWorkspaceFields.romajiTitle,
  AnimeCatalogItemWorkspaceFields.englishTitle,
  AnimeCatalogItemWorkspaceFields.format,
  AnimeCatalogItemWorkspaceFields.season,
  AnimeCatalogItemWorkspaceFields.seasonYear,
  AnimeCatalogItemWorkspaceFields.episodeCount,
  AnimeCatalogItemWorkspaceFields.episodeRuntimeMinutes,
  AnimeCatalogItemWorkspaceFields.airingStatus,
  AnimeCatalogItemWorkspaceFields.sourceMaterial,
  ...animeAdditionalCatalogItemWorkspaceFieldDefinitions,
];

final animeCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.studio,
    sidebarTitle: 'Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
  if (AnimeFieldIdentities.format.groupable)
    groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeCatalogItemWorkspaceFields.format,
      sidebarTitle: 'Formats',
      icon: Icons.tv_outlined,
    ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.season,
    sidebarTitle: 'Seasons',
    icon: Icons.wb_sunny_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.airingStatus,
    sidebarTitle: 'Airing Status',
    icon: Icons.play_circle_outline,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.sourceMaterial,
    sidebarTitle: 'Source Material',
    icon: Icons.import_contacts_outlined,
  ),
  ...animeAdditionalCatalogItemWorkspaceGroupDefinitions,
];

final animeCatalogItemWorkspaceSortDefinitions = [
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeCatalogItemWorkspaceFields.studio),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeCatalogItemWorkspaceFields.title),
  sortFromField<AnimeKind, AnimeWorkspaceDto, num>(
      AnimeCatalogItemWorkspaceFields.seasonYear,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, num>(
      AnimeCatalogItemWorkspaceFields.episodeCount,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeCatalogItemWorkspaceFields.airingStatus),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeCatalogItemWorkspaceFields.sourceMaterial),
  ...animeAdditionalCatalogItemWorkspaceSortDefinitions,
];

final animeCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.cover,
  AnimeFieldIds.studio,
  AnimeFieldIds.title,
  ...animeAdditionalCatalogItemWorkspaceDefaultVisibleColumns,
};

final animeCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    metadata: AnimeWorkspaceFieldMetadata.cover,
    getValue: AnimeCatalogItemWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeCatalogItemWorkspaceFields.studio,
      defaultWidth: 150),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.format,
    group: 'Metadata',
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.season,
    group: 'Metadata',
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeCatalogItemWorkspaceFields.seasonYear,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeCatalogItemWorkspaceFields.episodeCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.airingStatus,
    group: 'Metadata',
    defaultWidth: 130,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.sourceMaterial,
    group: 'Metadata',
    defaultWidth: 130,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.nativeTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.romajiTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeCatalogItemWorkspaceFields.englishTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  ...animeAdditionalCatalogItemWorkspaceColumnDefinitions,
];

final animeCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  fields: animeCatalogItemWorkspaceFieldDefinitions,
  columns: animeCatalogItemWorkspaceColumnDefinitions,
  sorts: animeCatalogItemWorkspaceSortDefinitions,
  groups: animeCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: AnimeFieldIds.title,
  defaultVisibleColumns: animeCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: AnimeSortIds.studio,
  defaultGroup: AnimeGroupIds.studio,
);
