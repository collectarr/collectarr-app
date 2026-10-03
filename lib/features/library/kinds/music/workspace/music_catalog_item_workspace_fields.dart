import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicCatalogItemWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genre,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.releaseDate,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.trackCount,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenCount,
    label: 'Listen count',
    getValue: (dto) => dto.listenCount,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.lastListened,
    label: 'Last listened',
    getValue: (dto) => dto.lastListened,
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isEntry ? 'entry' : null),
    entityScope: LibraryEntityScope.catalogItem,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.imageUrl,
    entityScope: LibraryEntityScope.catalogItem,
  );
}
