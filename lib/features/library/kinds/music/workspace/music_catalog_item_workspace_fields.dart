import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicCatalogItemWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genre,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.trackCount,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenCount,
    label: 'Listen count',
    getValue: (dto) => dto.listenCount,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.lastListened,
    label: 'Last listened',
    getValue: (dto) => dto.lastListened,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.personal.isWishlisted
        ? 'wishlist'
        : ((context.item.entrySummary != null) ? 'entry' : null),
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.imageUrl,
  );
}
