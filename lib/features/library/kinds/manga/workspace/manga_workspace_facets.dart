import 'package:collectarr_app/features/library/kinds/manga/config/manga_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/manga/config/manga_workspace_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/workspace/manga_workspace_dto.dart';
import 'package:collectarr_app/features/library/config/library_facet_types.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';

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
    extractValues: _mangaCharacterValues,
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

final mangaSmartListFacetFields =
    <LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, Object?>>[
  LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, Iterable<String>>(
    metadata: MangaWorkspaceFieldMetadata.character,
    id: const LibraryFieldId<MangaKind, Iterable<String>>('manga.character'),
    getValue: (context) => _mangaCharacterValues(context.dto),
  ),
  LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, Iterable<String>>(
    metadata: MangaWorkspaceFieldMetadata.genre,
    id: const LibraryFieldId<MangaKind, Iterable<String>>('manga.genre'),
    getValue: (context) => context.dto.metadata?.genres ?? const <String>[],
  ),
  LibraryFieldDefinition<MangaKind, MangaWorkspaceDto, Iterable<String>>(
    metadata: MangaWorkspaceFieldMetadata.theme,
    id: const LibraryFieldId<MangaKind, Iterable<String>>('manga.theme'),
    getValue: (context) => context.dto.metadata?.themes ?? const <String>[],
  ),
];

Iterable<String> _mangaCharacterValues(MangaWorkspaceDto dto) =>
    dto.metadata?.characters
        .map((character) => character.name)
        .whereType<String>() ??
    const <String>[];
