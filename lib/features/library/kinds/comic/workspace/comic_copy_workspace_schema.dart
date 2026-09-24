import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:flutter/material.dart';

abstract final class ComicCopyWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.condition,
    label: 'Condition',
    getValue: (context) => _owned(context)?.condition,
    entityScope: LibraryEntityScope.copy,
  );

  static final location =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => _owned(context)?.pricePaidCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final status =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.copy,
  );

  static final rating =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => _owned(context)?.reading.rating,
    entityScope: LibraryEntityScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.copy,
  );

  static final grade =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.grade,
    label: 'Grade',
    getValue: (context) => _owned(context)?.grade,
    entityScope: LibraryEntityScope.copy,
  );

  static final keyComic =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.keyComic,
    label: 'Key Comic',
    getValue: (context) => _ownedDetails(context)?.keyComic == true,
    entityScope: LibraryEntityScope.copy,
  );

  static final keyReason =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyReason,
    label: 'Key Reason',
    getValue: (context) => _ownedDetails(context)?.keyReason,
    entityScope: LibraryEntityScope.copy,
  );

  static final keyCategory =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyCategory,
    label: 'Key Category',
    getValue: (context) => _ownedDetails(context)?.keyCategory,
    entityScope: LibraryEntityScope.copy,
  );

  static final keySeverity =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keySeverity,
    label: 'Key Severity',
    getValue: (context) => _ownedDetails(context)?.keySeverity,
    entityScope: LibraryEntityScope.copy,
  );

  static final rawOrSlabbed =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.rawOrSlabbed,
    label: 'Raw / Slabbed',
    getValue: (context) => _ownedDetails(context)?.rawOrSlabbed,
    entityScope: LibraryEntityScope.copy,
  );

  static final gradingCompany =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.gradingCompany,
    label: 'Grading Company',
    getValue: (context) => _ownedDetails(context)?.gradingCompany,
    entityScope: LibraryEntityScope.copy,
  );

  static final graderNotes =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.graderNotes,
    label: 'Grader Notes',
    getValue: (context) => _ownedDetails(context)?.graderNotes,
    entityScope: LibraryEntityScope.copy,
  );

  static final signedBy =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) => _ownedDetails(context)?.signedBy,
    entityScope: LibraryEntityScope.copy,
  );

  static final labelType =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.labelType,
    label: 'Label Type',
    getValue: (context) => _ownedDetails(context)?.labelType,
    entityScope: LibraryEntityScope.copy,
  );

  static final customLabel =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.customLabel,
    label: 'Custom Label',
    getValue: (context) => _ownedDetails(context)?.customLabel,
    entityScope: LibraryEntityScope.copy,
  );

  static final pageQuality =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.pageQuality,
    label: 'Page Quality',
    getValue: (context) => _ownedDetails(context)?.pageQuality,
    entityScope: LibraryEntityScope.copy,
  );

  static final certificationNumber =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.certificationNumber,
    label: 'Certification Number',
    getValue: (context) => _ownedDetails(context)?.certificationNumber,
    entityScope: LibraryEntityScope.copy,
  );

  static final coverPrice =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.coverPrice,
    label: 'Cover Price',
    getValue: (context) => _ownedDetails(context)?.coverPriceCents,
    entityScope: LibraryEntityScope.copy,
  );

  static final lastBagBoardDate =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.lastBagBoardDate,
    label: 'Last Bag & Board Date',
    getValue: (context) => _ownedDetails(context)?.lastBagBoardDate,
    entityScope: LibraryEntityScope.copy,
  );
}

ComicOwnedItem? _owned(LibraryProjectionContext<ComicWorkspaceDto> context) =>
    context.dto.ownedItem;

ComicOwnedDetails? _ownedDetails(
  LibraryProjectionContext<ComicWorkspaceDto> context,
) =>
    _owned(context)?.details;

final comicCopyWorkspaceFieldDefinitions = [
  ComicCopyWorkspaceFields.status,
  ComicCopyWorkspaceFields.condition,
  ComicCopyWorkspaceFields.location,
  ComicCopyWorkspaceFields.pricePaid,
  ComicCopyWorkspaceFields.rating,
  ComicCopyWorkspaceFields.wishlist,
  ComicCopyWorkspaceFields.updatedAt,
  ComicCopyWorkspaceFields.addedAt,
  ComicCopyWorkspaceFields.grade,
  ComicCopyWorkspaceFields.keyComic,
  ComicCopyWorkspaceFields.keyReason,
  ComicCopyWorkspaceFields.keyCategory,
  ComicCopyWorkspaceFields.rawOrSlabbed,
  ComicCopyWorkspaceFields.gradingCompany,
  ComicCopyWorkspaceFields.signedBy,
];

final comicCopyWorkspaceGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCopyWorkspaceFields.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCopyWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    category: 'Personal',
    icon: Icons.verified_outlined,
  ),
];

final comicCopyWorkspaceSortDefinitions = [
  LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
    id: ComicSortIds.status,
    entityScope: LibraryEntityScope.copy,
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
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicCopyWorkspaceFields.condition),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(
      ComicCopyWorkspaceFields.rating,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(
      ComicCopyWorkspaceFields.pricePaid,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicCopyWorkspaceFields.updatedAt,
      defaultAscending: false),
];

final comicCopyWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.status,
  ComicFieldIds.grade,
  ComicFieldIds.keyComic,
  ComicFieldIds.condition,
  ComicFieldIds.pricePaid,
  ComicFieldIds.location,
  ComicFieldIds.wishlist,
  ComicFieldIds.updatedAt,
};

final comicCopyWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: ComicCopyWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCopyWorkspaceFields.grade,
    group: 'Grading',
    defaultWidth: 80,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, bool>(
    ComicCopyWorkspaceFields.keyComic,
    group: 'Key Info',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: ComicCopyWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: ComicCopyWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: ComicCopyWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCopyWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicCopyWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, int?>(
    ComicCopyWorkspaceFields.pricePaid,
    cellValue: (context) => Text(
        _formatCents(_owned(context)?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: ComicCopyWorkspaceFields.rating.getValue,
    cellValue: (context) =>
        Text(_owned(context)?.reading.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final comicCopyWorkspaceSchema =
    LibraryEntityWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  entityScope: LibraryEntityScope.copy,
  fields: comicCopyWorkspaceFieldDefinitions,
  columns: comicCopyWorkspaceColumnDefinitions,
  sorts: comicCopyWorkspaceSortDefinitions,
  groups: comicCopyWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.status,
  defaultVisibleColumns: comicCopyWorkspaceDefaultVisibleColumns,
  defaultSort: ComicSortIds.status,
  defaultGroup: ComicGroupIds.condition,
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
