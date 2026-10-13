import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry resolves runtime for normalized kind values', () {
    final runtime = libraryKindRegistration(CatalogMediaKind.music);
    expect(runtime.identity.kind, equals(CatalogMediaKind.music));
    expect(() => libraryKindRegistration(CatalogMediaKind.comic),
        throwsArgumentError);
  });

  test('Music uses square cover grid geometry', () {
    expect(
      libraryViewProfileForKind(CatalogMediaKind.music).coverGridHeightFactor,
      equals(1.0),
    );
  });

  test('workspace grid height follows the view profile', () {
    final music = libraryKindRegistration(CatalogMediaKind.music);

    expect(
      libraryWorkspaceGridMainAxisExtent(type: music, coverSize: 128),
      equals(128),
    );
  });
}
