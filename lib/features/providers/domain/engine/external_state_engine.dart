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
  });

  final ProviderPersonalEntry remoteEntry;
  final CatalogEntityRef? localEntityRef;
  final ProviderItemLink? link;
  final List<FieldDiff<dynamic>> diffs;

  bool get hasConflicts => diffs.any((d) => d.hasConflict);
  bool get isMatched => localEntityRef != null;
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
  }) {
    final diffs = <FieldDiff<dynamic>>[];

    // Status
    if (policy.status != SyncDirection.disabled) {
      diffs.add(_computeDiff<ProviderEntryStatus>(
        field: SyncField.status,
        base: base?.status,
        local: local?.status,
        remote: remote.status,
      ));
    }

    // Rating
    if (policy.rating != SyncDirection.disabled) {
      diffs.add(_computeDiff<double>(
        field: SyncField.rating,
        base: base?.rating,
        local: local?.rating,
        remote: remote.rating,
      ));
    }

    // Progress
    if (policy.progress != SyncDirection.disabled) {
      diffs.add(_computeDiff<int>(
        field: SyncField.progress,
        base: base?.progress,
        local: local?.progress,
        remote: remote.progress,
      ));
    }

    return EntrySyncDiff(
      remoteEntry: remote,
      localEntityRef: localRef,
      link: link,
      diffs: diffs,
    );
  }

  FieldDiff<T> _computeDiff<T>({
    required SyncField field,
    required T? base,
    required T? local,
    required T? remote,
  }) {
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
