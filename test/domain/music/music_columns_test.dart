import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final musicRuntime = musicKindModule;
  LibraryFieldIdRuntime field(String value) =>
      musicRuntime.fields.decodeColumnId(value);

  test('music workspace exposes album-specific columns', () {
    expect(
      plannedMediaTableColumnLabelForType(musicRuntime.fields, field('artist')),
      'Artist',
    );
    expect(
      plannedMediaTableColumnLabelForType(
        musicRuntime.fields,
        field('front_cover'),
      ),
      'Front Cover',
    );
    expect(
      plannedMediaTableColumnLabelForType(
        musicRuntime.fields,
        field('back_cover'),
      ),
      'Back Cover',
    );
    expect(
        plannedMediaTableColumnLabelForType(
            musicRuntime.fields, field('album')),
        'Album');
    expect(
      plannedMediaTableColumnLabelForType(
        musicRuntime.fields,
        field('catalog_number'),
      ),
      'Catalog Number',
    );
    expect(
        plannedMediaTableColumnLabelForType(
            musicRuntime.fields, field('disc_count')),
        'Disc Count');
    expect(
      musicRuntime.fields.defaultVisibleColumns.map((column) => column.value),
      containsAll([
        'music.artist',
        'music.title',
        'music.publisher',
        'music.track_count',
      ]),
    );
  });
}
