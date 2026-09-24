import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

abstract final class MusicReleaseWorkspaceFields {
  static final title = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.title,
    label: 'Title',
    getValue: (dto) => dto.primaryLabel,
    entityScope: LibraryEntityScope.release,
  );

  static final artist = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.artist,
    label: 'Artist',
    getValue: (dto) => dto.artist,
    entityScope: LibraryEntityScope.release,
  );

  static final publisher = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.publisher,
    label: 'Label',
    getValue: (dto) => dto.publisher,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseDate = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseDate,
    label: 'Release Date',
    getValue: (dto) => dto.release?.releaseDate,
    entityScope: LibraryEntityScope.release,
  );

  static final trackCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.trackCount,
    label: 'Track count',
    getValue: (dto) => dto.release?.trackCount,
    entityScope: LibraryEntityScope.release,
  );

  static final barcode = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.barcode,
    label: 'Barcode',
    getValue: (dto) => dto.barcode,
    entityScope: LibraryEntityScope.release,
  );

  static final listenCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.listenCount,
    label: 'Listen count',
    getValue: (dto) => dto.listenCount,
    entityScope: LibraryEntityScope.release,
  );

  static final lastListened = dateField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.lastListened,
    label: 'Last listened',
    getValue: (dto) => dto.lastListened,
    entityScope: LibraryEntityScope.release,
  );

  static final catalogNumber = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.catalogNumber,
    label: 'Catalog Number',
    getValue: (dto) => dto.catalogNumber,
    entityScope: LibraryEntityScope.release,
  );

  static final format = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.format,
    label: 'Format',
    getValue: (dto) => dto.format,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseType = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseType,
    label: 'Release type',
    getValue: (dto) => dto.releaseType,
    entityScope: LibraryEntityScope.release,
  );

  static final releaseStatus = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.releaseStatus,
    label: 'Release status',
    getValue: (dto) => dto.releaseStatus,
    entityScope: LibraryEntityScope.release,
  );

  static final language = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.language,
    label: 'Language',
    getValue: (dto) => dto.language,
    entityScope: LibraryEntityScope.release,
  );

  static final packaging = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.packaging,
    label: 'Packaging',
    getValue: (dto) => dto.packaging,
    entityScope: LibraryEntityScope.release,
  );

  static final boxSet = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.boxSet,
    label: 'Box set',
    getValue: (dto) => dto.boxSet,
    entityScope: LibraryEntityScope.release,
  );

  static final country = textField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.country,
    label: 'Country',
    getValue: (dto) => musicCountryName(dto.country),
    entityScope: LibraryEntityScope.release,
  );

  static final discCount = numberField<MusicKind, MusicWorkspaceProjection>(
    id: MusicFieldIds.discCount,
    label: 'Disc Count',
    getValue: (dto) => dto.discCount,
    entityScope: LibraryEntityScope.release,
  );

  static final status =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.status,
    label: 'Status',
    getValue: (context) => context.source.isWishlisted
        ? 'wishlist'
        : (context.source.isOwned ? 'owned' : null),
    entityScope: LibraryEntityScope.release,
  );

  static final cover =
      LibraryFieldDefinition<MusicKind, MusicWorkspaceProjection, String?>(
    id: MusicFieldIds.cover,
    label: 'Cover',
    getValue: (context) => context.dto.imageUrl,
    entityScope: LibraryEntityScope.release,
  );
}
