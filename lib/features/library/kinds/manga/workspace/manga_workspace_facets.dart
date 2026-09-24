import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_ids.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

final mangaLibraryFacetDefinitions =
    <LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>>[
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    id: MangaFacetIds.publisher,
    label: 'Publisher',
    extractValues: (dto) => [
      if (dto.publisher case final publisher?) publisher,
    ],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    id: MangaFacetIds.genre,
    label: 'Genre',
    extractValues: (dto) => dto.metadata?.genres ?? const <String>[],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    id: MangaFacetIds.character,
    label: 'Character',
    extractValues: (_) => const <String>[],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    id: MangaFacetIds.theme,
    label: 'Theme',
    extractValues: (dto) => dto.metadata?.themes ?? const <String>[],
  ),
  LibraryFacetDefinition<MangaKind, MangaWorkspaceDto, String>(
    id: MangaFacetIds.demographic,
    label: 'Demographic',
    extractValues: (dto) => [dto.metadata?.demographic.label ?? 'Other'],
  ),
];
