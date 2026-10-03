import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_entity_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MovieLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.condition,
    label: 'Condition',
    getValue: (context) {
      final entry = MovieLibraryEntryProjection.fromDispatch(
          context.source.libraryEntryDispatch);
      return entry is MovieLibraryEntry ? entry.condition : null;
    },
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final location =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final pricePaid =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.pricePaidCents,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final status =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final rating =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.dto.personal.rating,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final wishlist =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, bool>(
    id: MovieFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final updatedAt =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, DateTime>(
    id: MovieFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final addedAt =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, DateTime?>(
    id: MovieFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    entityScope: LibraryEntityScope.libraryEntry,
  );

  static final watchStatus =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.dto.personal.trackingStatus,
    entityScope: LibraryEntityScope.libraryEntry,
  );
}

final movieLibraryEntryWorkspaceFieldDefinitions = [
  MovieLibraryEntryWorkspaceFields.condition,
  MovieLibraryEntryWorkspaceFields.location,
  MovieLibraryEntryWorkspaceFields.pricePaid,
];

final movieLibraryEntryWorkspaceGroupDefinitions = [
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieLibraryEntryWorkspaceFields.condition,
    sidebarTitle: 'Conditions',
    category: 'Personal',
    icon: Icons.verified_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieLibraryEntryWorkspaceFields.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
];

final movieLibraryEntryWorkspaceSortDefinitions = [
  LibrarySortDefinition<MovieKind, MovieWorkspaceDto>(
    id: MovieSortIds.status,
    entityScope: LibraryEntityScope.libraryEntry,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MovieWorkspaceDto> ctx) {
        if (ctx.source.isEntry) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
];

final movieLibraryEntryWorkspaceDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.status,
  MovieFieldIds.rating,
  MovieFieldIds.condition,
  MovieFieldIds.pricePaid,
  MovieFieldIds.location,
  MovieFieldIds.wishlist,
  MovieFieldIds.updatedAt,
};

final movieLibraryEntryWorkspaceColumnDefinitions = [
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.status,
    label: 'Status',
    getValue: MovieLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isEntry ? 'Entry' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, bool>(
    id: MovieFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MovieLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, DateTime>(
    id: MovieFieldIds.updatedAt,
    label: 'Updated',
    getValue: MovieLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, DateTime?>(
    id: MovieFieldIds.addedAt,
    label: 'Added',
    getValue: MovieLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieLibraryEntryWorkspaceFields.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieLibraryEntryWorkspaceFields.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, int?>(
    MovieLibraryEntryWorkspaceFields.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.rating,
    label: 'Rating',
    getValue: MovieLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final movieLibraryEntryWorkspaceSchema =
    LibraryEntityWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  entityScope: LibraryEntityScope.libraryEntry,
  fields: movieLibraryEntryWorkspaceFieldDefinitions,
  columns: movieLibraryEntryWorkspaceColumnDefinitions,
  sorts: movieLibraryEntryWorkspaceSortDefinitions,
  groups: movieLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: MovieFieldIds.status,
  defaultVisibleColumns: movieLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: MovieSortIds.status,
  defaultGroup: MovieGroupIds.condition,
  preferenceCodec: const MoviePreferenceCodec(),
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
