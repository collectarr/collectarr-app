/// The sync orchestration logic that was previously in this file has been moved
/// to [features/sync/data/sync_apply_service.dart] as [SyncApplyService].
///
/// [SyncResult] and [SyncRejectedChange] now live in
/// [core/sync/sync_change.dart] alongside [SyncChange].
///
/// This file is kept only to avoid breaking imports that have not yet been
/// updated. Delete once all consumers are migrated.
export 'package:collectarr_app/core/sync/sync_change.dart'
    show SyncResult, SyncRejectedChange;
