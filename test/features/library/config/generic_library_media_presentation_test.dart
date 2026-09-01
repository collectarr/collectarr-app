import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/config/generic_library_workspace_projector.dart';

LibraryProjectionRuntime _makeItem(String id, {String? title}) {
  final cat = testCatalogItem(
    id: id,
    kind: 'comic',
    title: title ?? 'Batman #1',
  );
  final source = ShelfEntry(itemId: id, catalogItem: cat);
  final node = LibraryTitleNodeRef(titleItemId: id);
  final dto = const GenericWorkspaceProjector().projectTitle(
    source: source,
    node: node,
  );
  return LibraryProjectionItem(source: source, node: node, dto: dto);
}

void main() {
  test('leaves unsupported group identifiers opaque', () {
    final item = _makeItem('comic-1', title: 'Batman #1');

    final bucket = genericLibraryBucketLabelBuilder(
      LibraryBucketingContext(
        source: item.source,
        item: item,
        groupMode: 'series',
      ),
    );

    expect(bucket, 'series');
  });
}
