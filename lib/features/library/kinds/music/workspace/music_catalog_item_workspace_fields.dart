import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicCatalogItemWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: MusicFieldIdentities.titleLabel,
    getValue: (dto) => dto.primaryLabel,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: MusicFieldIdentities.artistLabel,
    getValue: (dto) => dto.artist,
    searchable: true,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    label: MusicFieldIdentities.publisherLabel,
    getValue: (dto) => dto.publisher,
    searchable: true,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    label: MusicFieldIdentities.barcodeLabel,
    getValue: (dto) => dto.barcode,
    searchable: true,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    label: MusicFieldIdentities.catalogNumberLabel,
    getValue: (dto) => dto.catalogNumber,
    searchable: true,
  );

  static final genre = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.genre,
    label: MusicFieldIdentities.genreLabel,
    getValue: (dto) => dto.genre,
    searchable: true,
  );

  static final format = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.format,
    label: MusicFieldIdentities.formatLabel,
    getValue: (dto) => dto.format,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    label: MusicFieldIdentities.releaseDateLabel,
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
