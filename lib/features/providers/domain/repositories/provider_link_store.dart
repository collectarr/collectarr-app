import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_item_link.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
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
  return InMemoryProviderLinkStore();
});
