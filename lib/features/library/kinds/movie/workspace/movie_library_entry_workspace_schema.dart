import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/config/movie_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_library_entry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_schema.dart';
import 'package:flutter/material.dart';

abstract final class MovieLibraryEntryWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.condition,
    metadata: MovieWorkspaceFieldMetadata.condition,
    getValue: (context) {
      final entry = MovieLibraryEntryProjection.fromDispatch(
          context.item.libraryEntryDispatch);
      return entry is MovieLibraryEntry ? entry.personal.condition : null;
    },
  );

  static final location =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.location,
    metadata: MovieWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.pricePaid,
    metadata: MovieWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.status,
    metadata: MovieWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.rating,
    metadata: MovieWorkspaceFieldMetadata.rating,
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, bool>(
    id: MovieFieldIds.wishlist,
    metadata: MovieWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, DateTime>(
    id: MovieFieldIds.updatedAt,
    metadata: MovieWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final addedAt =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, DateTime?>(
    id: MovieFieldIds.addedAt,
    metadata: MovieWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final watchStatus =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.watchStatus,
    metadata: MovieWorkspaceFieldMetadata.watchStatus,
    getValue: (context) => context.dto.personal.trackingStatus,
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
    compare: (left, right) {
      int rank(LibraryProjectionContext<MovieWorkspaceDto> ctx) {
        if ((ctx.item.entrySummary != null)) return 0;
        if (ctx.personal.isWishlisted) return 1;
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
    metadata: MovieWorkspaceFieldMetadata.status,
    getValue: MovieLibraryEntryWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, bool>(
    id: MovieFieldIds.wishlist,
    metadata: MovieWorkspaceFieldMetadata.wishlist,
    getValue: MovieLibraryEntryWorkspaceFields.wishlist.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, DateTime>(
    id: MovieFieldIds.updatedAt,
    metadata: MovieWorkspaceFieldMetadata.updatedAt,
    getValue: MovieLibraryEntryWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, DateTime?>(
    id: MovieFieldIds.addedAt,
    metadata: MovieWorkspaceFieldMetadata.addedAt,
    getValue: MovieLibraryEntryWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.addedAt)),
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
    cellValue: (context) => Text(_formatCents(
        context.item.entrySummary?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.rating,
    metadata: MovieWorkspaceFieldMetadata.rating,
    getValue: MovieLibraryEntryWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final movieLibraryEntryWorkspaceSchema =
    LibraryWorkspaceSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  fields: movieLibraryEntryWorkspaceFieldDefinitions,
  columns: movieLibraryEntryWorkspaceColumnDefinitions,
  sorts: movieLibraryEntryWorkspaceSortDefinitions,
  groups: movieLibraryEntryWorkspaceGroupDefinitions,
  primaryColumn: MovieFieldIds.status,
  defaultVisibleColumns: movieLibraryEntryWorkspaceDefaultVisibleColumns,
  defaultSort: MovieSortIds.status,
  defaultGroup: MovieGroupIds.condition,
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
