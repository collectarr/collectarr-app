import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicCatalogWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    metadata: MusicFieldIdentities.title,
    getValue: (dto) => dto.common.title,
  );

  static final artist = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.artist,
    metadata: MusicFieldIdentities.artist,
    getValue: (context) => context.dto.facts.artistNames,
  );

  static final artistSummary = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artistSummary,
    metadata: MusicFieldIdentities.artistSummary,
    getValue: (dto) => dto.music.artist ?? dto.facts.primaryArtist,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    metadata: MusicFieldIdentities.publisher,
    getValue: (dto) => dto.music.publisher,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    metadata: MusicFieldIdentities.barcode,
    getValue: (dto) => dto.music.barcode,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    metadata: MusicFieldIdentities.catalogNumber,
    getValue: (dto) => dto.music.catalogNumber,
  );

  static final genre = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.genre,
    metadata: MusicFieldIdentities.genre,
    getValue: (context) => context.dto.music.genres,
  );

  static final formatSummary = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.formatSummary,
    metadata: MusicFieldIdentities.formatSummary,
    getValue: (dto) => dto.facts.formatSummary,
  );

  static final discFormat = LibraryFieldDefinition<MusicKind,
      MusicWorkspaceProjection, Iterable<String>>(
    id: MusicFieldIds.discFormat,
    metadata: MusicFieldIdentities.discFormat,
    getValue: (context) => context.dto.facts.discFormats,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    metadata: MusicFieldIdentities.releaseDate,
    getValue: (dto) => dto.music.releaseDate,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    metadata: MusicWorkspaceFieldMetadata.trackCount,
    getValue: (dto) => dto.facts.trackCount,
  );

  static final country = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.country,
    metadata: MusicFieldIdentities.country,
    getValue: (dto) => dto.music.countryCode,
  );

  static final packaging = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.packaging,
    metadata: MusicFieldIdentities.packaging,
    getValue: (dto) => dto.music.packaging,
  );

  static final boxSet = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.boxSet,
    metadata: MusicFieldIdentities.boxSet,
    getValue: (dto) => dto.music.boxSet,
  );

  static final all =
      <LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, Object?>>[
    title,
    artist,
    artistSummary,
    publisher,
    barcode,
    catalogNumber,
    genre,
    formatSummary,
    discFormat,
    releaseDate,
    trackCount,
    country,
    packaging,
    boxSet,
  ];
}
