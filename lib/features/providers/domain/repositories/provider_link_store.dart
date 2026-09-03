import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ProviderLinkStore {
  Future<List<ProviderItemLink>> getAllLinks();
  Future<ProviderItemLink?> getLinkByRemoteId(
      String accountId, String remoteItemId);
  Future<ProviderItemLink?> getLinkByLocalRef(CatalogEntityRef localRef,
      {ProviderId? provider});
  Future<void> saveLink(ProviderItemLink link);
  Future<void> deleteLink(String accountId, String remoteItemId);
  Future<void> updateBaseSnapshot({
    required String accountId,
    required String remoteItemId,
    required ProviderPersonalEntry baseSnapshot,
    DateTime? pulledAt,
    DateTime? pushedAt,
    String? revision,
  });
}

class InMemoryProviderLinkStore implements ProviderLinkStore {
  InMemoryProviderLinkStore([Map<String, ProviderItemLink>? initialLinks])
      : _links = initialLinks ?? {};

  final Map<String, ProviderItemLink> _links;

  String _key(String accountId, String remoteItemId) =>
      '$accountId:$remoteItemId';

  @override
  Future<List<ProviderItemLink>> getAllLinks() async {
    return _links.values.toList();
  }

  @override
  Future<ProviderItemLink?> getLinkByRemoteId(
      String accountId, String remoteItemId) async {
    return _links[_key(accountId, remoteItemId)];
  }

  @override
  Future<ProviderItemLink?> getLinkByLocalRef(CatalogEntityRef localRef,
      {ProviderId? provider}) async {
    for (final link in _links.values) {
      if (link.localEntityRef.id == localRef.id &&
          link.localEntityRef.kind == localRef.kind) {
        if (provider == null || link.provider == provider) {
          return link;
        }
      }
    }
    return null;
  }

  @override
  Future<void> saveLink(ProviderItemLink link) async {
    _links[_key(link.accountId, link.remoteItemId)] = link;
  }

  @override
  Future<void> deleteLink(String accountId, String remoteItemId) async {
    _links.remove(_key(accountId, remoteItemId));
  }

  @override
  Future<void> updateBaseSnapshot({
    required String accountId,
    required String remoteItemId,
    required ProviderPersonalEntry baseSnapshot,
    DateTime? pulledAt,
    DateTime? pushedAt,
    String? revision,
  }) async {
    final existing = _links[_key(accountId, remoteItemId)];
    if (existing == null) return;
    _links[_key(accountId, remoteItemId)] = existing.copyWith(
      baseSnapshot: baseSnapshot,
      lastPulledAt: pulledAt ?? existing.lastPulledAt,
      lastPushedAt: pushedAt ?? existing.lastPushedAt,
      remoteRevision: revision ?? existing.remoteRevision,
    );
  }
}

final providerLinkStoreProvider = Provider<ProviderLinkStore>((ref) {
  return DriftProviderLinkStore(ref.watch(localDatabaseProvider));
});

class DriftProviderLinkStore implements ProviderLinkStore {
  const DriftProviderLinkStore(this.database);

  final LocalDatabase database;

  @override
  Future<List<ProviderItemLink>> getAllLinks() async {
    final rows = await database.select(database.providerItemLinksCache).get();
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<ProviderItemLink?> getLinkByRemoteId(
    String accountId,
    String remoteItemId,
  ) async {
    final row = await (database.select(database.providerItemLinksCache)
          ..where(
            (link) =>
                link.accountId.equals(accountId) &
                link.remoteItemId.equals(remoteItemId),
          )
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<ProviderItemLink?> getLinkByLocalRef(
    CatalogEntityRef localRef, {
    ProviderId? provider,
  }) async {
    final links = await getAllLinks();
    for (final link in links) {
      if (link.localEntityRef.id == localRef.id &&
          link.localEntityRef.kind == localRef.kind &&
          (provider == null || link.provider == provider)) {
        return link;
      }
    }
    return null;
  }

  @override
  Future<void> saveLink(ProviderItemLink link) async {
    await database.into(database.providerItemLinksCache).insert(
          _toCompanion(link),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> deleteLink(String accountId, String remoteItemId) async {
    await (database.delete(database.providerItemLinksCache)
          ..where(
            (link) =>
                link.accountId.equals(accountId) &
                link.remoteItemId.equals(remoteItemId),
          ))
        .go();
  }

  @override
  Future<void> updateBaseSnapshot({
    required String accountId,
    required String remoteItemId,
    required ProviderPersonalEntry baseSnapshot,
    DateTime? pulledAt,
    DateTime? pushedAt,
    String? revision,
  }) async {
    final existing = await getLinkByRemoteId(accountId, remoteItemId);
    if (existing == null) return;
    await saveLink(
      existing.copyWith(
        baseSnapshot: baseSnapshot,
        lastPulledAt: pulledAt ?? existing.lastPulledAt,
        lastPushedAt: pushedAt ?? existing.lastPushedAt,
        remoteRevision: revision ?? existing.remoteRevision,
      ),
    );
  }

  ProviderItemLink _fromRow(ProviderItemLinksCacheData row) {
    final localRef =
        CatalogEntityRef.fromJson(_decodeMap(row.localEntityRefJson));
    final baseSnapshotJson = _decodeOptionalMap(row.baseSnapshotJson);
    return ProviderItemLink(
      accountId: row.accountId,
      provider: ProviderId.fromValue(row.provider) ?? ProviderId.aniList,
      remoteItemId: row.remoteItemId,
      remoteEntryId: row.remoteEntryId,
      localEntityRef: localRef,
      baseSnapshot: baseSnapshotJson == null
          ? null
          : ProviderPersonalEntry.fromJson(baseSnapshotJson),
      lastPulledAt: row.lastPulledAt,
      lastPushedAt: row.lastPushedAt,
      remoteRevision: row.remoteRevision,
      metadata: _decodeMap(row.metadataJson),
    );
  }

  ProviderItemLinksCacheCompanion _toCompanion(ProviderItemLink link) {
    return ProviderItemLinksCacheCompanion.insert(
      accountId: link.accountId,
      provider: link.provider.value,
      remoteItemId: link.remoteItemId,
      remoteEntryId: Value(link.remoteEntryId),
      localEntityRefJson: jsonEncode(link.localEntityRef.toJson()),
      baseSnapshotJson: Value(
        link.baseSnapshot == null
            ? null
            : jsonEncode(link.baseSnapshot!.toJson()),
      ),
      lastPulledAt: Value(link.lastPulledAt),
      lastPushedAt: Value(link.lastPushedAt),
      remoteRevision: Value(link.remoteRevision),
      metadataJson: jsonEncode(link.metadata),
    );
  }

  Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeOptionalMap(raw);
    return decoded ?? const {};
  }

  Map<String, dynamic>? _decodeOptionalMap(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }
}
