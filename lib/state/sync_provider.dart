import 'dart:developer' as developer;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_cursor_store.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/core/sync/sync_service.dart';
import 'package:collectarr_app/core/sync/sync_warning_formatter.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

class SyncLogEntry {
  const SyncLogEntry({
    required this.timestamp,
    required this.success,
    this.pushed = 0,
    this.pulled = 0,
    this.rejected = 0,
    this.errorMessage,
  });

  final DateTime timestamp;
  final bool success;
  final int pushed;
  final int pulled;
  final int rejected;
  final String? errorMessage;
}

class SyncState {
  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.isOffline = false,
    this.lastSyncedAt,
    this.errorMessage,
    this.warningMessage,
    this.rejectedChanges = const [],
    this.syncLog = const [],
  });

  final int pendingCount;
  final bool isSyncing;
  final bool isOffline;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final String? warningMessage;
  final List<SyncRejectedChange> rejectedChanges;
  final List<SyncLogEntry> syncLog;

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    bool? isOffline,
    DateTime? lastSyncedAt,
    String? errorMessage,
    String? warningMessage,
    List<SyncRejectedChange>? rejectedChanges,
    List<SyncLogEntry>? syncLog,
    bool clearError = false,
    bool clearWarning = false,
    bool clearRejectedChanges = false,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      warningMessage:
          clearWarning ? null : warningMessage ?? this.warningMessage,
      rejectedChanges: clearRejectedChanges
          ? const []
          : rejectedChanges ?? this.rejectedChanges,
      syncLog: syncLog ?? this.syncLog,
    );
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref)..refreshPendingCount();
});

class SyncController extends StateNotifier<SyncState> {
  SyncController(this.ref) : super(const SyncState());

  final Ref ref;

  Future<void> refreshPendingCount() async {
    final count = await _queue().pendingCount();
    final lastSyncedAt = await _readLastSyncedAt();
    state = state.copyWith(pendingCount: count, lastSyncedAt: lastSyncedAt);
  }

  static const _maxLogEntries = 20;

  Future<void> syncNow() async {
    final preSyncPending = state.pendingCount;
    state = state.copyWith(
      isSyncing: true,
      isOffline: false,
      clearError: true,
      clearWarning: true,
      clearRejectedChanges: true,
    );
    try {
      final deviceId = await DeviceIdentity().getOrCreate();
      final cursor = SyncCursorStore();
      final since = await cursor.read();
      final db = ref.read(localDatabaseProvider);
      final settings = ref.read(connectionSettingsProvider);
      final result = await SyncService(
        client: CollectarrSyncClient(
          baseUrl: settings.syncBaseUrl,
          syncKey: settings.syncKey,
        ),
        db: db,
        queue: SyncQueueRepository(db),
        catalog: CatalogCacheRepository(db),
        ownedItems: OwnedItemsCacheRepository(db),
        wishlistItems: WishlistItemsCacheRepository(db),
      ).syncNow(deviceId, since: since);
      await cursor.write(result.serverTime);
      ref.invalidate(collectionProvider);
      ref.invalidate(wishlistIdsProvider);
      ref.invalidate(wishlistProvider);
      ref.invalidate(shelfProvider);
      final count = await _queue().pendingCount();
      final log = _appendLog(SyncLogEntry(
        timestamp: result.serverTime,
        success: true,
        pushed: preSyncPending,
        rejected: result.rejectedCount,
      ));
      state = SyncState(
        pendingCount: count,
        lastSyncedAt: result.serverTime,
        warningMessage: _syncWarningMessage(result),
        rejectedChanges: result.rejectedChanges,
        syncLog: log,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Collectarr personal sync failed',
        name: 'collectarr.sync',
        error: error,
        stackTrace: stackTrace,
      );
      final count = await _queue().pendingCount();
      final log = _appendLog(SyncLogEntry(
        timestamp: DateTime.now().toUtc(),
        success: false,
        pushed: preSyncPending,
        errorMessage: error.toString(),
      ));
      state = SyncState(
        pendingCount: count,
        isOffline: true,
        lastSyncedAt: state.lastSyncedAt,
        errorMessage: error.toString(),
        rejectedChanges: state.rejectedChanges,
        syncLog: log,
      );
    }
  }

  void dismissRejectedChange(String key) {
    final rejectedChanges = state.rejectedChanges
        .where((change) => change.key != key)
        .toList(growable: false);
    state = state.copyWith(
      rejectedChanges: rejectedChanges,
      warningMessage: SyncWarningFormatter.rejectedChanges(rejectedChanges),
      clearWarning: rejectedChanges.isEmpty,
    );
  }

  void dismissAllRejectedChanges() {
    state = state.copyWith(
      rejectedChanges: const [],
      clearRejectedChanges: true,
      clearWarning: true,
    );
  }

  Future<bool> keepLocalRejectedChange(SyncRejectedChange change) async {
    final db = ref.read(localDatabaseProvider);
    final queued = await _queue().enqueueLocalRetry(
      change,
      db: db,
      changedAt: DateTime.now().toUtc(),
      uuid: const Uuid(),
    );
    if (!queued) {
      return false;
    }
    dismissRejectedChange(change.key);
    await refreshPendingCount();
    return true;
  }

  String? _syncWarningMessage(SyncResult result) {
    return SyncWarningFormatter.rejectedChanges(result.rejectedChanges);
  }

  SyncQueueRepository _queue() {
    return SyncQueueRepository(ref.read(localDatabaseProvider));
  }

  List<SyncLogEntry> _appendLog(SyncLogEntry entry) {
    final log = [...state.syncLog, entry];
    if (log.length > _maxLogEntries) {
      return log.sublist(log.length - _maxLogEntries);
    }
    return log;
  }

  Future<DateTime?> _readLastSyncedAt() async {
    try {
      return await SyncCursorStore().read();
    } catch (error, stackTrace) {
      developer.log(
        'Collectarr sync cursor read failed',
        name: 'collectarr.sync',
        error: error,
        stackTrace: stackTrace,
      );
      return state.lastSyncedAt;
    }
  }
}

extension on SyncQueueRepository {
  Future<bool> enqueueLocalRetry(
    SyncRejectedChange change, {
    required LocalDatabase db,
    required DateTime changedAt,
    required Uuid uuid,
  }) async {
    final syncChange = await _localRetryChange(
      change,
      db: db,
      changedAt: changedAt,
      uuid: uuid,
    );
    if (syncChange == null) {
      return false;
    }
    await enqueue(syncChange);
    return true;
  }

  Future<SyncChange?> _localRetryChange(
    SyncRejectedChange change, {
    required LocalDatabase db,
    required DateTime changedAt,
    required Uuid uuid,
  }) async {
    switch (change.entityType) {
      case 'owned_item':
        final item = await OwnedItemsCacheRepository(db).findById(
          change.entityId,
        );
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: item.isDeleted ? 'delete' : 'upsert',
          payload: item.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      case 'wishlist_item':
        final item = await WishlistItemsCacheRepository(db).findById(
          change.entityId,
        );
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: item.isDeleted ? 'delete' : 'upsert',
          payload: item.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      case 'library_item_snapshot':
        final item = await CatalogCacheRepository(db).findById(change.entityId);
        if (item == null) {
          return null;
        }
        return SyncChange(
          id: uuid.v4(),
          entityType: change.entityType,
          entityId: item.id,
          action: 'upsert',
          payload: item.toSyncPayload(),
          clientChangedAt: changedAt,
        );
      default:
        return null;
    }
  }
}
