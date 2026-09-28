import 'dart:async';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/data/owned_copy_v1_repository.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:flutter/foundation.dart';

/// A workspace row groups one Catalog Item with its individually owned copies.
/// Missing remote catalog data does not discard local ownership records.
@immutable
final class CatalogItemV1WorkspaceItem {
  CatalogItemV1WorkspaceItem({
    required this.reference,
    required Iterable<OwnedCopyV1> copies,
    this.catalogItem,
    this.catalogError,
  }) : copies = List.unmodifiable(copies) {
    if (this.copies.isEmpty) {
      throw ArgumentError('A Catalog Item workspace row needs an owned copy.');
    }
    if (this.copies.any((copy) => copy.catalogItem != reference)) {
      throw ArgumentError(
          'Every copy must reference the workspace Catalog Item.');
    }
    if (catalogItem != null && catalogItem!.reference != reference) {
      throw ArgumentError('Catalog Item response identity does not match row.');
    }
    if (catalogItem != null && catalogError != null) {
      throw ArgumentError(
          'A row cannot have both catalog data and a load error.');
    }
  }

  final CatalogItemRef reference;
  final CatalogItemV1Dto? catalogItem;
  final Object? catalogError;
  final List<OwnedCopyV1> copies;

  String get title => catalogItem?.title ?? 'Catalog Item ${reference.id}';
  int get copyCount => copies.length;
}

/// Reads the new top-level workspace model without manufacturing Work or
/// Release nodes for kinds that have neither concept.
final class CatalogItemV1WorkspaceRepository {
  CatalogItemV1WorkspaceRepository({
    required ApiClient api,
    required OwnedCopyV1Repository ownedCopies,
  })  : _api = api,
        _ownedCopies = ownedCopies;

  final ApiClient _api;
  final OwnedCopyV1Repository _ownedCopies;
  final Map<CatalogItemRef, CatalogItemV1Dto> _catalogCache = {};
  final Map<CatalogItemRef, Future<CatalogItemV1Dto>> _catalogRequests = {};

  void remember(CatalogItemV1Dto item) {
    _catalogCache[item.reference] = item;
  }

  void clearCatalogCache() {
    _catalogCache.clear();
  }

  Future<List<CatalogItemV1WorkspaceItem>> load(CatalogMediaKind kind) async {
    final copies = await _ownedCopies.listForKind(kind);
    return _loadCatalogItems(copies);
  }

  Stream<List<CatalogItemV1WorkspaceItem>> watch(CatalogMediaKind kind) =>
      _ownedCopies.watchForKind(kind).asyncMap(_loadCatalogItems);

  Future<List<CatalogItemV1WorkspaceItem>> _loadCatalogItems(
    List<OwnedCopyV1> copies,
  ) async {
    final copiesByItem = <CatalogItemRef, List<OwnedCopyV1>>{};
    for (final copy in copies) {
      copiesByItem.putIfAbsent(copy.catalogItem, () => []).add(copy);
    }
    final entries = copiesByItem.entries.toList(growable: false);
    final rows = <CatalogItemV1WorkspaceItem>[];
    const concurrency = 8;
    for (var start = 0; start < entries.length; start += concurrency) {
      final nextStart = start + concurrency;
      final end = nextStart < entries.length ? nextStart : entries.length;
      rows.addAll(
        await Future.wait(
          entries
              .sublist(start, end)
              .map((entry) => _loadCatalogItem(entry.key, entry.value)),
        ),
      );
    }
    rows.sort((left, right) =>
        left.title.toLowerCase().compareTo(right.title.toLowerCase()));
    return List.unmodifiable(rows);
  }

  Future<CatalogItemV1WorkspaceItem> _loadCatalogItem(
    CatalogItemRef reference,
    List<OwnedCopyV1> copies,
  ) async {
    try {
      final item =
          _catalogCache[reference] ?? await _requestCatalogItem(reference);
      return CatalogItemV1WorkspaceItem(
        reference: reference,
        catalogItem: item,
        copies: copies,
      );
    } on Exception catch (error) {
      return CatalogItemV1WorkspaceItem(
        reference: reference,
        catalogError: error,
        copies: copies,
      );
    }
  }

  Future<CatalogItemV1Dto> _requestCatalogItem(
    CatalogItemRef reference,
  ) async {
    final pending = _catalogRequests.putIfAbsent(reference, () {
      return _api.getCatalogItem(reference).then((item) {
        remember(item);
        return item;
      });
    });
    try {
      return await pending;
    } finally {
      if (identical(_catalogRequests[reference], pending)) {
        final removed = _catalogRequests.remove(reference);
        assert(identical(removed, pending));
      }
    }
  }
}
