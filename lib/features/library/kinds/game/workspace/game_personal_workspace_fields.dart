import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/game_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class GamePersonalWorkspaceFields {
  static final condition =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.condition,
    metadata: GameWorkspaceFieldMetadata.condition,
    getValue: (context) => _entry(context)?.personal.condition,
  );

  static final location =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.location,
    metadata: GameWorkspaceFieldMetadata.location,
    getValue: (context) => context.personal.locationPath,
  );

  static final pricePaid =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.pricePaid,
    metadata: GameWorkspaceFieldMetadata.pricePaid,
    getValue: (context) => context.item.entrySummary?.pricePaidCents,
  );

  static final status =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.status,
    metadata: GameWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final rating =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: GameFieldIds.rating,
    metadata: GameWorkspaceFieldMetadata.rating,
    getValue: (context) => context.dto.personal.rating,
  );

  static final wishlist =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool>(
    id: GameFieldIds.wishlist,
    metadata: GameWorkspaceFieldMetadata.wishlist,
    getValue: (context) => context.personal.isWishlisted,
  );

  static final updatedAt =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: GameFieldIds.updatedAt,
    metadata: GameWorkspaceFieldMetadata.updatedAt,
    getValue: (context) => context.updatedAt,
  );

  static final completionStatus =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completionStatus,
    metadata: GameWorkspaceFieldMetadata.completionStatus,
    getValue: (context) => _entry(context)?.personal.collectionStatus,
  );

  static final completed =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completed,
    metadata: GameWorkspaceFieldMetadata.completed,
    getValue: (context) {
      final entry = _entry(context);
      if (entry == null) return null;
      return entry.personal.details.completed == true ? 'Yes' : 'No';
    },
  );

  static final completeness =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.completeness,
    metadata: GameWorkspaceFieldMetadata.completeness,
    getValue: (context) => _entry(context)?.personal.details.completeness,
  );

  static final hasBox =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.hasBox,
    metadata: GameWorkspaceFieldMetadata.hasBox,
    getValue: (context) => _entry(context)?.personal.details.hasBox,
  );

  static final hasManual =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.hasManual,
    metadata: GameWorkspaceFieldMetadata.hasManual,
    getValue: (context) => _entry(context)?.personal.details.hasManual,
  );

  static final priceChartingId =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.priceChartingId,
    metadata: GameWorkspaceFieldMetadata.priceChartingId,
    getValue: (context) => _entry(context)?.personal.details.priceChartingId,
  );

  static final coreRegion =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.coreRegion,
    metadata: GameWorkspaceFieldMetadata.coreRegion,
    getValue: (context) => _entry(context)?.personal.details.coreRegion,
  );

  static final valueLocked =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, bool?>(
    id: GameFieldIds.valueLocked,
    metadata: GameWorkspaceFieldMetadata.valueLocked,
    getValue: (context) => _entry(context)?.personal.details.valueIsLocked,
  );

  static final loosePrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.loosePrice,
    metadata: GameWorkspaceFieldMetadata.loosePrice,
    getValue: (dto) => dto.loosePrice,
  );

  static final cibPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.cibPrice,
    metadata: GameWorkspaceFieldMetadata.cibPrice,
    getValue: (dto) => dto.cibPrice,
  );

  static final newPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.newPrice,
    metadata: GameWorkspaceFieldMetadata.newPrice,
    getValue: (dto) => dto.newPrice,
  );

  static final gradedPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.gradedPrice,
    metadata: GameWorkspaceFieldMetadata.gradedPrice,
    getValue: (dto) => dto.gradedPrice,
  );

  static final boxOnlyPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.boxOnlyPrice,
    metadata: GameWorkspaceFieldMetadata.boxOnlyPrice,
    getValue: (dto) => dto.boxOnlyPrice,
  );

  static final manualOnlyPrice = numberField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.manualOnlyPrice,
    metadata: GameWorkspaceFieldMetadata.manualOnlyPrice,
    getValue: (dto) => dto.manualOnlyPrice,
  );

  static final purchaseDate =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, PartialDate?>(
    id: const LibraryFieldId('game.purchase_date'),
    metadata: GameWorkspaceFieldMetadata.purchaseDate,
    getValue: (context) => _purchase(context),
  );

  static final purchaseYear =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.purchase_year'),
    metadata: GameWorkspaceFieldMetadata.purchaseYear,
    getValue: (context) => _purchase(context)?.year,
  );

  static final purchaseStore =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: const LibraryFieldId('game.purchase_store'),
    metadata: GameWorkspaceFieldMetadata.purchaseStore,
    getValue: (context) => _entry(context)?.personal.purchaseStore,
  );

  static final value = LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.value'),
    metadata: GameWorkspaceFieldMetadata.value,
    getValue: (context) => _entry(context)?.personal.marketValueCents,
  );

  static final addedDateTime =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: const LibraryFieldId('game.added_datetime'),
    metadata: GameWorkspaceFieldMetadata.addedDateTime,
    getValue: (context) => _entry(context)?.createdAt ?? context.addedAt,
  );

  static final addedYear =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.added_year'),
    metadata: GameWorkspaceFieldMetadata.addedYear,
    getValue: (context) =>
        (_entry(context)?.createdAt ?? context.addedAt)?.year,
  );

  static final modifiedDateTime =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime>(
    id: const LibraryFieldId('game.modified_datetime'),
    metadata: GameWorkspaceFieldMetadata.modifiedDateTime,
    getValue: (context) => _entry(context)?.updatedAt ?? context.updatedAt,
  );

  static final completedDate =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, PartialDate?>(
    id: const LibraryFieldId('game.completed_date'),
    metadata: GameWorkspaceFieldMetadata.completedDate,
    getValue: (context) => _entry(context)?.personal.details.completedDate,
  );

  static final completedYear =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.completed_year'),
    metadata: GameWorkspaceFieldMetadata.completedYear,
    getValue: (context) =>
        _entry(context)?.personal.details.completedDate?.year,
  );

  static final index = LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.index'),
    metadata: GameWorkspaceFieldMetadata.index,
    getValue: (context) => _entry(context)?.personal.indexNumber,
  );

  static final quantity =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.quantity'),
    metadata: GameWorkspaceFieldMetadata.quantity,
    getValue: (context) => _entry(context)?.personal.quantity,
  );

  static final notes =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: const LibraryFieldId('game.notes'),
    metadata: GameWorkspaceFieldMetadata.notes,
    getValue: (context) => _entry(context)?.personal.personalNotes,
  );

  static final owner =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: const LibraryFieldId('game.owner'),
    metadata: GameWorkspaceFieldMetadata.owner,
    getValue: (context) => _entry(context)?.personal.ownerLabel,
  );

  static final storage =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: const LibraryFieldId('game.storage'),
    metadata: GameWorkspaceFieldMetadata.storage,
    getValue: (context) => _entry(context)?.personal.details.storageDevice,
  );

  static final tags =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, Iterable<String>>(
    id: const LibraryFieldId('game.tags'),
    metadata: GameWorkspaceFieldMetadata.tags,
    getValue: (context) => _entry(context)?.personal.tags ?? const <String>[],
  );

  static final all = [
    purchaseDate,
    purchaseYear,
    purchaseStore,
    value,
    addedDateTime,
    addedYear,
    modifiedDateTime,
    completedDate,
    completedYear,
    index,
    quantity,
    notes,
    owner,
    storage,
    tags,
    condition,
    location,
    pricePaid,
    status,
    rating,
    wishlist,
    updatedAt,
    GameCatalogWorkspaceFields.addedAt,
    completionStatus,
    completed,
    completeness,
    coreRegion,
    hasBox,
    hasManual,
    priceChartingId,
    valueLocked,
    loosePrice,
    cibPrice,
    newPrice,
    gradedPrice,
    boxOnlyPrice,
    manualOnlyPrice,
  ];
}

PartialDate? _purchase(LibraryProjectionContext<GameWorkspaceDto> context) {
  final personal = _entry(context)?.personal;
  final date = personal?.purchaseDate;
  return personal?.purchaseDateParts ??
      (date == null ? null : PartialDate.fromDateTime(date));
}

GameLibraryEntry? _entry(LibraryProjectionContext<GameWorkspaceDto> context) =>
    GameLibraryEntryProjection.fromDispatch(context.item.libraryEntryDispatch);
