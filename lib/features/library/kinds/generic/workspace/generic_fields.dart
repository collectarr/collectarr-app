import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_preference_codec.dart';
import 'package:flutter/material.dart';

abstract final class GenericKind {}

abstract final class GenericFieldIds {
  static const title = LibraryFieldId<GenericKind, String?>('unknown.title');
  static const publisher =
      LibraryFieldId<GenericKind, String?>('unknown.publisher');
  static const series = LibraryFieldId<GenericKind, String?>('unknown.series');
  static const releaseDate =
      LibraryFieldId<GenericKind, DateTime?>('unknown.releaseDate');
  static const condition =
      LibraryFieldId<GenericKind, String?>('unknown.condition');
  static const location =
      LibraryFieldId<GenericKind, String?>('unknown.location');
  static const pricePaid =
      LibraryFieldId<GenericKind, int?>('unknown.pricePaid');
}

abstract final class GenericSortIds {
  static const title = LibrarySortId<GenericKind>('unknown.title');
  static const publisher = LibrarySortId<GenericKind>('unknown.publisher');
  static const series = LibrarySortId<GenericKind>('unknown.series');
  static const releaseDate = LibrarySortId<GenericKind>('unknown.releaseDate');
  static const condition = LibrarySortId<GenericKind>('unknown.condition');
}

abstract final class GenericKindSchema {
  static final title = textField<GenericKind, GenericWorkspaceDto>(
    id: GenericFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final publisher = textField<GenericKind, GenericWorkspaceDto>(
    id: GenericFieldIds.publisher,
    label: 'Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final series = textField<GenericKind, GenericWorkspaceDto>(
    id: GenericFieldIds.series,
    label: 'Series',
    getValue: (dto) => dto.seriesTitle,
  );

  static final releaseDate = dateField<GenericKind, GenericWorkspaceDto>(
    id: GenericFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
  );

  static final location =
      LibraryFieldDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<GenericKind, GenericWorkspaceDto, int?>(
    id: GenericFieldIds.pricePaid,
    label: 'Price Paid',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
  );
}

final genericLibraryFieldDefinitions = [
  GenericKindSchema.title,
  GenericKindSchema.publisher,
  GenericKindSchema.series,
  GenericKindSchema.releaseDate,
  GenericKindSchema.condition,
  GenericKindSchema.location,
  GenericKindSchema.pricePaid,
];

final genericLibraryColumnDefinitions = [
  LibraryColumnDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.title,
    label: 'Title',
    getValue: GenericKindSchema.title.getValue,
    defaultWidth: 250,
  ),
  LibraryColumnDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.publisher,
    label: 'Publisher',
    getValue: GenericKindSchema.publisher.getValue,
    defaultWidth: 160,
  ),
  LibraryColumnDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.series,
    label: 'Series',
    getValue: GenericKindSchema.series.getValue,
    defaultWidth: 180,
  ),
  LibraryColumnDefinition<GenericKind, GenericWorkspaceDto, DateTime?>(
    id: GenericFieldIds.releaseDate,
    label: 'Release Date',
    getValue: GenericKindSchema.releaseDate.getValue,
    defaultWidth: 110,
    cellValue: (context) {
      final date = context.dto.releaseDate;
      if (date == null) return const Text('—');
      return Text('${date.year}');
    },
  ),
  LibraryColumnDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.condition,
    label: 'Condition',
    group: 'Personal',
    getValue: GenericKindSchema.condition.getValue,
    defaultWidth: 110,
  ),
  LibraryColumnDefinition<GenericKind, GenericWorkspaceDto, String?>(
    id: GenericFieldIds.location,
    label: 'Location',
    group: 'Personal',
    getValue: GenericKindSchema.location.getValue,
    defaultWidth: 140,
  ),
];

final genericLibrarySortDefinitions = [
  sortFromField<GenericKind, GenericWorkspaceDto, String>(
    GenericKindSchema.title,
  ),
  sortFromField<GenericKind, GenericWorkspaceDto, String>(
    GenericKindSchema.publisher,
  ),
  sortFromField<GenericKind, GenericWorkspaceDto, String>(
    GenericKindSchema.series,
  ),
  sortFromField<GenericKind, GenericWorkspaceDto, DateTime>(
    GenericKindSchema.releaseDate,
  ),
  sortFromField<GenericKind, GenericWorkspaceDto, String>(
    GenericKindSchema.condition,
  ),
];

final genericLibraryGroupDefinitions = [
  groupFromField<GenericKind, GenericWorkspaceDto, String?>(
    GenericKindSchema.series,
    sidebarTitle: 'Series',
    icon: Icons.collections_bookmark_outlined,
  ),
  groupFromField<GenericKind, GenericWorkspaceDto, String?>(
    GenericKindSchema.publisher,
    sidebarTitle: 'Publishers',
    icon: Icons.business_outlined,
  ),
  groupFromField<GenericKind, GenericWorkspaceDto, String?>(
    GenericKindSchema.location,
    sidebarTitle: 'Locations',
    icon: Icons.place_outlined,
  ),
];

final genericLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  GenericFieldIds.title,
  GenericFieldIds.publisher,
  GenericFieldIds.series,
  GenericFieldIds.location,
};

final genericLibraryKindSchema =
    LibraryKindSchema<GenericKind, GenericWorkspaceDto>(
  kindNamespace: 'unknown',
  fields: genericLibraryFieldDefinitions,
  columns: genericLibraryColumnDefinitions,
  sorts: genericLibrarySortDefinitions,
  groups: genericLibraryGroupDefinitions,
  defaultVisibleColumns: genericLibraryDefaultVisibleColumns,
  defaultSort: GenericSortIds.title,
  preferenceCodec: const IdentityLibraryWorkspacePreferenceCodec<GenericKind>(),
);
