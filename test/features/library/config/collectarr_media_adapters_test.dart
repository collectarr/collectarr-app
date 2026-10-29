import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry resolves runtime for normalized kind values', () {
    final runtime = libraryKindRegistration(CatalogMediaKind.music);
    expect(runtime.identity.kind, equals(CatalogMediaKind.music));
    expect(libraryKindRegistration(CatalogMediaKind.comic).identity.kind,
        CatalogMediaKind.comic);
    expect(() => libraryKindRegistration(CatalogMediaKind.book),
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

  for (final kind in [
    CatalogMediaKind.game,
    CatalogMediaKind.gameHardware,
    CatalogMediaKind.gameToy,
  ]) {
    test('$kind keeps portrait covers in grid and card layouts', () {
      final type = libraryKindRegistration(kind);
      final profile = libraryViewProfileForKind(kind);
      final height =
          libraryWorkspaceGridMainAxisExtent(type: type, coverSize: 140);
      expect(height, closeTo(200, 0.001));
      expect(1 / profile.coverGridHeightFactor, closeTo(0.7, 0.001));
    });
  }
}
