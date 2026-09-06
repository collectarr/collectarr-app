import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers the complete typed Comic workspace facet surface', () {
    final definitions = comicLibraryFacetModule.definitions;
    final ids = definitions.map((definition) => definition.id.value).toList();

    expect(ids, [
      ComicFacetIds.publisher.value,
      ComicFacetIds.genre.value,
      ComicFacetIds.character.value,
      ComicFacetIds.storyArc.value,
      ComicFacetIds.writer.value,
      ComicFacetIds.artist.value,
    ]);
    expect(
      definitions.map((definition) => definition.label),
      everyElement(isNotEmpty),
    );
  });

  test('extracts every Comic facet from the typed workspace DTO', () {
    final dto = _createWorkspace();

    final valuesByFacet = <String, List<String>>{
      for (final definition in comicLibraryFacetDefinitions)
        definition.id.value: definition.extractValues(dto).toList(),
    };

    expect(valuesByFacet[ComicFacetIds.publisher.value], ['Image Comics']);
    expect(valuesByFacet[ComicFacetIds.genre.value], ['Science Fiction']);
    expect(valuesByFacet[ComicFacetIds.character.value], ['Alana', 'Marko']);
    expect(valuesByFacet[ComicFacetIds.storyArc.value], ['The Beginning']);
    expect(valuesByFacet[ComicFacetIds.writer.value], ['Brian K. Vaughan']);
    expect(valuesByFacet[ComicFacetIds.artist.value], ['Fiona Staples']);
  });

  test('runtime facet adapter delegates to typed Comic definitions', () {
    final item = _ProjectionFixture(_createWorkspace());
    final getFacetValues = comicLibraryFacetModule.getFacetValues!;

    expect(
      getFacetValues(item, ComicFacetIds.writer),
      ['Brian K. Vaughan'],
    );
    expect(
      getFacetValues(item, ComicFacetIds.artist),
      ['Fiona Staples'],
    );
    expect(
      getFacetValues(item, ComicFacetIds.character),
      ['Alana', 'Marko'],
    );
  });
}

ComicWorkspaceDto _createWorkspace() {
  return ComicWorkspaceDto(
    common: const WorkspaceCommonProjection(
      title: 'Saga',
      publisher: 'Image Comics',
    ),
    personal: PersonalCopyProjection(),
    comic: const ComicMedia(
      title: 'Saga',
      characters: ['Alana', 'Marko'],
      storyArcs: ['The Beginning'],
      genres: ['Science Fiction'],
      writers: ['Brian K. Vaughan'],
      artists: ['Fiona Staples'],
      publisher: 'Image Comics',
    ),
  );
}

final class _ProjectionFixture
    implements LibraryProjectionRuntime<LibraryWorkspaceDto> {
  _ProjectionFixture(this.dto);

  @override
  final ComicWorkspaceDto dto;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
