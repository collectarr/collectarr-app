import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_grouping_field.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/groups/music_workspace_group_helpers.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

const musicCatalogGroupingFields = <MusicGroupingField>{
  MusicGroupingField.hasBack,
  MusicGroupingField.hasFront,
  MusicGroupingField.imageType,
  MusicGroupingField.artist,
  MusicGroupingField.genre,
  MusicGroupingField.publisher,
  MusicGroupingField.originalReleaseDate,
  MusicGroupingField.originalReleaseMonth,
  MusicGroupingField.originalReleaseYear,
  MusicGroupingField.releaseDate,
  MusicGroupingField.releaseMonth,
  MusicGroupingField.releaseYear,
  MusicGroupingField.boxSet,
  MusicGroupingField.country,
  MusicGroupingField.extra,
  MusicGroupingField.packaging,
};

Object? musicCatalogGroupValue(
  MusicGroupingField field,
  LibraryProjectionContext<MusicWorkspaceProjection> context,
) {
  final dto = context.dto;
  final album = dto.music;
  final imageTypes = <String>{
    if (dto.imageUrl?.trim().isNotEmpty == true ||
        album.coverImageUrl?.trim().isNotEmpty == true ||
        album.localCoverImagePath?.trim().isNotEmpty == true)
      'front_cover',
    if (album.backCoverImageUrl?.trim().isNotEmpty == true ||
        album.localBackImagePath?.trim().isNotEmpty == true)
      'back_cover',
    for (final image in context.personal.images)
      MusicAlbumImage.imageTypeFromStorageValue(image.imageType),
    for (final type in context.personal.imageTypes)
      MusicAlbumImage.imageTypeFromStorageValue(type),
  };

  return switch (field) {
    MusicGroupingField.hasBack =>
      imageTypes.contains('back_cover') ? 'Yes' : 'No',
    MusicGroupingField.hasFront =>
      imageTypes.contains('front_cover') ? 'Yes' : 'No',
    MusicGroupingField.imageType => imageTypes,
    MusicGroupingField.artist =>
      MusicCatalogWorkspaceFields.artist.getValue(context),
    MusicGroupingField.genre =>
      MusicCatalogWorkspaceFields.genre.getValue(context),
    MusicGroupingField.publisher =>
      MusicCatalogWorkspaceFields.publisher.getValue(context),
    MusicGroupingField.originalReleaseDate =>
      album.originalReleaseDateParts?.isoString,
    MusicGroupingField.originalReleaseMonth =>
      musicGroupMonthLabel(album.originalReleaseDateParts),
    MusicGroupingField.originalReleaseYear =>
      album.originalReleaseDateParts?.year,
    MusicGroupingField.releaseDate => album.releaseDateParts?.isoString,
    MusicGroupingField.releaseMonth =>
      musicGroupMonthLabel(album.releaseDateParts),
    MusicGroupingField.releaseYear => album.releaseDateParts?.year,
    MusicGroupingField.boxSet =>
      MusicCatalogWorkspaceFields.boxSet.getValue(context),
    MusicGroupingField.country =>
      MusicCatalogWorkspaceFields.country.getValue(context),
    MusicGroupingField.extra => album.extra,
    MusicGroupingField.packaging =>
      MusicCatalogWorkspaceFields.packaging.getValue(context),
    _ => throw ArgumentError.value(field, 'field', 'Not a catalog grouping.'),
  };
}
