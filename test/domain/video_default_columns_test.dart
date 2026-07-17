import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video list defaults stay media-focused', () {
    for (final config in [moviesLibraryConfig]) {
      final defaultVisibleColumnIds = libraryKindModuleForKind(config.workspace.kind).fields.defaultVisibleColumnIds;
      expect(
        defaultVisibleColumnIds,
        containsAll(<String>{
          'title',
          'release_date',
          'country',
          'language',
          'age_rating',
        }),
      );
      expect(
        defaultVisibleColumnIds,
        isNot(
          containsAll(<String>{
            'condition',
            'price',
            'location',
          }),
        ),
      );
    }
  });
}