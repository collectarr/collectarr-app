import 'package:collectarr_app/features/library/add/models/library_add_advanced_filter.dart';
import 'package:collectarr_app/features/library/add/models/library_add_search_context.dart';
import 'package:collectarr_app/features/library/kinds/music/add/music_add_search_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music search includes Core query and medium-filter input', () {
    final queryContext = LibraryAddSearchContext(query: 'Pink Floyd');
    expect(musicAddMediumFilterFor(queryContext), MusicAddMediumFilter.all);
    expect(musicAddHasSearchInput(queryContext), isTrue);

    expect(musicAddHasSearchInput(LibraryAddSearchContext()), isFalse);

    final vinylContext = LibraryAddSearchContext(
      advancedFilters: {
        musicAddMediumFilterId:
            LibraryAddOptionFilterValue(MusicAddMediumFilter.vinyl.value),
      },
    );
    expect(musicAddHasSearchInput(vinylContext), isTrue);
    expect(musicAddMediumFilterFor(vinylContext), MusicAddMediumFilter.vinyl);
  });

  test('medium filter classifies canonical format values', () {
    expect(
      musicAddMediumFilterMatchesTypes(
        ['Compact Disc'],
        MusicAddMediumFilter.cd,
      ),
      isTrue,
    );
    expect(
      musicAddMediumFilterMatchesTypes(['Vinyl'], MusicAddMediumFilter.cd),
      isFalse,
    );
    expect(
      musicAddMediumFilterMatchesTypes(['Vinyl'], MusicAddMediumFilter.vinyl),
      isTrue,
    );
    expect(
      musicAddMediumFilterMatchesTypes(
        ['Digital download'],
        MusicAddMediumFilter.digital,
      ),
      isTrue,
    );
    expect(
      musicAddMediumFilterMatchesTypes([], MusicAddMediumFilter.digital),
      isFalse,
    );
  });
}
