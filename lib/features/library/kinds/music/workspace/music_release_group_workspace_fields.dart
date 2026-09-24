import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicReleaseGroupWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
    entityScope: LibraryEntityScope.work,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.work,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    label: 'Genre',
    getValue: (dto) => dto.genre,
    entityScope: LibraryEntityScope.work,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseGroupReleaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.music.releaseDate,
    entityScope: LibraryEntityScope.work,
  );

  static final releaseCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseCount,
    label: 'Release count',
    getValue: (dto) => dto.releaseCount,
    entityScope: LibraryEntityScope.work,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseGroupTrackCount,
    label: 'Track count',
    getValue: (dto) => dto.music.trackCount,
    entityScope: LibraryEntityScope.work,
  );

  static final aggregateListenCount =
      numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.aggregateListenCount,
    label: 'Aggregate listens',
    getValue: (dto) => dto.aggregateListenCount,
    entityScope: LibraryEntityScope.work,
  );

  static final aggregateLastListened =
      dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.aggregateLastListened,
    label: 'Last listened',
    getValue: (dto) => dto.aggregateLastListened,
    entityScope: LibraryEntityScope.work,
  );

  static final listenedReleaseCount =
      numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenedReleaseCount,
    label: 'Listened releases',
    getValue: (dto) => dto.listenedReleaseCount,
    entityScope: LibraryEntityScope.work,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.work,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.imageUrl,
    entityScope: LibraryEntityScope.work,
  );
}
