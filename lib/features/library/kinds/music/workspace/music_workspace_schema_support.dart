import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:flutter/material.dart';

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicStatusColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: field.id,
    label: 'Status',
    getValue: field.getValue,
    cellValue: (context) => Text(context.source.isWishlisted
        ? 'Wishlist'
        : (context.source.isOwned ? 'Owned' : '')),
    sortable: false,
    groupable: false,
    entityScope: field.entityScope,
    defaultWidth: 52,
    minWidth: 44,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicCoverColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: field.id,
    label: '',
    getValue: field.getValue,
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
    entityScope: field.entityScope,
    defaultWidth: 42,
    minWidth: 44,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicReleaseDateColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection,
          DateTime?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    field,
    cellValue: (context) => Text(formatMusicDate(field.getValue(context))),
    defaultWidth: 118,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, bool>
    musicWishlistColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, bool>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, bool>(
    id: field.id,
    label: 'Wishlist',
    getValue: field.getValue,
    cellValue: (context) => Text(context.source.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
    entityScope: field.entityScope,
    defaultWidth: 82,
    minWidth: 70,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime>
    musicUpdatedAtColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, DateTime>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime>(
    id: field.id,
    label: 'Updated',
    getValue: field.getValue,
    cellValue: (context) => Text(_formatDate(field.getValue(context))),
    group: 'Personal',
    entityScope: field.entityScope,
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicAddedAtColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection,
          DateTime?>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection,
      DateTime?>(
    id: field.id,
    label: 'Added',
    getValue: field.getValue,
    cellValue: (context) => Text(_formatDate(field.getValue(context))),
    group: 'Personal',
    entityScope: field.entityScope,
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>
    musicPricePaidColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, int?>(
    field,
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
    musicRatingColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>(
    id: field.id,
    label: 'Rating',
    getValue: field.getValue,
    cellValue: (context) => Text(field.getValue(context)?.toString() ?? ''),
    group: 'Personal',
    entityScope: field.entityScope,
    defaultWidth: 80,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicSignedByColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, String?>(
    field,
    group: 'Personal',
    defaultWidth: 124,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicLastCleanedColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection,
          DateTime?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    field,
    group: 'Personal',
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicPurchaseDateColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection,
          DateTime?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    field,
    cellValue: (context) => Text(_formatDate(field.getValue(context))),
    defaultWidth: 112,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, int?>
    musicMarketValueColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, int?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, int?>(
    field,
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
