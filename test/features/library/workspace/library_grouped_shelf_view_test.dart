import 'package:collectarr_app/features/library/kinds/tv/workspace/tv_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv has series group definition defined in schema', () {
    expect(
      tvLibraryGroupDefinitions
          .firstWhere((definition) => definition.id.value == 'tv.series')
          .id
          .value,
      'tv.series',
    );
  });
}
