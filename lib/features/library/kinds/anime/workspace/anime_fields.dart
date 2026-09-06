import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/anime/workspace/anime_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/anime/workspace/anime_ids.dart';
export 'package:collectarr_app/features/library/kinds/anime/workspace/anime_preference_codec.dart';

/// Single source of truth schema for Anime kind fields.
abstract final class AnimeKindSchema {
  static final title = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final studio = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.studio,
    label: 'Studio',
    getValue: (dto) => dto.studio ?? dto.publisher,
  );

  static final publisher = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final barcode = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final status =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  static final watchStatus =
      LibraryFieldDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    scope: LibraryFieldScope.copy,
  );

  // Rich Anime Metadata Fields
  static final nativeTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.nativeTitle,
    label: 'Native Title',
    getValue: (dto) => dto.metadata?.nativeTitle,
  );

  static final romajiTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.romajiTitle,
    label: 'Romaji Title',
    getValue: (dto) => dto.metadata?.romajiTitle,
  );

  static final englishTitle = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.englishTitle,
    label: 'English Title',
    getValue: (dto) => dto.metadata?.englishTitle,
  );

  static final format = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.animeType,
  );

  static final season = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.season,
    label: 'Season',
    getValue: (dto) => dto.metadata?.season?.label,
  );

  static final seasonYear = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.seasonYear,
    label: 'Season Year',
    getValue: (dto) => dto.metadata?.seasonYear,
  );

  static final episodeCount = numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.episodeCount,
    label: 'Episode Count',
    getValue: (dto) => dto.episodeCount,
  );

  static final episodeRuntimeMinutes =
      numberField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.episodeRuntimeMinutes,
    label: 'Episode Runtime (m)',
    getValue: (dto) => dto.metadata?.episodeRuntimeMinutes,
  );

  static final airingStatus = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.airingStatus,
    label: 'Airing Status',
    getValue: (dto) => dto.airingStatus,
  );

  static final sourceMaterial = textField<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeFieldIds.sourceMaterial,
    label: 'Source Material',
    getValue: (dto) => dto.metadata?.sourceMaterial.label,
  );
}

final animeLibraryFieldDefinitions = [
  AnimeKindSchema.title,
  AnimeKindSchema.studio,
  AnimeKindSchema.publisher,
  AnimeKindSchema.releaseDate,
  AnimeKindSchema.condition,
  AnimeKindSchema.location,
  AnimeKindSchema.pricePaid,
  AnimeKindSchema.barcode,
  AnimeKindSchema.nativeTitle,
  AnimeKindSchema.romajiTitle,
  AnimeKindSchema.englishTitle,
  AnimeKindSchema.format,
  AnimeKindSchema.season,
  AnimeKindSchema.seasonYear,
  AnimeKindSchema.episodeCount,
  AnimeKindSchema.episodeRuntimeMinutes,
  AnimeKindSchema.airingStatus,
  AnimeKindSchema.sourceMaterial,
];

final animeLibraryGroupDefinitions = [
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.studio,
    sidebarTitle: 'Studios',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: libraryStringListBucketValueMutator(
      'studios',
      scalarMirrorKeys: ['publisher'],
    ),
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.format,
    sidebarTitle: 'Formats',
    icon: Icons.tv_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.season,
    sidebarTitle: 'Seasons',
    icon: Icons.wb_sunny_outlined,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.airingStatus,
    sidebarTitle: 'Airing Status',
    icon: Icons.play_circle_outline,
  ),
  groupFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.sourceMaterial,
    sidebarTitle: 'Source Material',
    icon: Icons.import_contacts_outlined,
  ),
];

final animeLibrarySortDefinitions = [
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(AnimeKindSchema.studio),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeKindSchema.publisher),
  LibrarySortDefinition<AnimeKind, AnimeWorkspaceDto>(
    id: AnimeSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<AnimeWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(AnimeKindSchema.title),
  sortFromField<AnimeKind, AnimeWorkspaceDto, DateTime>(
      AnimeKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, num>(AnimeKindSchema.seasonYear,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, num>(AnimeKindSchema.episodeCount,
      defaultAscending: false),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeKindSchema.airingStatus),
  sortFromField<AnimeKind, AnimeWorkspaceDto, String>(
      AnimeKindSchema.sourceMaterial),
];

final animeLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  AnimeFieldIds.status,
  AnimeFieldIds.cover,
  AnimeFieldIds.studio,
  AnimeFieldIds.title,
  AnimeFieldIds.publisher,
  AnimeFieldIds.releaseDate,
  AnimeFieldIds.barcode,
  AnimeFieldIds.rating,
  AnimeFieldIds.condition,
  AnimeFieldIds.pricePaid,
  AnimeFieldIds.location,
  AnimeFieldIds.wishlist,
  AnimeFieldIds.updatedAt,
};

final animeLibraryColumnDefinitions = [
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.status,
    label: 'Status',
    getValue: AnimeKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, String?>(
    id: AnimeFieldIds.cover,
    label: '',
    getValue: AnimeKindSchema.cover.getValue,
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
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(AnimeKindSchema.studio,
      defaultWidth: 150),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(AnimeKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
      AnimeKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    AnimeKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, bool>(
    id: AnimeFieldIds.wishlist,
    label: 'Wishlist',
    getValue: AnimeKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime>(
    id: AnimeFieldIds.updatedAt,
    label: 'Updated',
    getValue: AnimeKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, DateTime?>(
    id: AnimeFieldIds.addedAt,
    label: 'Added',
    getValue: AnimeKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, int?>(
    AnimeKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<AnimeKind, AnimeWorkspaceDto, int?>(
    id: AnimeFieldIds.rating,
    label: 'Rating',
    getValue: AnimeKindSchema.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.format,
    group: 'Metadata',
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.season,
    group: 'Metadata',
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeKindSchema.seasonYear,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, num?>(
    AnimeKindSchema.episodeCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.airingStatus,
    group: 'Metadata',
    defaultWidth: 130,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.sourceMaterial,
    group: 'Metadata',
    defaultWidth: 130,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.nativeTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.romajiTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<AnimeKind, AnimeWorkspaceDto, String?>(
    AnimeKindSchema.englishTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
];

final animeLibraryKindSchema = LibraryKindSchema<AnimeKind, AnimeWorkspaceDto>(
  kindNamespace: 'anime',
  fields: animeLibraryFieldDefinitions,
  columns: animeLibraryColumnDefinitions,
  sorts: animeLibrarySortDefinitions,
  groups: animeLibraryGroupDefinitions,
  defaultVisibleColumns: animeLibraryDefaultVisibleColumns,
  defaultSort: AnimeSortIds.studio,
  defaultGroup: AnimeGroupIds.studio,
  preferenceCodec: const AnimePreferenceCodec(),
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
