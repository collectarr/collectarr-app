import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

abstract final class MusicWorkspaceFields {
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

  static final backCover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.backCover,
    metadata: MusicWorkspaceFieldMetadata.backCover,
    getValue: (context) => context.dto.music.backCoverImageUrl,
  );

  static final coreId =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.coreId,
    metadata: MusicWorkspaceFieldMetadata.coreId,
    getValue: (context) => switch (context.item.target) {
      CatalogTargetRef(:final ref) => ref.id,
      _ => context.item.entrySummary?.sourceCatalogRef?.id,
    },
  );
}
