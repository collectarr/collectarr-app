import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sidebar facets alias matches group mode categories', () {
    const modes = [
      LibraryGroupMode.series,
      LibraryGroupMode.grade,
      LibraryGroupMode.publisher,
    ];

    final adapter = comicsLibraryConfig.kindUiAdapter;
    final categories = adapter.groupModeCategories(comicsLibraryConfig, modes);
    final facets = adapter.sidebarFacets(comicsLibraryConfig, modes);

    expect(facets.map((category) => category.label), [
      for (final category in categories) category.label,
    ]);
  });

  test('comic-only toolbar actions stay in the kind adapter', () {
    final adapter = comicsLibraryConfig.kindUiAdapter;

    expect(
      adapter.supportsMissingComicsReport(comicsLibraryConfig),
      isTrue,
    );
    expect(
      adapter.supportsMissingComicsReport(moviesLibraryConfig),
      isFalse,
    );
  });
}
