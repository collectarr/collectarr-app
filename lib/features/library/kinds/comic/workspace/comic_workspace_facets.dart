import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final comicLibraryFacetDefinitions =
    <LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>>[
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    metadata: ComicWorkspaceFieldMetadata.publisher,
    extractValues: (dto) => [
      if (dto.publisher case final publisher?) publisher,
    ],
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    metadata: ComicWorkspaceFieldMetadata.genre,
    extractValues: (dto) => dto.comic.genres,
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    metadata: ComicWorkspaceFieldMetadata.character,
    extractValues: (dto) => dto.comic.characters
        .map((character) => character.name)
        .whereType<String>(),
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    metadata: ComicWorkspaceFieldMetadata.storyArc,
    extractValues: (dto) =>
        dto.comic.storyArcs.map((arc) => arc.name).whereType<String>(),
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    metadata: ComicWorkspaceFieldMetadata.writer,
    extractValues: (dto) => _creatorNamesForRole(dto, 'writer'),
  ),
  LibraryFacetDefinition<ComicKind, ComicWorkspaceDto, String>(
    metadata: ComicWorkspaceFieldMetadata.artist,
    extractValues: (dto) => _creatorNamesForRole(dto, 'artist'),
  ),
];

Iterable<String> _creatorNamesForRole(ComicWorkspaceDto dto, String role) => [
      ...dto.comic.contributors,
      ...dto.comic.creators,
    ]
        .where((creator) {
          final value = (creator.roleId ?? creator.role ?? '')
              .toLowerCase()
              .replaceAll(RegExp('[^a-z]'), '');
          return value == role;
        })
        .map((creator) => creator.name)
        .whereType<String>();
