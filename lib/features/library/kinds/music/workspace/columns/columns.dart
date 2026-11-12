import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:flutter/material.dart';

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicStatusColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: field.id,
    metadata: field.metadata,
    getValue: field.getValue,
    cellValue: (context) => Text(context.personal.isWishlisted
        ? 'Wishlist'
        : ((context.item.entrySummary != null) ? 'Entry' : '')),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 52,
    minWidth: 44,
  );
}

/// A front or back cover image, listed under Images as in the reference:
/// scaled with the cover size while retaining its square aspect ratio.
LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>
    musicCoverColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>
      field,
}) {
  return LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: field.id,
    metadata: field.metadata,
    getValue: field.getValue,
    cellValue: (context) {
      final imageUrl = field.getValue(context);
      return imageUrl == null || imageUrl.isEmpty
          ? const SizedBox.shrink()
          : AspectRatio(
              aspectRatio: 1,
              child: LibraryCoverImage(
                title: context.dto.primaryLabel,
                mediaKind: CatalogMediaKind.music,
                imageUrl: imageUrl,
                fallbackAspectRatio: 1,
                borderRadius: 0,
                fit: BoxFit.fill,
              ),
            );
    },
    group: 'Images',
    imageAspectRatio: 1,
    cellPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 90,
    minWidth: 44,
  );
}

LibraryColumnDefinition<MusicKind, MusicWorkspaceProjection, DateTime?>
    musicAlbumDateColumn({
  required LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection,
          DateTime?>
      field,
}) {
  return columnFromField<MusicKind, MusicWorkspaceProjection, DateTime?>(
    field,
    cellValue: (context) => Text(AppFormats.current
        .formatPartialDate(context.dto.music.releaseDateParts)),
    isNumeric: true,
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
    metadata: field.metadata,
    getValue: field.getValue,
    cellValue: (context) =>
        Text(context.personal.isWishlisted ? 'Wishlist' : ''),
    group: 'Personal',
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
    metadata: field.metadata,
    getValue: field.getValue,
    cellValue: (context) => Text(_formatDate(field.getValue(context))),
    group: 'Personal',
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
    metadata: field.metadata,
    getValue: field.getValue,
    cellValue: (context) => Text(_formatDate(field.getValue(context))),
    group: 'Personal',
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
      AppFormats.current.formatMoney(
        context.item.entrySummary?.pricePaidCents,
        context.dto.common.currency,
      ),
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
    metadata: field.metadata,
    getValue: field.getValue,
    cellValue: (context) => Text(field.getValue(context)?.toString() ?? ''),
    group: 'Personal',
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
      AppFormats.current.formatMoney(
        context.item.entrySummary?.marketValueCents,
        context.dto.common.currency,
      ),
    ),
    group: 'Value',
    isNumeric: true,
    defaultWidth: 100,
  );
}

String _formatDate(DateTime? value) =>
    value == null ? '' : AppFormats.current.formatDate(value);
