import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final mangaLibraryFacetDefinitions =
    <LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>>[
  if (MangaFieldIdentities.publisher.filterable)
    LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
      metadata: MangaFieldIdentities.publisher,
      extractValues: (dto) => [
        if (dto.publisher case final publisher?) publisher,
      ],
    ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    metadata: MangaWorkspaceFieldMetadata.genre,
    extractValues: (dto) => dto.metadata?.genres ?? const <String>[],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    metadata: MangaWorkspaceFieldMetadata.character,
    extractValues: (_) => const <String>[],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    metadata: MangaWorkspaceFieldMetadata.theme,
    extractValues: (dto) => dto.metadata?.themes ?? const <String>[],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    metadata: MangaWorkspaceFieldMetadata.demographic,
    extractValues: (dto) => [dto.metadata?.demographic.label ?? 'Other'],
  ),
];
