import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_conflict_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('restores a conflict with both versions', () async {
    await SyncConflictStore().write([
      SyncRejectedChange(
        entityType: 'library_entry',
        entityId: 'entry-1',
        reason: 'server_has_newer_client_change',
        currentClientChangedAt: DateTime.utc(2026, 11, 6, 9),
        serviceAction: 'upsert',
        servicePayload: const {'pages': 209},
        localAction: 'upsert',
        localPayload: const {'pages': 208},
        localClientChangedAt: DateTime.utc(2026, 11, 6, 8),
      ),
    ]);

    final restored = (await SyncConflictStore().read()).single;

    expect(restored.key, 'library_entry:entry-1');
    expect(restored.reason, 'server_has_newer_client_change');
    expect(restored.currentClientChangedAt, DateTime.utc(2026, 11, 6, 9));
    expect(restored.serviceAction, 'upsert');
    expect(restored.servicePayload, {'pages': 209});
    expect(restored.localAction, 'upsert');
    expect(restored.localPayload, {'pages': 208});
    expect(restored.localClientChangedAt, DateTime.utc(2026, 11, 6, 8));
    expect(restored.canKeepLocal, isTrue);
  });

  test('clearing forgets every conflict', () async {
    await SyncConflictStore().write(const [
      SyncRejectedChange(entityType: 'note', entityId: 'n', reason: 'rejected'),
    ]);

    await SyncConflictStore().clear();

    expect(await SyncConflictStore().read(), isEmpty);
  });

  test('a damaged value reads as no conflicts', () async {
    SharedPreferences.setMockInitialValues({
      'collectarr.sync.conflicts': 'not json',
    });

    expect(await SyncConflictStore().read(), isEmpty);
  });
}
