import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/kinds/music/config/music_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_catalog_workspace_fields.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final musicLibraryFacetDefinitions =
    <LibraryFacetDefinition<MusicKind, MusicWorkspaceProjection, String>>[
  LibraryFacetDefinition<MusicKind, MusicWorkspaceProjection, String>(
    metadata: MusicFieldIdentities.artist,
    extractValues: MusicCatalogWorkspaceFields.artistValues,
  ),
  LibraryFacetDefinition<MusicKind, MusicWorkspaceProjection, String>(
    metadata: MusicFieldIdentities.publisher,
    extractValues: (dto) => [
      if (MusicCatalogWorkspaceFields.publisherValue(dto) case final value?)
        value,
    ],
  ),
  LibraryFacetDefinition<MusicKind, MusicWorkspaceProjection, String>(
    metadata: MusicFieldIdentities.genre,
    extractValues: MusicCatalogWorkspaceFields.genreValues,
  ),
  LibraryFacetDefinition<MusicKind, MusicWorkspaceProjection, String>(
    metadata: MusicFieldIdentities.discFormat,
    extractValues: MusicCatalogWorkspaceFields.discFormatValues,
  ),
  LibraryFacetDefinition<MusicKind, MusicWorkspaceProjection, String>(
    metadata: MusicFieldIdentities.country,
    extractValues: (dto) => [
      if (MusicCatalogWorkspaceFields.countryValue(dto) case final value?)
        value,
    ],
  ),
];

Iterable<String> getMusicFacetValues(
  MusicWorkspaceProjection dto,
  LibraryFacetIdRuntime facetId,
) {
  for (final definition in musicLibraryFacetDefinitions) {
    if (definition.id.sameIdentityAs(facetId)) {
      return definition.extractValues(dto);
    }
  }
  return const [];
}

final musicLibraryFacetModule =
    TypedLibraryFacetModule<MusicWorkspaceProjection>(
  getFacetValues: getMusicFacetValues,
  externalFacetBucketIdsByMode: {
    for (final definition in musicLibraryFacetDefinitions)
      definition.metadata.id: definition.id,
  },
);
