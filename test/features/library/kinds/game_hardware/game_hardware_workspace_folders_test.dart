import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_metadata.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/domain/game_hardware_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace.dart';
import 'package:collectarr_app/features/library/kinds/game_hardware/workspace/game_hardware_workspace_dto.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_workspace_projections.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('folders keep individual tags and group timestamps by calendar day', () {
    final metadata = GameHardwareCatalogMetadata(title: 'Fictional inventory');
    final entry = GameHardwareLibraryEntry(
      id: const LibraryEntryId('folder-test'),
      metadata: metadata,
      personal: const GameHardwarePersonalData(tags: ['A, B', 'Gift']),
      createdAt: DateTime.utc(2026, 10, 16, 9, 23),
      updatedAt: DateTime.utc(2026, 10, 18, 17, 42),
    );
    const personal = PersonalOverlay();
    final context = LibraryProjectionContext(
      item: const WorkspaceItem(
          target: CatalogTargetRef(CatalogItemRef(
              kind: CatalogMediaKind.gameHardware, id: 'folder-test'))),
      personal: personal,
      dto: GameHardwareWorkspaceDto(
        common: const WorkspaceCommonProjection(title: 'Fictional inventory'),
        personal: PersonalEntryProjection(),
        metadata: metadata,
        entry: entry,
      ),
    );
    final groups =
        gameHardwareKindWorkspace.libraryEntryWorkspace.typedFields.groups;
    Object? value(String key) => groups
        .singleWhere((group) => group.id.value == 'game_hardware.$key')
        .getValue(context);
    expect(value('tags'), ['A, B', 'Gift']);
    expect(value('added_date'), '2026-10-16');
    expect(value('modified_date'), '2026-10-18');
    expect(
        groups
            .singleWhere(
                (group) => group.id.value == 'game_hardware.completeness')
            .category,
        'Value');
  });
}
