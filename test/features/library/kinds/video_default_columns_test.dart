import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video list defaults stay media-focused', () {
    for (final config in [moviesWorkspaceConfig]) {
      expect(
        config.defaultVisibleColumns,
        containsAll(<LibraryTableColumn>{
          LibraryTableColumn.title,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.country,
          LibraryTableColumn.language,
          LibraryTableColumn.ageRating,
        }),
      );
      expect(
        config.defaultVisibleColumns,
        isNot(
          containsAll(<LibraryTableColumn>{
            LibraryTableColumn.condition,
            LibraryTableColumn.price,
            LibraryTableColumn.location,
          }),
        ),
      );
    }
  });
}