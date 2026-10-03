import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/entries/comic_entry_details.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:flutter/material.dart';

abstract final class ComicLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.condition,
    label: 'Condition',
    getValue: (context) => _entry(context)?.condition,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => _entry(context)?.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: (context) => _entry(context)?.reading.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final grade =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.grade,
    label: 'Grade',
    getValue: (context) => _entry(context)?.grade,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final keyComic =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.keyComic,
    label: 'Key Comic',
    getValue: (context) => _entryDetails(context)?.keyComic == true,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final keyReason =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyReason,
    label: 'Key Reason',
    getValue: (context) => _entryDetails(context)?.keyReason,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final keyCategory =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keyCategory,
    label: 'Key Category',
    getValue: (context) => _entryDetails(context)?.keyCategory,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final keySeverity =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.keySeverity,
    label: 'Key Severity',
    getValue: (context) => _entryDetails(context)?.keySeverity,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rawOrSlabbed =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.rawOrSlabbed,
    label: 'Raw / Slabbed',
    getValue: (context) => _entryDetails(context)?.rawOrSlabbed,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final gradingCompany =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.gradingCompany,
    label: 'Grading Company',
    getValue: (context) => _entryDetails(context)?.gradingCompany,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final graderNotes =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.graderNotes,
    label: 'Grader Notes',
    getValue: (context) => _entryDetails(context)?.graderNotes,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final signedBy =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.signedBy,
    label: 'Signed By',
    getValue: (context) => _entryDetails(context)?.signedBy,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final labelType =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.labelType,
    label: 'Label Type',
    getValue: (context) => _entryDetails(context)?.labelType,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final customLabel =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.customLabel,
    label: 'Custom Label',
    getValue: (context) => _entryDetails(context)?.customLabel,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pageQuality =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.pageQuality,
    label: 'Page Quality',
    getValue: (context) => _entryDetails(context)?.pageQuality,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final certificationNumber =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.certificationNumber,
    label: 'Certification Number',
    getValue: (context) => _entryDetails(context)?.certificationNumber,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final coverPrice =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.coverPrice,
    label: 'Cover Price',
    getValue: (context) => _entryDetails(context)?.coverPriceCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final lastBagBoardDate =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.lastBagBoardDate,
    label: 'Last Bag & Board Date',
    getValue: (context) => _entryDetails(context)?.lastBagBoardDate,
    entityScope: LibraryEntityScope.libraryEntry,
  );
}

ComicLibraryEntry? _entry(LibraryProjectionContext<ComicWorkspaceDto> context) =>
    context.dto.libraryEntry;

ComicEntryDetails? _entryDetails(
  LibraryProjectionContext<ComicWorkspaceDto> context,
) =>
    _entry(context)?.details;

final comicLibraryEntryWorkspaceFieldDefinitions = [
  ComicLibraryEntryWorkspaceFields.status,
  ComicLibraryEntryWorkspaceFields.condition,
  ComicLibraryEntryWorkspaceFields.location,
  ComicLibraryEntryWorkspaceFields.pricePaid,
  ComicLibraryEntryWorkspaceFields.rating,
  ComicLibraryEntryWorkspaceFields.wishlist,
  ComicLibraryEntryWorkspaceFields.updatedAt,
  ComicLibraryEntryWorkspaceFields.addedAt,
  ComicLibraryEntryWorkspaceFields.grade,
  ComicLibraryEntryWorkspaceFields.keyComic,
  ComicLibraryEntryWorkspaceFields.keyReason,
  ComicLibraryEntryWorkspaceFields.keyCategory,
  ComicLibraryEntryWorkspaceFields.rawOrSlabbed,
  ComicLibraryEntryWorkspaceFields.gradingCompany,
  ComicLibraryEntryWorkspaceFields.signedBy,
];

final comicLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
  groupFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    category: 'Personal',
    icon: Icons.verified_outlined,
  ),
];

final comicLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
    id: ComicSortIds.status,
    entityScope: LibraryEntityScope.libraryEntry,
    compare: (left, right) {
      int rank(LibraryProjectionContext<ComicWorkspaceDto> ctx) {
        if (ctx.source.isEntry) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<ComicKind, ComicWorkspaceDto, String>(
      ComicLibraryEntryWorkspaceFields.condition),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(
      ComicLibraryEntryWorkspaceFields.rating,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, int>(
      ComicLibraryEntryWorkspaceFields.pricePaid,
      defaultAscending: false),
  sortFromField<ComicKind, ComicWorkspaceDto, DateTime>(
      ComicLibraryEntryWorkspaceFields.updatedAt,
      defaultAscending: false),
];

final comicLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  ComicFieldIds.status,
  ComicFieldIds.grade,
  ComicFieldIds.keyComic,
  ComicFieldIds.condition,
  ComicFieldIds.pricePaid,
  ComicFieldIds.location,
  ComicFieldIds.wishlist,
  ComicFieldIds.updatedAt,
};

final comicLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: ComicFieldIds.status,
    label: 'Status',
    getValue: ComicLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isEntry ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.grade,
    group: 'Grading',
    defaultWidth: 80,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, bool>(
    ComicLibraryEntryWorkspaceFields.keyComic,
    group: 'Key Info',
    defaultWidth: 90,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, bool>(
    id: ComicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: ComicLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime>(
    id: ComicFieldIds.updatedAt,
    label: 'Updated',
    getValue: ComicLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, DateTime?>(
    id: ComicFieldIds.addedAt,
    label: 'Added',
    getValue: ComicLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, String?>(
    ComicLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<ComicKind, ComicWorkspaceDto, int?>(
    ComicLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) => Text(
        _formatCents(_entry(context)?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, int?>(
    id: ComicFieldIds.rating,
    label: 'Rating',
    getValue: ComicLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) =>
        Text(_entry(context)?.reading.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final comicLibraryEntryWorkspaceSchema =
    LibraryEntityWorkspaceSchema<ComicKind, ComicWorkspaceDto>(
  kindNamespace: 'comic',
  entityScope: LibraryEntityScope.libraryEntry,
  fields: comicLibraryEntryWorkspaceFieldDefinitions,
  columns: comicLibraryEntryWorkspaceColumnDefinitions,
  sorts: comicLibraryEntryWorkspaceSortDefinitions,
  groups: comicLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: ComicFieldIds.status,
  defaultVisibleColumns: comicLibraryEntryWorkspaceDefaultVisibleColumns,
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
