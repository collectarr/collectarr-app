import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video list defaults stay media-focused', () {
    for (final config in [
      tvWorkspaceConfig,
      moviesWorkspaceConfig,
      animeWorkspaceConfig,
    ]) {
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
            LibraryTableColumn.storageBox,
          }),
        ),
      );
    }
  });
}