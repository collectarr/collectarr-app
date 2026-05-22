import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/core/sync/sync_warning_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats rejected sync changes by reason and entity type', () {
    final message = SyncWarningFormatter.rejectedChanges([
      const SyncRejectedChange(
        entityType: 'owned_item',
        entityId: 'owned-1',
        reason: 'server_has_newer_client_change',
      ),
      const SyncRejectedChange(
        entityType: 'wishlist_item',
        entityId: 'wish-1',
        reason: 'server_has_newer_client_change',
      ),
      const SyncRejectedChange(
        entityType: 'owned_item',
        entityId: 'owned-2',
        reason: 'server_has_newer_client_change',
      ),
    ]);

    expect(
      message,
      '3 local sync changes were not applied because another device had newer data. Service data was kept (2 owned items, 1 wishlist item).',
    );
  });

  test('formats stale client reason with user-facing copy', () {
    expect(
      SyncWarningFormatter.reasonLabel('stale_client_change'),
      'This device is behind the service',
    );
  });

  test('returns null when there are no rejected sync changes', () {
    expect(SyncWarningFormatter.rejectedChanges(const []), isNull);
  });
}
