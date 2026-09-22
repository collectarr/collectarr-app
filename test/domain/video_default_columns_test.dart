import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video list defaults stay media-focused', () {
    for (final workspace in [movieKindWorkspace]) {
      final defaultVisibleColumnIds = workspace.fields.defaultVisibleColumns
          .map((column) => column.value)
          .toSet();
      expect(defaultVisibleColumnIds, contains('movie.title'));
      expect(defaultVisibleColumnIds, contains('movie.director'));
      final releaseColumns = movieKindWorkspace
          .fieldsForScope(LibraryEntityScope.release)
          .defaultVisibleColumns
          .map((column) => column.value)
          .toSet();
      expect(
          releaseColumns,
          containsAll(<String>{
            'movie.release_date',
            'movie.publisher',
          }));
      expect(
        defaultVisibleColumnIds,
        isNot(
          containsAll(<String>{
            'isbn',
            'issue_number',
            'pages',
          }),
        ),
      );
    }
  });
}
