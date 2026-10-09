import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicCatalogItemWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    metadata: MusicFieldIdentities.title,
    getValue: (dto) => dto.primaryLabel,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    metadata: MusicFieldIdentities.artist,
    getValue: (dto) => dto.artist,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    metadata: MusicFieldIdentities.publisher,
    getValue: (dto) => dto.publisher,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    metadata: MusicFieldIdentities.barcode,
    getValue: (dto) => dto.barcode,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    metadata: MusicFieldIdentities.catalogNumber,
    getValue: (dto) => dto.catalogNumber,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    metadata: MusicFieldIdentities.genre,
    getValue: (dto) => dto.genre,
  );

  static final format = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.format,
    metadata: MusicFieldIdentities.format,
    getValue: (dto) => dto.format,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    metadata: MusicFieldIdentities.releaseDate,
    getValue: (dto) => dto.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    metadata: MusicWorkspaceFieldMetadata.trackCount,
    getValue: (dto) => dto.trackCount,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenCount,
    metadata: MusicWorkspaceFieldMetadata.listenCount,
    getValue: (dto) => dto.listenCount,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.lastListened,
    metadata: MusicWorkspaceFieldMetadata.lastListened,
    getValue: (dto) => dto.lastListened,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    metadata: MusicWorkspaceFieldMetadata.status,
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    metadata: MusicWorkspaceFieldMetadata.cover,
    getValue: (context) => context.dto.imageUrl,
  );
}
