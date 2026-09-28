import 'dart:async';
import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/data/owned_copy_v1_repository.dart';
import 'package:collectarr_app/features/library/data/catalog_item_wishlist_v1_repository.dart';
import 'package:collectarr_app/features/library/domain/catalog_item_wishlist_v1.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:flutter/foundation.dart';

/// A workspace row groups one Catalog Item with its individually owned copies.
/// Missing remote catalog data does not discard local ownership records.
@immutable
final class CatalogItemV1WorkspaceItem {
  CatalogItemV1WorkspaceItem({
    required this.reference,
    required Iterable<OwnedCopyV1> copies,
    this.wishlist,
    this.catalogItem,
    this.catalogError,
  }) : copies = List.unmodifiable(copies) {
    if (this.copies.isEmpty && wishlist == null) {
      throw ArgumentError(
          'A Catalog Item row needs an owned copy or wishlist entry.');
    }
    if (this.copies.any((copy) => copy.catalogItem != reference)) {
      throw ArgumentError(
          'Every copy must reference the workspace Catalog Item.');
    }
    if (wishlist != null && wishlist!.catalogItem != reference) {
      throw ArgumentError('Wishlist entry must reference the Catalog Item.');
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
  final CatalogItemWishlistV1? wishlist;

  String get title => catalogItem?.title ?? 'Catalog Item ${reference.id}';
  int get copyCount => copies.length;
}

/// Reads the new top-level workspace model without manufacturing Work or
/// Release nodes for kinds that have neither concept.
final class CatalogItemV1WorkspaceRepository {
  CatalogItemV1WorkspaceRepository({
    required ApiClient api,
    required OwnedCopyV1Repository ownedCopies,
    required CatalogItemWishlistV1Repository wishlists,
  })  : _api = api,
        _ownedCopies = ownedCopies,
        _wishlists = wishlists;

  final ApiClient _api;
  final OwnedCopyV1Repository _ownedCopies;
  final CatalogItemWishlistV1Repository _wishlists;
  final Map<CatalogItemRef, CatalogItemV1Dto> _catalogCache = {};
  final Map<CatalogItemRef, Future<CatalogItemV1Dto>> _catalogRequests = {};

  void remember(CatalogItemV1Dto item) {
    _catalogCache[item.reference] = item;
  }

  void clearCatalogCache() {
    _catalogCache.clear();
  }

  Future<List<CatalogItemV1WorkspaceItem>> load(
    CatalogMediaKind kind, {
    bool includeWishlistOnly = false,
  }) async {
    final copies = await _ownedCopies.listForKind(kind);
    final wishlists = await _wishlists.listForKind(kind);
    return _loadCatalogItems(
      copies,
      wishlists,
      includeWishlistOnly: includeWishlistOnly,
    );
  }

  Stream<List<CatalogItemV1WorkspaceItem>> watch(CatalogMediaKind kind) {
    late final StreamController<List<CatalogItemV1WorkspaceItem>> controller;
    StreamSubscription<List<OwnedCopyV1>>? copiesSubscription;
    StreamSubscription<List<CatalogItemWishlistV1>>? wishlistSubscription;

    Future<void> refresh() async {
      try {
        controller.add(await load(kind));
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<List<CatalogItemV1WorkspaceItem>>(
      onListen: () {
        copiesSubscription = _ownedCopies.watchForKind(kind).listen((_) {
          unawaited(refresh());
        }, onError: controller.addError);
        wishlistSubscription = _wishlists.watchForKind(kind).listen((_) {
          unawaited(refresh());
        }, onError: controller.addError);
      },
      onCancel: () async {
        await copiesSubscription?.cancel();
        await wishlistSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  Future<List<CatalogItemV1WorkspaceItem>> _loadCatalogItems(
    List<OwnedCopyV1> copies,
    List<CatalogItemWishlistV1> wishlists, {
    bool includeWishlistOnly = false,
  }) async {
    final copiesByItem = <CatalogItemRef, List<OwnedCopyV1>>{};
    for (final copy in copies) {
      copiesByItem.putIfAbsent(copy.catalogItem, () => []).add(copy);
    }
    final wishlistsByItem = <CatalogItemRef, CatalogItemWishlistV1>{
      for (final entry in wishlists) entry.catalogItem: entry,
    };
    final references = <CatalogItemRef>{
      ...copiesByItem.keys,
      if (includeWishlistOnly) ...wishlistsByItem.keys,
    };
    final entries = references.toList(growable: false);
    final rows = <CatalogItemV1WorkspaceItem>[];
    const concurrency = 8;
    for (var start = 0; start < entries.length; start += concurrency) {
      final nextStart = start + concurrency;
      final end = nextStart < entries.length ? nextStart : entries.length;
      rows.addAll(
        await Future.wait(
          entries.sublist(start, end).map((reference) => _loadCatalogItem(
                reference,
                copiesByItem[reference] ?? const [],
                wishlistsByItem[reference],
              )),
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
    CatalogItemWishlistV1? wishlist,
  ) async {
    try {
      final item =
          _catalogCache[reference] ?? await _requestCatalogItem(reference);
      return CatalogItemV1WorkspaceItem(
        reference: reference,
        catalogItem: item,
        copies: copies,
        wishlist: wishlist,
      );
    } on Exception catch (error) {
      return CatalogItemV1WorkspaceItem(
        reference: reference,
        catalogError: error,
        copies: copies,
        wishlist: wishlist,
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
