import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/config/library_group_bucket_mutation.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';

ComicOwnedItem? _owned(LibraryProjectionContext<ComicWorkspaceDto> context) =>
    context.dto.ownedItem;

ComicOwnedDetails? _ownedDetails(
  LibraryProjectionContext<ComicWorkspaceDto> context,
) =>
    _owned(context)?.details;

/// Single source of truth schema for Comic kind fields.
abstract final class ComicKindSchema {
  static final title = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final issueNumber = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.issueNumber,
    label: 'Issue Number',
    getValue: (dto) => dto.itemNumber,
  );

  static final releaseDate = dateField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.condition,
    label: 'Condition',
    getValue: (context) => _owned(context)?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => _owned(context)?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final barcode = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final status =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => _owned(context)?.reading.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  static final grade =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.grade,
    label: 'Grade',
    getValue: (context) => _owned(context)?.grade,
    scope: LibraryFieldScope.copy,
  );

  static final keyComic =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.keyComic,
    label: 'Key Comic',
    getValue: (context) => _ownedDetails(context)?.keyComic == true,
    scope: LibraryFieldScope.copy,
  );

  static final keyReason =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyReason,
    label: 'Key Reason',
    getValue: (context) => _ownedDetails(context)?.keyReason,
    scope: LibraryFieldScope.copy,
  );

  static final keyCategory =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyCategory,
    label: 'Key Category',
    getValue: (context) => _ownedDetails(context)?.keyCategory,
    scope: LibraryFieldScope.copy,
  );

  static final keySeverity =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keySeverity,
    label: 'Key Severity',
    getValue: (context) => _ownedDetails(context)?.keySeverity,
    scope: LibraryFieldScope.copy,
  );

  static final rawOrSlabbed =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.rawOrSlabbed,
    label: 'Raw / Slabbed',
    getValue: (context) => _ownedDetails(context)?.rawOrSlabbed,
    scope: LibraryFieldScope.copy,
  );

  static final gradingCompany =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.gradingCompany,
    label: 'Grading Company',
    getValue: (context) => _ownedDetails(context)?.gradingCompany,
    scope: LibraryFieldScope.copy,
  );

  static final graderNotes =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.graderNotes,
    label: 'Grader Notes',
    getValue: (context) => _ownedDetails(context)?.graderNotes,
    scope: LibraryFieldScope.copy,
  );

  static final signedBy =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) => _ownedDetails(context)?.signedBy,
    scope: LibraryFieldScope.copy,
  );

  static final labelType =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.labelType,
    label: 'Label Type',
    getValue: (context) => _ownedDetails(context)?.labelType,
    scope: LibraryFieldScope.copy,
  );

  static final customLabel =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.customLabel,
    label: 'Custom Label',
    getValue: (context) => _ownedDetails(context)?.customLabel,
    scope: LibraryFieldScope.copy,
  );

  static final pageQuality =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.pageQuality,
    label: 'Page Quality',
    getValue: (context) => _ownedDetails(context)?.pageQuality,
    scope: LibraryFieldScope.copy,
  );

  static final certificationNumber =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.certificationNumber,
    label: 'Certification Number',
    getValue: (context) => _ownedDetails(context)?.certificationNumber,
    scope: LibraryFieldScope.copy,
  );

  static final coverPrice =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.coverPrice,
    label: 'Cover Price',
    getValue: (context) => _ownedDetails(context)?.coverPriceCents,
    scope: LibraryFieldScope.release,
  );

  static final lastBagBoardDate =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.lastBagBoardDate,
    label: 'Last Bag & Board Date',
    getValue: (context) => _ownedDetails(context)?.lastBagBoardDate,
    scope: LibraryFieldScope.copy,
  );

  // Rich Comic Metadata Fields
  static final writer = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.writer,
    label: 'Writer',
    getValue: (dto) => dto.writer,
  );

  static final artist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
  );

  static final coverArtist = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.coverArtist,
    label: 'Cover Artist',
    getValue: (dto) => dto.coverArtist,
  );

  static final imprint = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.imprint,
    label: 'Imprint',
    getValue: (dto) => dto.imprint,
  );

  static final variant = textField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.variant,
    label: 'Variant',
    getValue: (dto) => dto.variant,
    scope: LibraryFieldScope.release,
  );

  static final pageCount = numberField<ComicKind, ComicWorkspaceDto>(
    id: ComicFieldIds.pageCount,
    label: 'Page Count',
    getValue: (dto) => dto.pageCount,
  );
}

final comicLibraryFacetDefinitions =
    <LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>>[
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    id: ComicFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => [
      if (dto.publisher case final publisher?) publisher,
    ],
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    id: ComicFacetIds.genre,
    label: 'Genre',
    extractValues: (dto) => dto.comic.genres,
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    id: ComicFacetIds.character,
    label: 'Character',
    extractValues: (dto) => dto.comic.characters,
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    id: ComicFacetIds.storyArc,
    label: 'Story Arc',
    extractValues: (dto) => dto.comic.storyArcs,
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    id: ComicFacetIds.writer,
    label: 'Writer',
    extractValues: (dto) => dto.comic.writers,
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    id: ComicFacetIds.artist,
    label: 'Artist',
    extractValues: (dto) => dto.comic.artists,
  ),
];

final comicLibraryFieldDefinitions = [
  ComicKindSchema.title,
  ComicKindSchema.series,
  ComicKindSchema.issueNumber,
  ComicKindSchema.publisher,
  ComicKindSchema.releaseDate,
  ComicKindSchema.condition,
  ComicKindSchema.location,
  ComicKindSchema.pricePaid,
  ComicKindSchema.barcode,
  ComicKindSchema.grade,
  ComicKindSchema.keyComic,
  ComicKindSchema.keyReason,
  ComicKindSchema.keyCategory,
  ComicKindSchema.rawOrSlabbed,
  ComicKindSchema.gradingCompany,
  ComicKindSchema.signedBy,
  ComicKindSchema.writer,
  ComicKindSchema.artist,
  ComicKindSchema.coverArtist,
  ComicKindSchema.imprint,
  ComicKindSchema.variant,
  ComicKindSchema.pageCount,
];

final comicLibraryGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.series,
    sidebarTitle: 'Series',
    category: 'Main',
    icon: Icons.collections_bookmark_outlined,
    supportsJump: true,
    sequenceValue: (context) => context.dto.itemNumber,
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.publisher,
    sidebarTitle: 'Publishers',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
    bucketValueMutator: libraryStringBucketValueMutator(
      'publisher',
      mirrorKeys: ['original_publisher'],
      nestedValueKey: 'original_publisher',
    ),
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
];

final comicLibrarySortDefinitions = [
  sortFromField<ComicKind, ComicWorkspaceDto, String>(ComicKindSchema.series),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicKindSchema.issueNumber),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicKindSchema.publisher),
  LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
    id: ComicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<ComicWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(ComicKindSchema.title),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicKindSchema.releaseDate,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicKindSchema.condition),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(ComicKindSchema.rating,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(ComicKindSchema.pricePaid,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicKindSchema.updatedAt,
      defaultAscending: false),
];

final comicLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.status,
  ComicFieldIds.cover,
  ComicFieldIds.series,
  ComicFieldIds.issueNumber,
  ComicFieldIds.title,
  ComicFieldIds.publisher,
  ComicFieldIds.releaseDate,
  ComicFieldIds.grade,
  ComicFieldIds.keyComic,
  ComicFieldIds.condition,
  ComicFieldIds.pricePaid,
  ComicFieldIds.location,
  ComicFieldIds.wishlist,
  ComicFieldIds.updatedAt,
};

final comicLibraryColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: ComicKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.cover,
    label: '',
    getValue: ComicKindSchema.cover.getValue,
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
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(ComicKindSchema.series,
      defaultWidth: 160),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicKindSchema.issueNumber,
      defaultWidth: 80),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(ComicKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
      ComicKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<ComicKind, ComicWorkspaceDto, DateTime?>(
    ComicKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.grade,
    group: 'Grading',
    defaultWidth: 80,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, bool>(
    ComicKindSchema.keyComic,
    group: 'Key Info',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: ComicKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: ComicKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: ComicKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, int?>(
    ComicKindSchema.pricePaid,
    cellValue: (context) => Text(
        _formatCents(_owned(context)?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: ComicKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(_owned(context)?.reading.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.writer,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.artist,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.coverArtist,
    group: 'Credits',
    defaultWidth: 130,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicKindSchema.imprint,
    group: 'Publisher',
    defaultWidth: 120,
  ),
];

final comicLibraryKindSchema = LibraryKindSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  fields: comicLibraryFieldDefinitions,
  columns: comicLibraryColumnDefinitions,
  sorts: comicLibrarySortDefinitions,
  groups: comicLibraryGroupDefinitions,
  defaultVisibleColumns: comicLibraryDefaultVisibleColumns,
  defaultSort: ComicSortIds.series,
  defaultGroup: ComicGroupIds.series,
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<ComicKind>(),
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
