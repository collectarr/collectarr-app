import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_kind_schema.dart';
import 'package:flutter/material.dart';

export 'package:collectarr_app/features/library/kinds/movie/workspace/movie_ids.dart';
export 'package:collectarr_app/features/library/kinds/movie/workspace/movie_preference_codec.dart';

/// Single source of truth schema for Movie kind fields.
abstract final class MovieKindSchema {
  static final title = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.title,
  );

  static final director = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.director,
    label: 'Director',
    getValue: (dto) => dto.creator,
  );

  static final publisher = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.publisher,
    label: 'Studio / Publisher',
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final condition =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.condition,
    label: 'Condition',
    getValue: (context) => context.source.ownedItem?.condition,
    scope: LibraryFieldScope.copy,
  );

  static final location =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.location,
    label: 'Location',
    getValue: (context) => context.source.locationPath,
    scope: LibraryFieldScope.copy,
  );

  static final pricePaid =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.pricePaid,
    label: 'Purchase Price',
    getValue: (context) => context.source.ownedItem?.pricePaidCents,
    scope: LibraryFieldScope.copy,
  );

  static final barcode = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.barcode,
    label: 'UPC / Barcode',
    getValue: (dto) => dto.barcode,
    scope: LibraryFieldScope.release,
  );

  static final status =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    scope: LibraryFieldScope.copy,
  );

  static final cover =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.coverImageUrl,
    scope: LibraryFieldScope.media,
  );

  static final rating =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.rating,
    label: 'Rating',
    getValue: (context) => context.source.ownedItem?.rating,
    scope: LibraryFieldScope.copy,
  );

  static final wishlist =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, bool>(
    id: MovieFieldIds.wishlist,
    label: 'Wishlist',
    getValue: (context) => context.source.isWishlisted,
    scope: LibraryFieldScope.copy,
  );

  static final updatedAt =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, DateTime>(
    id: MovieFieldIds.updatedAt,
    label: 'Updated',
    getValue: (context) => context.source.updatedAt,
    scope: LibraryFieldScope.copy,
  );

  static final addedAt =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, DateTime?>(
    id: MovieFieldIds.addedAt,
    label: 'Added',
    getValue: (context) => context.source.addedAt,
    scope: LibraryFieldScope.copy,
  );

  static final format = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
  );

  static final watchStatus =
      LibraryFieldDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.watchStatus,
    label: 'Watch Status',
    getValue: (context) => context.source.ownedItem?.readStatus,
    scope: LibraryFieldScope.copy,
  );

  static final releaseYear = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.releaseYear,
    label: 'Release Year',
    getValue: (dto) => dto.releaseDate?.year,
  );

  static final runtimeMinutes = numberField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.runtimeMinutes,
    label: 'Runtime (min)',
    getValue: (dto) => dto.movie.technical.runtimeMinutes,
  );

  static final genre = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.movie.work.genres.isNotEmpty
        ? dto.movie.work.genres.join(', ')
        : null,
  );

  static final audienceRating = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audienceRating,
    label: 'Audience Rating',
    getValue: (dto) => dto.audienceRating,
  );

  static final movieOrTvSeries = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.movieOrTvSeries,
    label: 'Movie / TV Series',
    getValue: (dto) => 'Movie',
  );

  static final edition = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.edition,
    label: 'Edition',
    getValue: (dto) =>
        dto.movie.releases.isNotEmpty ? dto.movie.releases.first.title : null,
    scope: LibraryFieldScope.release,
  );

  static final audioTracks = textField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.audioTracks,
    label: 'Audio Tracks',
    getValue: (dto) => dto.movie.technical.audioTracks,
    scope: LibraryFieldScope.release,
  );

  static final editionReleaseDate = dateField<MovieKind, MovieWorkspaceDto>(
    id: MovieFieldIds.editionReleaseDate,
    label: 'Edition Release Date',
    getValue: (dto) => dto.movie.releases.isNotEmpty
        ? dto.movie.releases.first.releaseDate
        : null,
    scope: LibraryFieldScope.release,
  );
}

final movieLibraryFieldDefinitions = [
  MovieKindSchema.title,
  MovieKindSchema.director,
  MovieKindSchema.publisher,
  MovieKindSchema.releaseDate,
  MovieKindSchema.format,
  MovieKindSchema.condition,
  MovieKindSchema.location,
  MovieKindSchema.pricePaid,
  MovieKindSchema.barcode,
];

final movieLibraryGroupDefinitions = [
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.director,
    category: 'Cast & Crew',
    icon: Icons.movie_creation_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.publisher,
    sidebarTitle: 'Studios',
    category: 'Main',
    icon: Icons.business_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.genre,
    sidebarTitle: 'Genres',
    category: 'Main',
    icon: Icons.category_outlined,
    supportsBucketManagement: true,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, num?>(
    MovieKindSchema.releaseYear,
    category: 'Main',
    icon: Icons.calendar_today_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.audienceRating,
    category: 'Main',
    icon: Icons.star_outline,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.movieOrTvSeries,
    category: 'Main',
    icon: Icons.tv_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.format,
    category: 'Edition',
    icon: Icons.album_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.audioTracks,
    category: 'Edition',
    icon: Icons.audiotrack_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, DateTime?>(
    MovieKindSchema.editionReleaseDate,
    category: 'Edition',
    icon: Icons.calendar_today_outlined,
  ),
  groupFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.location,
    sidebarTitle: 'Locations',
    category: 'Personal',
    icon: Icons.place_outlined,
  ),
];

final movieLibrarySortDefinitions = [
  sortFromField<MovieKind, MovieWorkspaceDto, String>(MovieKindSchema.director),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(
      MovieKindSchema.publisher),
  LibrarySortDefinition<MovieKind, MovieWorkspaceDto>(
    id: MovieSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MovieWorkspaceDto> ctx) {
        if (ctx.source.isOwned) return 0;
        if (ctx.source.isWishlisted) return 1;
        return 2;
      }

      final res = rank(left).compareTo(rank(right));
      return res != 0 ? res : left.dto.title.compareTo(right.dto.title);
    },
    label: 'Status',
  ),
  sortFromField<MovieKind, MovieWorkspaceDto, String>(MovieKindSchema.title),
  sortFromField<MovieKind, MovieWorkspaceDto, DateTime>(
      MovieKindSchema.releaseDate,
      defaultAscending: false),
];

final movieLibraryDefaultVisibleColumns = <LibraryFieldIdRuntime>{
  MovieFieldIds.status,
  MovieFieldIds.cover,
  MovieFieldIds.director,
  MovieFieldIds.title,
  MovieFieldIds.publisher,
  MovieFieldIds.releaseDate,
  MovieFieldIds.format,
  MovieFieldIds.barcode,
  MovieFieldIds.rating,
  MovieFieldIds.condition,
  MovieFieldIds.pricePaid,
  MovieFieldIds.location,
  MovieFieldIds.wishlist,
  MovieFieldIds.updatedAt,
};

final movieLibraryColumnDefinitions = [
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.status,
    label: 'Status',
    getValue: MovieKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, String?>(
    id: MovieFieldIds.cover,
    label: '',
    getValue: MovieKindSchema.cover.getValue,
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
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieKindSchema.director,
      defaultWidth: 150),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(MovieKindSchema.title,
      defaultWidth: 260, maxWidth: 520),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
      MovieKindSchema.publisher,
      defaultWidth: 140),
  columnFromField<MovieKind, MovieWorkspaceDto, DateTime?>(
    MovieKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(MovieKindSchema.format,
      defaultWidth: 90),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, bool>(
    id: MovieFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MovieKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, DateTime>(
    id: MovieFieldIds.updatedAt,
    label: 'Updated',
    getValue: MovieKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, DateTime?>(
    id: MovieFieldIds.addedAt,
    label: 'Added',
    getValue: MovieKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.location,
    group: 'Personal',
    defaultWidth: 118,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.condition,
    group: 'Value',
    defaultWidth: 124,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, int?>(
    MovieKindSchema.pricePaid,
    cellValue: (context) => Text(_formatCents(
        context.source.ownedItem?.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  ),
  columnFromField<MovieKind, MovieWorkspaceDto, String?>(
    MovieKindSchema.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  LibraryColumnDefinition<MovieKind, MovieWorkspaceDto, int?>(
    id: MovieFieldIds.rating,
    label: 'Rating',
    getValue: MovieKindSchema.rating.getValue,
    cellValue: (context) =>
        Text(context.source.ownedItem?.rating?.toString() ?? ''),
    defaultWidth: 80,
  ),
];

final movieLibraryKindSchema = LibraryKindSchema<MovieKind, MovieWorkspaceDto>(
  kindNamespace: 'movie',
  fields: movieLibraryFieldDefinitions,
  columns: movieLibraryColumnDefinitions,
  sorts: movieLibrarySortDefinitions,
  groups: movieLibraryGroupDefinitions,
  defaultVisibleColumns: movieLibraryDefaultVisibleColumns,
  defaultSort: MovieSortIds.director,
  defaultGroup: MovieGroupIds.director,
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
