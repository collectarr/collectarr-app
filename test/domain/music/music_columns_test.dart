import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final musicRuntime = musicKindModule;
  LibraryFieldIdRuntime field(String value) =>
      musicRuntime.fields.decodeColumnId(value);

  test('music workspace exposes album-specific columns', () {
    expect(
      plannedMediaTableColumnLabelForType(musicKindModule, field('artist')),
      'Artist',
    );
    expect(
      plannedMediaTableColumnLabelForType(
        musicKindModule,
        field('front_cover'),
      ),
      'Front Cover',
    );
    expect(
      plannedMediaTableColumnLabelForType(
        musicKindModule,
        field('back_cover'),
      ),
      'Back Cover',
    );
    expect(plannedMediaTableColumnLabelForType(musicKindModule, field('album')),
        'Album');
    expect(
      plannedMediaTableColumnLabelForType(
        musicKindModule,
        field('catalog_number'),
      ),
      'Catalog Number',
    );
    expect(
        plannedMediaTableColumnLabelForType(
            musicKindModule, field('disc_count')),
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
