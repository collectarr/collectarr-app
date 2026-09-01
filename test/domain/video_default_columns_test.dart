import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('video list defaults stay media-focused', () {
    for (final runtime in [movieKindModule]) {
      final defaultVisibleColumnIds = runtime.fields.defaultVisibleColumns
          .map((column) => column.value)
          .toSet();
      expect(
        defaultVisibleColumnIds,
        containsAll(<String>{
          'movie.title',
          'movie.release_date',
          'movie.publisher',
        }),
      );
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
