import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game/workspace/data.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an entry saved without a title still projects, as in the reference',
      () {
    final item = WorkspaceItem(
      target: const CatalogTargetRef(
          CatalogItemRef(kind: CatalogMediaKind.game, id: 'untitled')),
      kindPresentationData:
          GameWorkspaceData(metadata: const GameCatalogMetadata(title: '')),
    );

    expect(item.title, '');
  });
}
