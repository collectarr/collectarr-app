import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const platform = LibraryLinkedMetadataFilter(value: 'PC', field: 'Platform');

  test('a chip names its field, or only the value without one', () {
    expect(platform.chipLabel, 'Platform: PC');
    expect(const LibraryLinkedMetadataFilter(value: 'PC').chipLabel, 'PC');
  });

  test('a chip matches its value in its own field only', () {
    expect(platform.matches((field: 'Platform', value: 'pc')), isTrue);
    expect(platform.matches((field: 'Series', value: 'PC')), isFalse);
    expect(platform.matches((field: 'Platform', value: 'Wii')), isFalse);
  });

  test('a chip without a field matches the value in any field', () {
    const unnamed = LibraryLinkedMetadataFilter(value: 'PC');
    expect(unnamed.matches((field: 'Series', value: 'PC')), isTrue);
    expect(unnamed.matches((field: null, value: 'PC')), isTrue);
  });

  test('several chips read together where one label fits', () {
    expect(libraryLinkedMetadataFiltersLabel(const []), isNull);
    expect(
      libraryLinkedMetadataFiltersLabel(const [
        platform,
        LibraryLinkedMetadataFilter(value: 'RPG', field: 'Genre'),
      ]),
      'Platform: PC, Genre: RPG',
    );
  });
}
