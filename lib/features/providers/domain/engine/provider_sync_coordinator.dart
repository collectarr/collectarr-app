import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/providers/domain/contracts/provider_registry.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_account.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';

class SyncPullResult {
  const SyncPullResult({
    required this.accountId,
    required this.provider,
    required this.pulledCount,
    required this.appliedCount,
    required this.conflictCount,
    this.conflicts = const [],
  });

  final String accountId;
  final ProviderId provider;
  final int pulledCount;
  final int appliedCount;
  final int conflictCount;
  final List<EntrySyncDiff> conflicts;
}

class ProviderSyncCoordinator {
  ProviderSyncCoordinator({
    required this.engine,
    required this.registry,
    required this.accountStore,
    required this.linkStore,
    this.localStateReader,
    this.localStateApplier,
  });

  final ExternalStateEngine engine;
  final ProviderConnectorRegistry registry;
  final ProviderAccountStore accountStore;
  final ProviderLinkStore linkStore;
  final Future<ProviderPersonalEntry?> Function(CatalogEntityRef localRef)?
      localStateReader;
  final Future<void> Function(
    CatalogEntityRef localRef,
    ProviderPersonalEntry remoteEntry,
    MutationOrigin origin,
  )? localStateApplier;

  /// Pulls remote changes for an account and executes 3-way diff (BASE, LOCAL, REMOTE).
  Future<SyncPullResult> pullAccount({
    required String accountId,
    CatalogMediaKind? kind,
  }) async {
    final account = await accountStore.getAccount(accountId);
    if (account == null) {
      throw StateError('Provider account $accountId not found');
    }

    final connector = registry.get(account.provider);
    final personalRead = connector?.personalRead;
    if (personalRead == null) {
      throw StateError(
          'Provider ${account.provider} does not support reading personal lists');
    }

    final context = await accountStore.getAccountContext(accountId);
    final policy = context?.syncPolicy ?? const ProviderSyncPolicy();
    final remoteEntries = await personalRead.readPersonalList(
      accountId: account.remoteAccountId ?? account.remoteHandle ?? account.id,
      kind: kind,
      context: context,
    );

    int applied = 0;
    final conflicts = <EntrySyncDiff>[];

    for (final remoteEntry in remoteEntries) {
      final link = await linkStore.getLinkByRemoteId(
          accountId, remoteEntry.remoteItemId);
      final localRef = link?.localEntityRef;

      ProviderPersonalEntry? localEntry;
      if (localRef != null && localStateReader != null) {
        localEntry = await localStateReader!(localRef);
      }

      final diff = engine.diffEntry(
        remote: remoteEntry,
        base: link?.baseSnapshot,
        local: localEntry,
        policy: policy,
        mode: SyncEngineMode.pullSync,
      );

      if (diff.hasConflicts) {
        conflicts.add(diff);
      } else if (diff.hasChanges) {
        if (localRef != null && localStateApplier != null) {
          final origin = MutationOrigin(
            source: MutationSourceType.externalProvider,
            provider: account.provider,
            accountId: accountId,
            timestamp: DateTime.now().toUtc(),
          );
          await localStateApplier!(
            localRef,
            _mergePullEntry(remoteEntry, localEntry, policy),
            origin,
          );
          applied++;
        }
      }

      // Update link snapshot with remote entry as new base
      if (link != null) {
        await linkStore.updateBaseSnapshot(
          accountId: accountId,
          remoteItemId: remoteEntry.remoteItemId,
          baseSnapshot: remoteEntry,
          pulledAt: DateTime.now().toUtc(),
          revision: remoteEntry.remoteRevision,
        );
      }
    }

    // Update account last sync time
    await accountStore.saveAccount(
      ProviderAccount(
        id: account.id,
        provider: account.provider,
        displayName: account.displayName,
        authType: account.authType,
        remoteAccountId: account.remoteAccountId,
        remoteHandle: account.remoteHandle,
        avatarUrl: account.avatarUrl,
        connectedAt: account.connectedAt,
        lastSyncAt: DateTime.now().toUtc(),
        enabledCapabilities: account.enabledCapabilities,
        syncPolicy: account.syncPolicy,
      ),
    );

    return SyncPullResult(
      accountId: accountId,
      provider: account.provider,
      pulledCount: remoteEntries.length,
      appliedCount: applied,
      conflictCount: conflicts.length,
      conflicts: conflicts,
    );
  }

  /// Pushes a local mutation to the external provider if echo prevention allows it.
  Future<bool> handleLocalMutation({
    required CatalogEntityRef localRef,
    required ProviderPersonalEntry localEntry,
    required MutationOrigin origin,
  }) async {
    final link = await linkStore.getLinkByLocalRef(localRef);
    if (link == null) {
      return false; // No linked external item
    }

    // Echo loop prevention: do not push back to the origin that triggered this mutation!
    if (!origin.shouldPushTo(link.provider)) {
      return false;
    }

    final connector = registry.get(link.provider);
    final personalWrite = connector?.personalWrite;
    if (personalWrite == null) {
      return false;
    }

    final context = await accountStore.getAccountContext(link.accountId);
    final policy = context?.syncPolicy ?? const ProviderSyncPolicy();
    if (!_hasPushableFields(policy)) {
      return false;
    }
    final entryToWrite = _mergePushEntry(localEntry, link.baseSnapshot, policy);
    await personalWrite.writePersonalEntry(
      accountId: link.accountId,
      entry: entryToWrite,
      context: context,
    );

    // Update base snapshot with the newly pushed state
    await linkStore.updateBaseSnapshot(
      accountId: link.accountId,
      remoteItemId: link.remoteItemId,
      baseSnapshot: entryToWrite,
      pushedAt: DateTime.now().toUtc(),
    );

    return true;
  }

  /// Establishes an item link after an import or manual link.
  Future<ProviderItemLink> linkImportedItem({
    required String accountId,
    required ProviderId provider,
    required CatalogEntityRef localRef,
    required ProviderPersonalEntry entry,
  }) async {
    final link = ProviderItemLink(
      accountId: accountId,
      provider: provider,
      remoteItemId: entry.remoteItemId,
      remoteEntryId: entry.remoteEntryId,
      localEntityRef: localRef,
      baseSnapshot: entry,
      lastPulledAt: DateTime.now().toUtc(),
      remoteRevision: entry.remoteRevision,
    );

    await linkStore.saveLink(link);
    return link;
  }

  bool _hasPushableFields(ProviderSyncPolicy policy) {
    return policy.allowsPush(SyncField.status) ||
        policy.allowsPush(SyncField.rating) ||
        policy.allowsPush(SyncField.progress) ||
        policy.allowsPush(SyncField.history);
  }

  ProviderPersonalEntry _mergePullEntry(
    ProviderPersonalEntry remote,
    ProviderPersonalEntry? local,
    ProviderSyncPolicy policy,
  ) {
    return ProviderPersonalEntry(
      provider: remote.provider,
      remoteItemId: remote.remoteItemId,
      remoteEntryId: remote.remoteEntryId,
      kind: remote.kind,
      title: remote.title,
      externalIds: remote.externalIds,
      status: policy.allowsPull(SyncField.status)
          ? remote.status
          : local?.status,
      rating: policy.allowsPull(SyncField.rating)
          ? remote.rating
          : local?.rating,
      progress: policy.allowsPull(SyncField.progress)
          ? remote.progress
          : local?.progress,
      totalProgress: policy.allowsPull(SyncField.progress)
          ? remote.totalProgress
          : local?.totalProgress,
      startedAt: policy.allowsPull(SyncField.history)
          ? remote.startedAt
          : local?.startedAt,
      completedAt: policy.allowsPull(SyncField.history)
          ? remote.completedAt
          : local?.completedAt,
      repeatCount: policy.allowsPull(SyncField.history)
          ? remote.repeatCount
          : local?.repeatCount ?? 0,
      remoteUpdatedAt: remote.remoteUpdatedAt,
      remoteRevision: remote.remoteRevision,
      notes: policy.allowsPull(SyncField.history)
          ? remote.notes
          : local?.notes,
      rawPayload: remote.rawPayload,
    );
  }

  ProviderPersonalEntry _mergePushEntry(
    ProviderPersonalEntry local,
    ProviderPersonalEntry? base,
    ProviderSyncPolicy policy,
  ) {
    return ProviderPersonalEntry(
      provider: local.provider,
      remoteItemId: local.remoteItemId,
      remoteEntryId: local.remoteEntryId,
      kind: local.kind,
      title: local.title,
      externalIds: local.externalIds,
      status: policy.allowsPush(SyncField.status)
          ? local.status
          : base?.status,
      rating: policy.allowsPush(SyncField.rating)
          ? local.rating
          : base?.rating,
      progress: policy.allowsPush(SyncField.progress)
          ? local.progress
          : base?.progress,
      totalProgress: policy.allowsPush(SyncField.progress)
          ? local.totalProgress
          : base?.totalProgress,
      startedAt: policy.allowsPush(SyncField.history)
          ? local.startedAt
          : base?.startedAt,
      completedAt: policy.allowsPush(SyncField.history)
          ? local.completedAt
          : base?.completedAt,
      repeatCount: policy.allowsPush(SyncField.history)
          ? local.repeatCount
          : base?.repeatCount ?? 0,
      remoteUpdatedAt: local.remoteUpdatedAt,
      remoteRevision: local.remoteRevision,
      notes: policy.allowsPush(SyncField.history)
          ? local.notes
          : base?.notes,
      rawPayload: local.rawPayload,
    );
  }
}
