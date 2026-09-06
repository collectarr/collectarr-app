import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry resolves runtime for normalized kind values', () {
    final comicRuntime = libraryKindModule(CatalogMediaKind.comic);
    expect(comicRuntime.identity.kind, equals(CatalogMediaKind.comic));
  });

  test('music uses square cover grid factor while comics keep portrait factor',
      () {
    final music = libraryKindModule(CatalogMediaKind.music);
    final comics = libraryKindModule(CatalogMediaKind.comic);

    expect(music.viewProfile.coverGridHeightFactor, equals(1.0));
    expect(comics.viewProfile.coverGridHeightFactor, equals(1.53));
  });

  test('workspace grid height follows the view profile', () {
    final music = libraryKindModule(CatalogMediaKind.music);
    final comics = libraryKindModule(CatalogMediaKind.comic);

    expect(
      libraryWorkspaceGridMainAxisExtent(type: music, coverSize: 128),
      equals(128),
    );
    expect(
      libraryWorkspaceGridMainAxisExtent(type: comics, coverSize: 128),
      closeTo(195.84, 0.001),
    );
  });
}
