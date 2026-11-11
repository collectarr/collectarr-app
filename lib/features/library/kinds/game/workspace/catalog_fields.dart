import 'package:collectarr_app/features/library/kinds/game/config/field_identities.dart';
import 'package:collectarr_app/features/library/kinds/game/config/game_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/ids.dart';
import 'package:collectarr_app/features/library/config/kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/groups.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_library_entry_projection.dart';
import 'package:collectarr_app/ui/app_formatted_text.dart';

abstract final class GameCatalogWorkspaceFields {
  static final coreId =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: const LibraryFieldId('game.core_id'),
    metadata: GameWorkspaceFieldMetadata.coreId,
    getValue: (context) {
      if (context.item.libraryEntryDispatch != null) {
        return GameLibraryEntryProjection.fromDispatch(
                context.item.libraryEntryDispatch)
            ?.sourceCatalogRef
            ?.id;
      }
      if (context.item.entrySummary != null) {
        return context.item.entrySummary?.sourceCatalogRef?.id;
      }
      return switch (context.item.target) {
        CatalogTargetRef(:final ref) => ref.id,
        _ => null,
      };
    },
  );

  static final description = textField<GameKind, GameWorkspaceDto>(
    id: const LibraryFieldId('game.description'),
    metadata: GameWorkspaceFieldMetadata.description,
    getValue: (dto) {
      final source = dto.metadata.description ?? dto.metadata.synopsis;
      return source == null
          ? null
          : parseAppFormattedText(source).map((block) => block.text).join('\n');
    },
  );

  static final country = textField<GameKind, GameWorkspaceDto>(
    id: const LibraryFieldId('game.country'),
    metadata: GameWorkspaceFieldMetadata.country,
    getValue: (dto) => dto.country,
  );

  static final language = textField<GameKind, GameWorkspaceDto>(
    id: const LibraryFieldId('game.language'),
    metadata: GameWorkspaceFieldMetadata.language,
    getValue: (dto) => dto.language,
  );

  static final releaseMonth =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.release_month'),
    metadata: GameWorkspaceFieldMetadata.releaseMonth,
    getValue: (context) => context.dto.metadata.releaseDateParts?.month,
  );

  static final backCover =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: const LibraryFieldId('game.back_cover'),
    metadata: GameWorkspaceFieldMetadata.backCover,
    getValue: (context) => context.personal.images
        .where((image) => image.imageType == 'back_cover')
        .firstOrNull
        ?.id,
  );
  static final title = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.title,
    metadata: GameWorkspaceFieldMetadata.title,
    getValue: (dto) => dto.title,
  );

  static final platform = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.platform,
    metadata: GameWorkspaceFieldMetadata.platform,
    getValue: (dto) => dto.platform,
  );

  static final developer = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.developer,
    metadata: GameWorkspaceFieldMetadata.developer,
    getValue: (dto) => dto.developer,
  );

  static final publisher = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.publisher,
    metadata: GameWorkspaceFieldMetadata.publisher,
    getValue: (dto) => dto.publisher,
  );

  static final releaseDate = dateField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.releaseDate,
    metadata: GameFieldIdentities.releaseDate,
    getValue: (dto) => dto.releaseDate,
  );

  static final barcode = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.barcode,
    metadata: GameFieldIdentities.barcode,
    getValue: (dto) => dto.barcode,
  );

  static final edition = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.edition,
    metadata: GameWorkspaceFieldMetadata.edition,
    getValue: (dto) => dto.edition,
  );

  static final cover =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.cover,
    metadata: GameWorkspaceFieldMetadata.cover,
    getValue: (context) => context.dto.coverImageUrl,
  );

  static final franchise = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.franchise,
    metadata: GameFieldIdentities.franchise,
    getValue: (dto) => dto.franchise,
  );

  static final series = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.series,
    metadata: GameWorkspaceFieldMetadata.series,
    getValue: (dto) => dto.seriesTitle,
  );

  static final ageRating = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.ageRating,
    metadata: GameWorkspaceFieldMetadata.ageRating,
    getValue: (dto) => dto.ageRating,
  );

  static final region = textField<GameKind, GameWorkspaceDto>(
    id: GameFieldIds.region,
    metadata: GameWorkspaceFieldMetadata.region,
    getValue: (dto) => dto.region,
  );

  static final addedAt =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, DateTime?>(
    id: GameFieldIds.addedAt,
    metadata: GameWorkspaceFieldMetadata.addedAt,
    getValue: (context) => context.addedAt,
  );

  static final platformIcon =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?>(
    id: GameFieldIds.platformIcon,
    metadata: GameWorkspaceFieldMetadata.platformIcon,
    getValue: (context) => context.dto.platform,
  );

  static final audienceRating = textField<GameKind, GameWorkspaceDto>(
    id: const LibraryFieldId('game.audience_rating'),
    metadata: GameWorkspaceFieldMetadata.audienceRating,
    getValue: (dto) => dto.metadata.audienceRating,
  );

  static final sortTitle = textField<GameKind, GameWorkspaceDto>(
    id: const LibraryFieldId('game.sort_title'),
    metadata: GameWorkspaceFieldMetadata.sortTitle,
    getValue: (dto) => dto.metadata.sortKey ?? dto.title,
  );

  static final format = textField<GameKind, GameWorkspaceDto>(
    id: const LibraryFieldId('game.format'),
    metadata: GameWorkspaceFieldMetadata.format,
    getValue: (dto) =>
        dto.metadata.physicalFormatLabel ?? dto.metadata.physicalFormat,
  );

  static final releaseYear =
      LibraryFieldDefinition<GameKind, GameWorkspaceDto, int?>(
    id: const LibraryFieldId('game.release_year'),
    metadata: GameWorkspaceFieldMetadata.releaseYear,
    getValue: (context) => context.dto.metadata.releaseDateParts?.year,
  );

  static final hasFront =
      _imageFlag(GameWorkspaceFieldMetadata.hasFront, 'front_cover');

  static final hasBack =
      _imageFlag(GameWorkspaceFieldMetadata.hasBack, 'back_cover');

  static final all = [
    coreId,
    description,
    country,
    language,
    releaseMonth,
    backCover,
    audienceRating,
    sortTitle,
    format,
    releaseYear,
    hasFront,
    hasBack,
    title,
    platform,
    platformIcon,
    developer,
    publisher,
    releaseDate,
    barcode,
    edition,
    cover,
    franchise,
    series,
    ageRating,
    region,
  ];
}

LibraryFieldDefinition<GameKind, GameWorkspaceDto, String?> _imageFlag(
        LibraryKindFieldMetadata metadata, String imageType) =>
    LibraryFieldDefinition(
      id: LibraryFieldId(metadata.id),
      metadata: metadata,
      getValue: (context) =>
          gameWorkspaceImageTypes(context).contains(imageType) ? 'Yes' : 'No',
    );
