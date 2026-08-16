import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/shared/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music workspace exposes album-specific columns', () {
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, 'artist'),
      'Artist',
    );
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, 'front_cover'),
      'Front Cover',
    );
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, 'back_cover'),
      'Back Cover',
    );
    expect(plannedMediaTableColumnLabelForType(musicLibraryConfig, 'album'),
        'Album');
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, 'catalog_number'),
      'Catalog Number',
    );
    expect(
        plannedMediaTableColumnLabelForType(musicLibraryConfig, 'disc_count'),
        'Disc Count');
    expect(
      libraryKindRuntimeForKind(CatalogMediaKind.music)
          .fields
          .defaultVisibleColumnIds,
      containsAll([
        'music.artist',
        'music.title',
        'music.publisher',
        'music.track_count',
      ]),
    );
  });
}
