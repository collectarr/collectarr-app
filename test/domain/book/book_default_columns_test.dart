import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_view_enums.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('book list defaults stay book-focused', () {
    expect(
      libraryKindModuleForKind(CatalogMediaKind.book).fields.defaultVisibleColumnIds,
      containsAll(<Object>{
        'author',
        'title',
        'publisher',
        'release_date',
        'barcode',
        'read_status',
        'rating',
        'condition',
        'location',
      }),
    );
  });
}
