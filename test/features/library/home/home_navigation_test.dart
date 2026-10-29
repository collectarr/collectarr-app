import 'package:collectarr_app/core/api/dto/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const music = CatalogMediaType(
      kind: 'music', singularLabel: 'Album', pluralLabel: 'Albums');
  test('active library remains visible at the smallest navigation capacity',
      () {
    final split = splitLibraryNavTypes([music], 'music', 1);
    expect(split.visible, [music]);
    expect(split.overflow, isEmpty);
  });
  test('Music navigation labels differ from album action labels', () {
    expect(libraryNavLabel(music), 'Music');
    expect(music.pluralLabel, 'Albums');
  });
  test('navigation normalizes released kinds and rejects inactive kinds', () {
    expect(canonicalLibraryNavKind('  MUSIC  '), 'music');
    expect(canonicalLibraryNavKind('COMIC'), 'comic');
    for (final kind in ['movie', 'book', 'unknown', '']) {
      expect(canonicalLibraryNavKind(kind), isNull);
    }
    expect(canonicalLibraryNavKind(null), isNull);
  });
  test('navigation groups resolve the active Music library', () {
    final groups = buildLibraryNavGroups([music]);
    expect(groups.single.label, 'Music');
    expect(groups.single.types, [music]);
    expect(
        selectedLibraryNavGroup(groups, 'music').containsKind('music'), isTrue);
  });
}
