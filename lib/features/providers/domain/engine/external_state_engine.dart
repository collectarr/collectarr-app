import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/models/sync_policy.dart';
import 'package:flutter/foundation.dart';

enum SyncEngineMode {
  oneShotImport,
  pullSync,
  bidirectionalSync,
}

enum FieldDiffState {
  unchanged,
  localChanged,
  remoteChanged,
  conflictBothChanged,
}

@immutable
final class FieldDiff<T> {
  const FieldDiff({
    required this.field,
    required this.baseValue,
    required this.localValue,
    required this.remoteValue,
    required this.state,
    this.resolvedValue,
  });

  final SyncField field;
  final T? baseValue;
  final T? localValue;
  final T? remoteValue;
  final FieldDiffState state;
  final T? resolvedValue;

  bool get hasConflict => state == FieldDiffState.conflictBothChanged;
}

@immutable
final class EntrySyncDiff {
  const EntrySyncDiff({
    required this.remoteEntry,
    this.localEntityRef,
    this.link,
    this.diffs = const [],
    this.mode = SyncEngineMode.pullSync,
  });

  final ProviderPersonalEntry remoteEntry;
  final CatalogEntityRef? localEntityRef;
  final ProviderItemLink? link;
  final List<FieldDiff<dynamic>> diffs;
  final SyncEngineMode mode;

  bool get hasConflicts => diffs.any((d) => d.hasConflict);
  bool get isMatched => localEntityRef != null;
  bool get hasChanges => diffs.any((d) => d.state != FieldDiffState.unchanged);
}

class ExternalStateEngine {
  const ExternalStateEngine();

  EntrySyncDiff diffEntry({
    required ProviderPersonalEntry remote,
    required ProviderPersonalEntry? base,
    required ProviderPersonalEntry? local,
    CatalogEntityRef? localRef,
    ProviderItemLink? link,
    ProviderSyncPolicy policy = const ProviderSyncPolicy(),
    SyncEngineMode mode = SyncEngineMode.pullSync,
  }) {
    final diffs = <FieldDiff<dynamic>>[];

    // Status
    if (policy.allowsPull(SyncField.status)) {
      diffs.add(_computeDiff<ProviderEntryStatus>(
        field: SyncField.status,
        base: base?.status,
        local: local?.status,
        remote: remote.status,
        mode: mode,
      ));
    }

    // Rating
    if (policy.allowsPull(SyncField.rating)) {
      diffs.add(_computeDiff<double>(
        field: SyncField.rating,
        base: base?.rating,
        local: local?.rating,
        remote: remote.rating,
        mode: mode,
      ));
    }

    // Progress
    if (policy.allowsPull(SyncField.progress)) {
      diffs.add(_computeDiff<int>(
        field: SyncField.progress,
        base: base?.progress,
        local: local?.progress,
        remote: remote.progress,
        mode: mode,
      ));
    }

    return EntrySyncDiff(
      remoteEntry: remote,
      localEntityRef: localRef,
      link: link,
      diffs: diffs,
      mode: mode,
    );
  }

  FieldDiff<T> _computeDiff<T>({
    required SyncField field,
    required T? base,
    required T? local,
    required T? remote,
    required SyncEngineMode mode,
  }) {
    if (mode == SyncEngineMode.oneShotImport) {
      if (local == null) {
        return FieldDiff<T>(
          field: field,
          baseValue: base,
          localValue: local,
          remoteValue: remote,
          state: FieldDiffState.remoteChanged,
          resolvedValue: remote,
        );
      }
      if (local == remote) {
        return FieldDiff<T>(
          field: field,
          baseValue: base,
          localValue: local,
          remoteValue: remote,
          state: FieldDiffState.unchanged,
          resolvedValue: local,
        );
      }
      return FieldDiff<T>(
        field: field,
        baseValue: base,
        localValue: local,
        remoteValue: remote,
        state: FieldDiffState.conflictBothChanged,
        resolvedValue: null,
      );
    }

    final localChanged = local != base;
    final remoteChanged = remote != base;

    if (!localChanged && !remoteChanged) {
      return FieldDiff<T>(
        field: field,
        baseValue: base,
        localValue: local,
        remoteValue: remote,
        state: FieldDiffState.unchanged,
        resolvedValue: local ?? remote,
      );
    }

    if (localChanged && !remoteChanged) {
      return FieldDiff<T>(
        field: field,
        baseValue: base,
        localValue: local,
        remoteValue: remote,
        state: FieldDiffState.localChanged,
        resolvedValue: local,
      );
    }

    if (!localChanged && remoteChanged) {
      return FieldDiff<T>(
        field: field,
        baseValue: base,
        localValue: local,
        remoteValue: remote,
        state: FieldDiffState.remoteChanged,
        resolvedValue: remote,
      );
    }

    // Both changed
    if (local == remote) {
      return FieldDiff<T>(
        field: field,
        baseValue: base,
        localValue: local,
        remoteValue: remote,
        state: FieldDiffState.unchanged,
        resolvedValue: local,
      );
    }

    return FieldDiff<T>(
      field: field,
      baseValue: base,
      localValue: local,
      remoteValue: remote,
      state: FieldDiffState.conflictBothChanged,
      resolvedValue: null,
    );
  }
}
