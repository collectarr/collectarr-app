import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_display_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_ids.dart';
export 'package:collectarr_app/features/library/kinds/tv/workspace/tv_preference_codec.dart';

/// Default video display level for the TV kind (shows season-level by default).
const tvDefaultVideoDisplayLevel = TvDisplayLevel.season;

/// Default video grouping for the TV kind (no grouping by default).
const tvDefaultVideoGrouping = TvGroupingDefault.none;

/// Single source of truth schema for TV kind fields.
abstract final class TvKindSchema {
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

  static final releaseDate = dateField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final barcode = textField<TvKind, TvWorkspaceDto>(
    id: TvFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final status = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover = LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating = LibraryFieldDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist = LibraryFieldDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  static final watchStatus =
      LibraryFieldDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    scope: LibraryFieldScope.copy,
  );

  // Rich TV Metadata Fields
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

final tvLibraryFieldDefinitions = [
  TvKindSchema.title,
  TvKindSchema.publisher,
  TvKindSchema.series,
  TvKindSchema.releaseDate,
  TvKindSchema.condition,
  TvKindSchema.location,
  TvKindSchema.pricePaid,
  TvKindSchema.barcode,
  TvKindSchema.firstAirDate,
  TvKindSchema.lastAirDate,
  TvKindSchema.tvStatus,
  TvKindSchema.streamingService,
  TvKindSchema.contentRating,
  TvKindSchema.seasonCount,
  TvKindSchema.episodeCount,
  TvKindSchema.episodeRuntimeMinutes,
];

final tvLibraryGroupDefinitions = [
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.publisher,
    sidebarTitle: 'Networks',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: libraryStringBucketValueMutator(
      'publisher',
      mirrorKeys: ['network', 'studio'],
    ),
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.streamingService,
    sidebarTitle: 'Streaming Services',
    icon: Icons.tv_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.tvStatus,
    sidebarTitle: 'Status',
    icon: Icons.flag_outlined,
  ),
  groupFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final tvLibrarySortDefinitions = [
  sortFromField<TvKind, TvWorkspaceDto, String>(TvKindSchema.series),
  sortFromField<TvKind, TvWorkspaceDto, String>(TvKindSchema.publisher),
  LibrarySortDefinition<TvKind, TvWorkspaceDto>(
    id: TvSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<TvWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<TvKind, TvWorkspaceDto, String>(TvKindSchema.title),
  sortFromField<TvKind, TvWorkspaceDto, DateTime>(TvKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<TvKind, TvWorkspaceDto, num>(TvKindSchema.seasonCount,
      defaultAscending: false),
  sortFromField<TvKind, TvWorkspaceDto, num>(TvKindSchema.episodeCount,
      defaultAscending: false),
];

final tvLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  TvFieldIds.status,
  TvFieldIds.cover,
  TvFieldIds.series,
  TvFieldIds.title,
  TvFieldIds.network,
  TvFieldIds.releaseDate,
  TvFieldIds.barcode,
  TvFieldIds.rating,
  TvFieldIds.condition,
  TvFieldIds.pricePaid,
  TvFieldIds.location,
  TvFieldIds.wishlist,
  TvFieldIds.updatedAt,
};

final tvLibraryColumnDefinitions = [
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.status,
    label: 'Status',
    getValue: TvKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, String?>(
    id: TvFieldIds.cover,
    label: '',
    getValue: TvKindSchema.cover.getValue,
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
  columnFromField<TvKind, TvWorkspaceDto, String?>(TvKindSchema.series,
      defaultWidth: 160),
  columnFromField<TvKind, TvWorkspaceDto, String?>(TvKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<TvKind, TvWorkspaceDto, String?>(TvKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<TvKind, TvWorkspaceDto, DateTime?>(
    TvKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, bool>(
    id: TvFieldIds.wishlist,
    label: 'Wishlist',
    getValue: TvKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime>(
    id: TvFieldIds.updatedAt,
    label: 'Updated',
    getValue: TvKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, DateTime?>(
    id: TvFieldIds.addedAt,
    label: 'Added',
    getValue: TvKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<TvKind, TvWorkspaceDto, int?>(
    TvKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<TvKind, TvWorkspaceDto, int?>(
    id: TvFieldIds.rating,
    label: 'Rating',
    getValue: TvKindSchema.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.tvStatus,
    group: 'Metadata',
    defaultWidth: 110,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.streamingService,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<TvKind, TvWorkspaceDto, num?>(
    TvKindSchema.seasonCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<TvKind, TvWorkspaceDto, num?>(
    TvKindSchema.episodeCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 90,
  ),
  columnFromField<TvKind, TvWorkspaceDto, String?>(
    TvKindSchema.contentRating,
    group: 'Metadata',
    defaultWidth: 100,
  ),
];

final tvLibraryKindSchema = LibraryKindSchema<TvKind, TvWorkspaceDto>(
  kindNamespace: 'tv',
  fields: tvLibraryFieldDefinitions,
  columns: tvLibraryColumnDefinitions,
  sorts: tvLibrarySortDefinitions,
  groups: tvLibraryGroupDefinitions,
  defaultVisibleColumns: tvLibraryDefaultVisibleColumns,
  defaultSort: TvSortIds.series,
  defaultGroup: TvGroupIds.series,
  preferenceCodec: const TvPreferenceCodec(),
);

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
