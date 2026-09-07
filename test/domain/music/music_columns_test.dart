import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final musicWorkspace = musicKindWorkspace;
  LibraryFieldIdRuntime field(String value) =>
      musicWorkspace.fields.decodeColumnId(value);

  test('music workspace exposes album-specific columns', () {
    expect(
      plannedMediaTableColumnLabelForType(musicWorkspace.fields, field('artist')),
      'Artist',
    );
    expect(
      plannedMediaTableColumnLabelForType(
        musicWorkspace.fields,
        field('front_cover'),
      ),
      'Front Cover',
    );
    expect(
      plannedMediaTableColumnLabelForType(
        musicWorkspace.fields,
        field('back_cover'),
      ),
      'Back Cover',
    );
    expect(
        plannedMediaTableColumnLabelForType(
            musicWorkspace.fields, field('album')),
        'Album');
    expect(
      plannedMediaTableColumnLabelForType(
        musicWorkspace.fields,
        field('catalog_number'),
      ),
      'Catalog Number',
    );
    expect(
        plannedMediaTableColumnLabelForType(
            musicWorkspace.fields, field('disc_count')),
        'Disc Count');
    expect(
      musicWorkspace.fields.defaultVisibleColumns.map((column) => column.value),
      containsAll([
        'music.artist',
        'music.title',
        'music.publisher',
        'music.track_count',
      ]),
    );
  });
}
