import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/catalog_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/presentation/formatting.dart';
import 'package:collectarr_app/features/library/ui/primitives/platform_icon.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';

final gameCatalogWorkspaceColumns = [
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.backCover,
    group: 'Images',
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 48,
    minWidth: 44,
    cellValue: (context) => SizedBox(
      width: 32,
      height: 32,
      child: LibraryCoverImage(
        title: context.dto.title,
        mediaKind: CatalogMediaKind.game,
        libraryEntryRef: context.item.libraryEntryDispatch?.ref,
        localImageType: 'back_cover',
        showPlaceholder: false,
        borderRadius: 0,
      ),
    ),
  ),
  for (final field in [
    GameCatalogWorkspaceFields.coreId,
    GameCatalogWorkspaceFields.description,
  ])
    columnFromField<GameKind, GameWorkspaceDto, String?>(field),
  for (final field in [
    GameCatalogWorkspaceFields.country,
    GameCatalogWorkspaceFields.language,
  ])
    columnFromField<GameKind, GameWorkspaceDto, String?>(field,
        group: 'Edition'),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GameCatalogWorkspaceFields.releaseMonth,
    isNumeric: true,
    defaultWidth: 96,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    metadata: GameWorkspaceFieldMetadata.cover,
    getValue: GameCatalogWorkspaceFields.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(
            context.dto.coverImageUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
    group: 'Images',
    displayName: 'Front Cover',
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameCatalogWorkspaceFields.hasFront,
      group: 'Images',
      displayName: 'Has Front Cover',
      defaultWidth: 96),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameCatalogWorkspaceFields.hasBack,
      group: 'Images',
      displayName: 'Has Back Cover',
      defaultWidth: 96),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.platformIcon,
    metadata: GameWorkspaceFieldMetadata.platformIcon,
    getValue: GameCatalogWorkspaceFields.platformIcon.getValue,
    cellValue: (context) => buildPlatformIcon(context.dto.platform),
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 36,
    minWidth: 32,
    maxWidth: 44,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameCatalogWorkspaceFields.platform,
      defaultWidth: 120),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
      GameCatalogWorkspaceFields.title,
      defaultWidth: 260,
      maxWidth: 520),
  columnFromField<GameKind, GameWorkspaceDto, DateTime?>(
    GameCatalogWorkspaceFields.releaseDate,
    cellValue: (context) => Text(AppFormats.current
        .formatPartialDate(context.dto.metadata.releaseDateParts)),
    // Dates align right, as in the reference list.
    isNumeric: true,
    defaultWidth: 118,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.publisher,
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.developer,
    sortId: const LibrarySortId('game.developer_sort'),
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, int?>(
    GameCatalogWorkspaceFields.releaseYear,
    cellValue: (context) =>
        Text('${context.dto.metadata.releaseDateParts?.year ?? ''}'),
    isNumeric: true,
    defaultWidth: 96,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.series,
    sortId: const LibrarySortId('game.series_sort'),
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.sortTitle,
    defaultWidth: 200,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.audienceRating,
    defaultWidth: 120,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, Iterable<String>>(
    id: GameFieldIds.genre,
    metadata: GameWorkspaceFieldMetadata.genre,
    getValue: (context) => context.dto.metadata.genres,
    cellValue: (context) => Text(context.dto.metadata.genres.join(' | ')),
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.edition,
    group: 'Edition',
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.barcode,
    group: 'Edition',
    defaultWidth: 160,
    maxWidth: 260,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.format,
    sortId: const LibrarySortId('game.format_sort'),
    group: 'Edition',
    defaultWidth: 140,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.region,
    sortId: const LibrarySortId('game.region_sort'),
    group: 'Edition',
    defaultWidth: 110,
  ),
  columnFromField<GameKind, GameWorkspaceDto, String?>(
    GameCatalogWorkspaceFields.franchise,
    defaultWidth: 130,
  ),
  LibraryColumnDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    metadata: GameWorkspaceFieldMetadata.addedAt,
    getValue: GameCatalogWorkspaceFields.addedAt.getValue,
    cellValue: (context) => Text(formatGameDate(context.addedAt)),
    group: 'Personal',
    defaultWidth: 112,
  ),
];
