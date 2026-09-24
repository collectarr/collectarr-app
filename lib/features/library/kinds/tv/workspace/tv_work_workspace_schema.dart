import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_bucket_mutators.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class TvWorkWorkspaceFields {
  static final title = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
    entityScope: LibraryEntityScope.work,
  );

  static final publisher = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.network,
    label: 'Network / Studio',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.work,
  );

  static final series = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
    entityScope: LibraryEntityScope.work,
  );

  static final cover = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    entityScope: LibraryEntityScope.work,
  );

  static final firstAirDate = dateField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.firstAirDate,
    label: 'First Air Date',
    getValue: (dto) => dto.firstAirDate,
    entityScope: LibraryEntityScope.work,
  );

  static final lastAirDate = dateField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.lastAirDate,
    label: 'Last Air Date',
    getValue: (dto) => dto.lastAirDate,
    entityScope: LibraryEntityScope.work,
  );

  static final tvStatus = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.tvStatus,
    label: 'Series Status',
    getValue: (dto) => dto.tvStatus,
    entityScope: LibraryEntityScope.work,
  );

  static final streamingService = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.streamingService,
    label: 'Streamer',
    getValue: (dto) => dto.streamingService,
    entityScope: LibraryEntityScope.work,
  );

  static final contentRating = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.contentRating,
    label: 'Content Rating',
    getValue: (dto) => dto.contentRating,
    entityScope: LibraryEntityScope.work,
  );

  static final seasonCount = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.seasonCount,
    label: 'Seasons',
    getValue: (dto) => dto.seasonCount,
    entityScope: LibraryEntityScope.work,
  );

  static final episodeCount = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.episodeCount,
    label: 'Episodes',
    getValue: (dto) => dto.episodeCount,
    entityScope: LibraryEntityScope.work,
  );

  static final episodeRuntimeMinutes = numberField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.episodeRuntimeMinutes,
    label: 'Episode Runtime (m)',
    getValue: (dto) => dto.episodeRuntimeMinutes,
    entityScope: LibraryEntityScope.work,
  );
}

final tvWorkWorkspaceFieldDefinitions = [
  TvWorkWorkspaceFields.title,
  TvWorkWorkspaceFields.publisher,
  TvWorkWorkspaceFields.series,
  TvWorkWorkspaceFields.firstAirDate,
  TvWorkWorkspaceFields.lastAirDate,
  TvWorkWorkspaceFields.tvStatus,
  TvWorkWorkspaceFields.streamingService,
  TvWorkWorkspaceFields.contentRating,
  TvWorkWorkspaceFields.seasonCount,
  TvWorkWorkspaceFields.episodeCount,
  TvWorkWorkspaceFields.episodeRuntimeMinutes,
];

final tvWorkWorkspaceGroupDefinitions = [
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.publisher,
    sidebarTitle: 'Networks',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: catalogTransportStringBucketValueMutator(
      ['publisher', 'network', 'studio'],
    ),
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.streamingService,
    sidebarTitle: 'Streaming Services',
    icon: Icons.tv_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.tvStatus,
    sidebarTitle: 'Status',
    icon: Icons.flag_outlined,
  ),
];

final tvWorkWorkspaceSortDefinitions = [
  sortFromField<TvKind, TvWorkspaceDto, String>(TvWorkWorkspaceFields.series),
  sortFromField<TvKind, TvWorkspaceDto, String>(
      TvWorkWorkspaceFields.publisher),
  sortFromField<TvKind, TvWorkspaceDto, String>(TvWorkWorkspaceFields.title),
  sortFromField<TvKind, TvWorkspaceDto, num>(TvWorkWorkspaceFields.seasonCount,
      defaultAscending: false),
  sortFromField<TvKind, TvWorkspaceDto, num>(TvWorkWorkspaceFields.episodeCount,
      defaultAscending: false),
];

final tvWorkWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  TvFieldIds.cover,
  TvFieldIds.series,
  TvFieldIds.title,
  TvFieldIds.network,
};

final tvWorkWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.cover,
    label: '',
    getValue: TvWorkWorkspaceFields.cover.getValue,
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
  columnFromField<TvKind, TvWorkspaceDto, String?>(TvWorkWorkspaceFields.series,
      defaultWidth: 160),
  columnFromField<TvKind, TvWorkspaceDto, String?>(TvWorkWorkspaceFields.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
      TvWorkWorkspaceFields.publisher,
      defaultWidth: 140),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.tvStatus,
    group: 'Metadata',
    defaultWidth: 110,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.streamingService,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<TvKind, TvWorkspaceDto, num?>(
    TvWorkWorkspaceFields.seasonCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<TvKind, TvWorkspaceDto, num?>(
    TvWorkWorkspaceFields.episodeCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvWorkWorkspaceFields.contentRating,
    group: 'Metadata',
    defaultWidth: 100,
  ),
];

final tvWorkWorkspaceSchema =
    LibraryEntityWorkspaceSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  entityScope: LibraryEntityScope.work,
  fields: tvWorkWorkspaceFieldDefinitions,
  columns: tvWorkWorkspaceColumnDefinitions,
  sorts: tvWorkWorkspaceSortDefinitions,
  groups: tvWorkWorkspaceGroupDefinitions,
  primaryColumn: TvFieldIds.title,
  defaultVisibleColumns: tvWorkWorkspaceDefaultVisibleColumns,
  defaultSort: TvSortIds.series,
  defaultGroup: TvGroupIds.series,
  preferenceCodec: const TvPreferenceCodec(),
);
