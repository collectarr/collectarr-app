import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
export 'package:collectarr_app/features/library/kinds/manga/workspace/manga_preference_codec.dart';

/// Single source of truth schema for Manga kind fields.
abstract final class MangaKindSchema {
  static final title = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
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

  static final releaseDate = dateField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final barcode = textField<MangaKind, MangaWorkspaceDto>(
    id: MangaFieldIds.barcode,
    label: 'ISBN / Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final status =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  // Manga Metadata Fields
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

  // Manga Ownership Fields
  static final obiStripPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    label: 'Obi Strip Present',
    getValue: (context) => context.dto.ownedDetails?.obiStripPresent ?? false,
    scope: LibraryFieldScope.copy,
  );

  static final slipcoverPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    label: 'Slipcover Present',
    getValue: (context) => context.dto.ownedDetails?.slipcoverPresent ?? false,
    scope: LibraryFieldScope.copy,
  );

  static final dustJacketPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    label: 'Dust Jacket Present',
    getValue: (context) => context.dto.ownedDetails?.dustJacketPresent ?? false,
    scope: LibraryFieldScope.copy,
  );

  static final dustJacketCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.dustJacketCondition,
    label: 'Dust Jacket Condition',
    getValue: (context) => context.dto.ownedDetails?.dustJacketCondition,
    scope: LibraryFieldScope.copy,
  );

  static final boxSetOuterCondition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.boxSetOuterCondition,
    label: 'Box Set Outer Condition',
    getValue: (context) => context.dto.ownedDetails?.boxSetOuterCondition,
    scope: LibraryFieldScope.copy,
  );

  static final insertsPresent =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.insertsPresent,
    label: 'Inserts Present',
    getValue: (context) => context.dto.ownedDetails?.insertsPresent ?? false,
    scope: LibraryFieldScope.copy,
  );

  static final printing =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.printing,
    label: 'Printing',
    getValue: (context) => context.dto.ownedDetails?.printing,
    scope: LibraryFieldScope.copy,
  );

  static final localizedEdition =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.localizedEdition,
    label: 'Localized Edition',
    getValue: (context) => context.dto.ownedDetails?.localizedEdition,
    scope: LibraryFieldScope.copy,
  );

  static final signedBy =
      LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) => context.dto.ownedDetails?.signedBy,
    scope: LibraryFieldScope.copy,
  );
}

final mangaLibraryFieldDefinitions = [
  MangaKindSchema.title,
  MangaKindSchema.series,
  MangaKindSchema.volumeNumber,
  MangaKindSchema.publisher,
  MangaKindSchema.releaseDate,
  MangaKindSchema.condition,
  MangaKindSchema.location,
  MangaKindSchema.pricePaid,
  MangaKindSchema.barcode,
  MangaKindSchema.nativeTitle,
  MangaKindSchema.romajiTitle,
  MangaKindSchema.englishTitle,
  MangaKindSchema.demographic,
  MangaKindSchema.serializationPlatform,
  MangaKindSchema.publicationStatus,
  MangaKindSchema.originalPublisher,
  MangaKindSchema.localizedPublisher,
  MangaKindSchema.totalVolumes,
  MangaKindSchema.chapterCount,
  MangaKindSchema.editionFormat,
  MangaKindSchema.readingDirection,
  MangaKindSchema.translator,
  MangaKindSchema.obiStripPresent,
  MangaKindSchema.slipcoverPresent,
  MangaKindSchema.dustJacketPresent,
  MangaKindSchema.dustJacketCondition,
  MangaKindSchema.boxSetOuterCondition,
  MangaKindSchema.insertsPresent,
  MangaKindSchema.printing,
  MangaKindSchema.localizedEdition,
  MangaKindSchema.signedBy,
];

final mangaLibraryGroupDefinitions = [
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.demographic,
    sidebarTitle: 'Demographics',
    icon: Icons.people_outline,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.publicationStatus,
    sidebarTitle: 'Status',
    icon: Icons.flag_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.editionFormat,
    sidebarTitle: 'Formats',
    icon: Icons.book_outlined,
  ),
  groupFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.readingDirection,
    sidebarTitle: 'Reading Direction',
    icon: Icons.import_contacts_outlined,
  ),
];

final mangaLibrarySortDefinitions = [
  sortFromField<MangaKind, MangaWorkspaceDto, String>(MangaKindSchema.series),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.volumeNumber),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.publisher),
  LibrarySortDefinition<MangaKind, MangaWorkspaceDto>(
    id: MangaSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MangaWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(MangaKindSchema.title),
  sortFromField<MangaKind, MangaWorkspaceDto, DateTime>(
      MangaKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.demographic),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.publicationStatus),
  sortFromField<MangaKind, MangaWorkspaceDto, String>(
      MangaKindSchema.editionFormat),
  sortFromField<MangaKind, MangaWorkspaceDto, num>(
      MangaKindSchema.totalVolumes),
];

final mangaLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MangaFieldIds.status,
  MangaFieldIds.cover,
  MangaFieldIds.series,
  MangaFieldIds.title,
  MangaFieldIds.publisher,
  MangaFieldIds.releaseDate,
  MangaFieldIds.barcode,
  MangaFieldIds.rating,
  MangaFieldIds.condition,
  MangaFieldIds.pricePaid,
  MangaFieldIds.location,
  MangaFieldIds.wishlist,
  MangaFieldIds.updatedAt,
};

final mangaLibraryColumnDefinitions = [
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.status,
    label: 'Status',
    getValue: MangaKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, String?>(
    id: MangaFieldIds.cover,
    label: '',
    getValue: MangaKindSchema.cover.getValue,
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
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(MangaKindSchema.series,
      defaultWidth: 160),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(MangaKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
      MangaKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<MangaKind, MangaWorkspaceDto, DateTime?>(
    MangaKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MangaKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime>(
    id: MangaFieldIds.updatedAt,
    label: 'Updated',
    getValue: MangaKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, DateTime?>(
    id: MangaFieldIds.addedAt,
    label: 'Added',
    getValue: MangaKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, int?>(
    MangaKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, int?>(
    id: MangaFieldIds.rating,
    label: 'Rating',
    getValue: MangaKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.demographic,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.publicationStatus,
    group: 'Metadata',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.editionFormat,
    group: 'Edition',
    defaultWidth: 120,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.readingDirection,
    group: 'Edition',
    defaultWidth: 150,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, num?>(
    MangaKindSchema.totalVolumes,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, num?>(
    MangaKindSchema.chapterCount,
    group: 'Metadata',
    isNumeric: true,
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.nativeTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.romajiTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.englishTitle,
    group: 'Metadata',
    defaultWidth: 180,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.originalPublisher,
    group: 'Metadata',
    defaultWidth: 140,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.localizedPublisher,
    group: 'Edition',
    defaultWidth: 140,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.translator,
    group: 'Edition',
    defaultWidth: 140,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.obiStripPresent,
    label: 'Obi Strip',
    getValue: MangaKindSchema.obiStripPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.ownedDetails?.obiStripPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.slipcoverPresent,
    label: 'Slipcover',
    getValue: MangaKindSchema.slipcoverPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.ownedDetails?.slipcoverPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<MangaKind, MangaWorkspaceDto, bool>(
    id: MangaFieldIds.dustJacketPresent,
    label: 'Dust Jacket',
    getValue: MangaKindSchema.dustJacketPresent.getValue,
    cellValue: (context) => Text(
      (context.dto.ownedDetails?.dustJacketPresent ?? false) ? 'Yes' : 'No',
    ),
    group: 'Condition',
    defaultWidth: 90,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.printing,
    group: 'Edition',
    defaultWidth: 100,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.localizedEdition,
    group: 'Edition',
    defaultWidth: 130,
  ),
  columnFromField<MangaKind, MangaWorkspaceDto, String?>(
    MangaKindSchema.signedBy,
    group: 'Condition',
    defaultWidth: 130,
  ),
];

final mangaLibraryKindSchema = LibraryKindSchema<MangaKind, MangaWorkspaceDto>(
  kindNamespace: 'manga',
  fields: mangaLibraryFieldDefinitions,
  columns: mangaLibraryColumnDefinitions,
  sorts: mangaLibrarySortDefinitions,
  groups: mangaLibraryGroupDefinitions,
  defaultVisibleColumns: mangaLibraryDefaultVisibleColumns,
  defaultSort: MangaSortIds.series,
  defaultGroup: MangaGroupIds.series,
  preferenceCodec: const MangaPreferenceCodec(),
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
