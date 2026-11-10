import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Books exposes edition, credit and personal workspace fields', () {
    final workspace =
        libraryKindWorkspaceForKind(CatalogMediaKind.book).workspaceFields;
    final columns = workspace.columns.map((field) => field.id.value).toSet();
    final sorts = workspace.sorts.map((field) => field.id.value).toSet();
    final groups = workspace.groups.map((field) => field.id.value).toSet();
    expect(
        columns,
        containsAll([
          'book.series',
          'book.page_count',
          'book.cover_artist',
          'book.signed_by',
          'book.genre',
          'book.added_at'
        ]));
    expect(
        sorts,
        containsAll([
          'book.series',
          'book.publisher',
          'book.format',
          'book.isbn',
          'book.editor',
          'book.rating',
          'book.price_paid',
          'book.updated_at'
        ]));
    expect(
        groups,
        containsAll([
          'book.genre',
          'book.subject',
          'book.country',
          'book.language',
          'book.translator',
          'book.editor',
          'book.illustrator',
          'book.cover_artist',
          'book.read_status',
          'book.signed_by'
        ]));
  });
}
