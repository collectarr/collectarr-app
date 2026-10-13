import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/generic/transferable_field.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_personal_data.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ref = LibraryEntryRef(
      kind: CatalogMediaKind.music, id: LibraryEntryId('independent-album'));
  test('independent local entries are transferable without Core provenance',
      () {
    final album = MusicLibraryEntry(
      id: ref.id,
      metadata: MusicAlbum(title: 'Independent Album'),
      personal: const MusicPersonalData(condition: 'Near Mint'),
      updatedAt: DateTime.utc(2026, 10, 11),
    );
    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: EntryTargetRef(ref),
        entrySummary: LibraryEntrySummary(ref: ref),
        libraryEntryDispatch: OpaqueLibraryEntryDispatch(
            ref: ref, kind: CatalogMediaKind.music, value: album),
      ),
      personal: PersonalOverlay(),
    );
    expect(source.sourceCatalogRef, isNull);
    final entry = TransferableLibraryEntry.fromWorkspaceContext(source)!;
    expect(entry.ref, ref);
    expect(entry.value, same(album));
    final fields = libraryTransferForKind(CatalogMediaKind.music).allFields();
    final condition = fields.firstWhere((field) => field.key == 'condition');
    final purchaseStore =
        fields.firstWhere((field) => field.key == 'purchaseStore');
    expect(condition.readFrom(entry.value), 'Near Mint');
    final updated =
        purchaseStore.writeTo(entry.value, condition.readFrom(entry.value));
    expect(purchaseStore.readFrom(updated), 'Near Mint');
    expect(condition.readFrom(updated), 'Near Mint');
    expect(album.personal.purchaseStore, isNull);
  });

  test('catalog-only targets cannot be transferred as local entries', () {
    const source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: CatalogTargetRef(
            CatalogItemRef(kind: CatalogMediaKind.music, id: 'catalog-album')),
      ),
      personal: PersonalOverlay(),
    );
    expect(TransferableLibraryEntry.fromWorkspaceContext(source), isNull);
  });
}
