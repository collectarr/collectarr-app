import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicStatusColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: MusicWorkspaceFields.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicCoverColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: '',
    getValue: MusicWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.imageUrl == null
        ? const SizedBox.shrink()
        : SizedBox.square(
            dimension: 32,
            child: LibraryCoverImage(
              title: context.dto.primaryLabel,
              imageUrl: context.dto.imageUrl,
              fallbackAspectRatio: 1,
              borderRadius: 2,
              fit: BoxFit.cover,
            ),
          ),
    sortable: false,
    groupable: false,
    defaultWidth: 42,
    minWidth: 44,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicReleaseDateColumn({
  LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>? field,
}) {
  final releaseDate = field ?? MusicWorkspaceFields.releaseDate;
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    releaseDate,
    cellValue: (context) => Text(formatMusicDate(context.dto.releaseDate)),
    defaultWidth: 118,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, bool>
    musicWishlistColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MusicWorkspaceFields.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime>
    musicUpdatedAtColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: MusicWorkspaceFields.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicAddedAtColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection,
      DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: MusicWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>
    musicPricePaidColumn() {
  return columnFromField<MusicKind, MusicWorkspaceProjection, int?>(
    MusicWorkspaceFields.pricePaid,
    cellValue: (context) => Text(
      _formatCents(context.source.pricePaidCents, context.dto.currency),
    ),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>
    musicRatingColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: MusicWorkspaceFields.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    group: 'Personal',
    defaultWidth: 80,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicSignedByColumn() {
  return columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
    MusicWorkspaceFields.signedBy,
    group: 'Personal',
    defaultWidth: 124,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicLastCleanedColumn() {
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    MusicWorkspaceFields.lastCleaned,
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicPurchaseDateColumn() {
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    MusicWorkspaceFields.purchaseDate,
    cellValue: (context) => Text(_formatDate(context.source.purchaseDate)),
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>
    musicMarketValueColumn() {
  return columnFromField<MusicKind, MusicWorkspaceProjection, int?>(
    MusicWorkspaceFields.marketValue,
    cellValue: (context) => Text(
      _formatCents(context.source.marketValueCents, context.dto.currency),
    ),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 100,
  );
}

LibrarySortDefinition<MusicKind, MusicWorkspaceProjection> musicStatusSort() {
  return LibrarySortDefinition<MusicKind, MusicWorkspaceProjection>(
    id: MusicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MusicWorkspaceProjection> context) {
        if (context.source.isOwned) return 0;
        if (context.source.isWishlisted) return 1;
        return 2;
      }

      final result = rank(left).compareTo(rank(right));
      return result != 0
          ? result
          : left.dto.primaryLabel.compareTo(right.dto.primaryLabel);
    },
    label: 'Status',
  );
}

String _formatDate(DateTime? value) {
  if (value == null) return '';
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String formatMusicDate(DateTime? value) => _formatDate(value);

String _formatCents(int? cents, String? currency) {
  if (cents == null) return '';
  final amount = (cents / 100).toStringAsFixed(2);
  return currency == null ? amount : '$currency $amount';
}
