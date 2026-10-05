import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class TvCatalogItemWorkspaceFields {
  static final title = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.network,
    label: 'Network / Studio',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final cover = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final firstAirDate = dateField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.firstAirDate,
    label: 'First Air Date',
    getValue: (dto) => dto.firstAirDate,
  );

  static final lastAirDate = dateField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.lastAirDate,
    label: 'Last Air Date',
    getValue: (dto) => dto.lastAirDate,
  );

  static final tvStatus = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.tvStatus,
    label: 'Series Status',
    getValue: (dto) => dto.tvStatus,
  );

  static final streamingService = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.streamingService,
    label: 'Streamer',
    getValue: (dto) => dto.streamingService,
  );

  static final contentRating = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.contentRating,
    label: 'Content Rating',
    getValue: (dto) => dto.contentRating,
  );

  static final seasonCount = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.seasonCount,
    label: 'Seasons',
    getValue: (dto) => dto.seasonCount,
  );

  static final episodeCount = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.episodeCount,
    label: 'Episodes',
    getValue: (dto) => dto.episodeCount,
  );

  static final episodeRuntimeMinutes = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.episodeRuntimeMinutes,
    label: 'Episode Runtime (m)',
    getValue: (dto) => dto.episodeRuntimeMinutes,
  );
}

final tvCatalogItemWorkspaceFieldDefinitions = [
  TvCatalogItemWorkspaceFields.title,
  TvCatalogItemWorkspaceFields.publisher,
  TvCatalogItemWorkspaceFields.series,
  TvCatalogItemWorkspaceFields.firstAirDate,
  TvCatalogItemWorkspaceFields.lastAirDate,
  TvCatalogItemWorkspaceFields.tvStatus,
  TvCatalogItemWorkspaceFields.streamingService,
  TvCatalogItemWorkspaceFields.contentRating,
  TvCatalogItemWorkspaceFields.seasonCount,
  TvCatalogItemWorkspaceFields.episodeCount,
  TvCatalogItemWorkspaceFields.episodeRuntimeMinutes,
];

final tvCatalogItemWorkspaceGroupDefinitions = [
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.publisher,
    sidebarTitle: 'Networks',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'network', 'studio'],
    ),
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.streamingService,
    sidebarTitle: 'Streaming Services',
    icon: Icons.tv_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.tvStatus,
    sidebarTitle: 'Status',
    icon: Icons.flag_outlined,
  ),
];

final tvCatalogItemWorkspaceSortDefinitions = [
  sortFromField<TvKind, TvWorkspaceDto, String>(
      TvCatalogItemWorkspaceFields.series),
  sortFromField<TvKind, TvWorkspaceDto, String>(
      TvCatalogItemWorkspaceFields.publisher),
  sortFromField<TvKind, TvWorkspaceDto, String>(
      TvCatalogItemWorkspaceFields.title),
  sortFromField<TvKind, TvWorkspaceDto, num>(
      TvCatalogItemWorkspaceFields.seasonCount,
      defaultAscending: false),
  sortFromField<TvKind, TvWorkspaceDto, num>(
      TvCatalogItemWorkspaceFields.episodeCount,
      defaultAscending: false),
];

final tvCatalogItemWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  TvFieldIds.cover,
  TvFieldIds.series,
  TvFieldIds.title,
  TvFieldIds.network,
};

final tvCatalogItemWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.cover,
    label: '',
    getValue: TvCatalogItemWorkspaceFields.cover.getValue,
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
  columnFromField<TvKind, TvWorkspaceDto, String?>(
      TvCatalogItemWorkspaceFields.series,
      defaultWidth: 160),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
      TvCatalogItemWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
      TvCatalogItemWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.tvStatus,
    group: 'Metadata',
    defaultWidth: 110,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.streamingService,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<TvKind, TvWorkspaceDto, num?>(
    TvCatalogItemWorkspaceFields.seasonCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<TvKind, TvWorkspaceDto, num?>(
    TvCatalogItemWorkspaceFields.episodeCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvCatalogItemWorkspaceFields.contentRating,
    group: 'Metadata',
    defaultWidth: 100,
  ),
];

final tvCatalogItemWorkspaceSchema =
    LibraryWorkspaceSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  fields: tvCatalogItemWorkspaceFieldDefinitions,
  columns: tvCatalogItemWorkspaceColumnDefinitions,
  sorts: tvCatalogItemWorkspaceSortDefinitions,
  groups: tvCatalogItemWorkspaceGroupDefinitions,
  primaryColumn: TvFieldIds.title,
  defaultVisibleColumns: tvCatalogItemWorkspaceDefaultVisibleColumns,
  defaultSort: TvSortIds.series,
  defaultGroup: TvGroupIds.series,
);
