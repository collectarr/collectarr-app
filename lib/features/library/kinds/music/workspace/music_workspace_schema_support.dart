import 'package:collectarr_app/features/library/kinds/music/workspace/music_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>
    musicStatusColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: MusicKindSchema.status.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    defaultWidth: 52,
    minWidth: 44,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>
    musicCoverColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>(
    id: MusicFieldIds.cover,
    label: '',
    getValue: MusicKindSchema.cover.getValue,
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
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>
    musicReleaseDateColumn() {
  return columnFromField<MusicKind, MusicWorkspaceDto, DateTime?>(
    MusicKindSchema.releaseDate,
    cellValue: (context) => Text(_formatDate(context.dto.releaseDate)),
    defaultWidth: 118,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, bool>
    musicWishlistColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, bool>(
    id: MusicFieldIds.wishlist,
    label: 'Wishlist',
    getValue: MusicKindSchema.wishlist.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    defaultWidth: 82,
    minWidth: 70,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime>
    musicUpdatedAtColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime>(
    id: MusicFieldIds.updatedAt,
    label: 'Updated',
    getValue: MusicKindSchema.updatedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.updatedAt)),
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>
    musicAddedAtColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>(
    id: MusicFieldIds.addedAt,
    label: 'Added',
    getValue: MusicKindSchema.addedAt.getValue,
    cellValue: (context) => Text(_formatDate(context.source.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, int?>
    musicPricePaidColumn() {
  return columnFromField<MusicKind, MusicWorkspaceDto, int?>(
    MusicKindSchema.pricePaid,
    cellValue: (context) =>
        Text(_formatCents(context.source.pricePaidCents, context.dto.currency)),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 92,
    minWidth: 78,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, int?>
    musicRatingColumn() {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, int?>(
    id: MusicFieldIds.rating,
    label: 'Rating',
    getValue: MusicKindSchema.rating.getValue,
    cellValue: (context) => Text(context.dto.personal.rating?.toString() ?? ''),
    group: 'Personal',
    defaultWidth: 80,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, String?>
    musicSignedByColumn() {
  return columnFromField<MusicKind, MusicWorkspaceDto, String?>(
    MusicKindSchema.signedBy,
    group: 'Personal',
    defaultWidth: 124,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>
    musicLastCleanedColumn() {
  return columnFromField<MusicKind, MusicWorkspaceDto, DateTime?>(
    MusicKindSchema.lastCleaned,
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, DateTime?>
    musicPurchaseDateColumn() {
  return columnFromField<MusicKind, MusicWorkspaceDto, DateTime?>(
    MusicKindSchema.purchaseDate,
    cellValue: (context) => Text(_formatDate(context.source.purchaseDate)),
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceDto, int?>
    musicMarketValueColumn() {
  return columnFromField<MusicKind, MusicWorkspaceDto, int?>(
    MusicKindSchema.marketValue,
    cellValue: (context) => Text(
      _formatCents(context.source.marketValueCents, context.dto.currency),
    ),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 100,
  );
}

LibrarySortDefinition<MusicKind, MusicWorkspaceDto> musicStatusSort() {
  return LibrarySortDefinition<MusicKind, MusicWorkspaceDto>(
    id: MusicSortIds.status,
    compare: (left, right) {
      int rank(LibraryProjectionContext<MusicWorkspaceDto> context) {
        if (context.source.isOwned) return 0;
        if (context.source.isWishlisted) return 1;
        return 2;
      }

      final result = rank(left).compareTo(rank(right));
      return result != 0 ? result : left.dto.title.compareTo(right.dto.title);
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
