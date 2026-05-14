import 'package:collectarr_app/core/sync/sync_service.dart';

class SyncWarningFormatter {
  const SyncWarningFormatter._();

  static String? rejectedChanges(List<SyncRejectedChange> changes) {
    if (changes.isEmpty) {
      return null;
    }
    final count = changes.length;
    final changeLabel = count == 1 ? 'change' : 'changes';
    final verb = count == 1 ? 'was' : 'were';
    final reason = _reasonSummary(changes);
    final entitySummary = _entitySummary(changes);
    return '$count local sync $changeLabel $verb not applied because $reason. Service data was kept ($entitySummary).';
  }

  static String _reasonSummary(List<SyncRejectedChange> changes) {
    final reasons = changes.map((change) => change.reason).toSet();
    if (reasons.length == 1 &&
        reasons.single == 'server_has_newer_client_change') {
      return 'another device had newer data';
    }
    if (reasons.length == 1 && reasons.single == 'rejected') {
      return 'the sync service rejected them';
    }
    return 'the sync service kept newer or conflicting data';
  }

  static String _entitySummary(List<SyncRejectedChange> changes) {
    final counts = <String, int>{};
    for (final change in changes) {
      counts.update(change.entityType, (count) => count + 1, ifAbsent: () => 1);
    }
    final parts = [
      for (final entry in counts.entries) _entityLabel(entry.key, entry.value),
    ];
    return parts.join(', ');
  }

  static String _entityLabel(String entityType, int count) {
    final label = switch (entityType) {
      'library_item_snapshot' =>
        count == 1 ? 'catalog snapshot' : 'catalog snapshots',
      'owned_item' => count == 1 ? 'owned item' : 'owned items',
      'wishlist_item' => count == 1 ? 'wishlist item' : 'wishlist items',
      'note' => count == 1 ? 'note' : 'notes',
      _ => _fallbackEntityLabel(entityType, count),
    };
    return '$count $label';
  }

  static String _fallbackEntityLabel(String entityType, int count) {
    final label = entityType.replaceAll('_', ' ');
    return count == 1 ? label : '${label}s';
  }
}
