import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/services/library_catalog_item_v1_add_service.dart';
import 'package:collectarr_app/features/library/csv/catalog_item_v1_csv_importer.dart';
import 'package:collectarr_app/features/library/data/catalog_item_v1_workspace_repository.dart';
import 'package:collectarr_app/features/library/data/catalog_item_wishlist_v1_repository.dart';
import 'package:collectarr_app/features/library/data/owned_copy_v1_repository.dart';
import 'package:collectarr_app/features/library/domain/owned_copy_v1.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ownedCopyV1RepositoryProvider = Provider<OwnedCopyV1Repository>((ref) {
  return OwnedCopyV1Repository(ref.watch(localDatabaseProvider));
});

final catalogItemWishlistV1RepositoryProvider =
    Provider<CatalogItemWishlistV1Repository>((ref) {
  return CatalogItemWishlistV1Repository(ref.watch(localDatabaseProvider));
});

final catalogItemV1CsvImporterProvider =
    Provider<CatalogItemV1CsvImporter>((ref) {
  return CatalogItemV1CsvImporter(
    api: ref.watch(apiClientProvider),
    ownedCopies: ref.watch(ownedCopyV1RepositoryProvider),
  );
});

final libraryCatalogItemV1AddServiceProvider =
    Provider<LibraryCatalogItemV1AddService>((ref) {
  return LibraryCatalogItemV1AddService(
    api: ref.watch(apiClientProvider),
    ownedCopies: ref.watch(ownedCopyV1RepositoryProvider),
  );
});

final catalogItemV1WorkspaceRepositoryProvider =
    Provider<CatalogItemV1WorkspaceRepository>((ref) {
  return CatalogItemV1WorkspaceRepository(
    api: ref.watch(apiClientProvider),
    ownedCopies: ref.watch(ownedCopyV1RepositoryProvider),
    wishlists: ref.watch(catalogItemWishlistV1RepositoryProvider),
  );
});

final ownedCopiesV1ByKindProvider = StreamProvider.autoDispose
    .family<List<OwnedCopyV1>, CatalogMediaKind>((ref, kind) {
  if (kind.isUnknown) {
    throw ArgumentError.value(
        kind, 'kind', 'A known library kind is required.');
  }
  return ref.watch(ownedCopyV1RepositoryProvider).watchForKind(kind);
});

final catalogItemV1WorkspaceByKindProvider = StreamProvider.autoDispose
    .family<List<CatalogItemV1WorkspaceItem>, CatalogMediaKind>((ref, kind) {
  if (kind.isUnknown) {
    throw ArgumentError.value(
        kind, 'kind', 'A known library kind is required.');
  }
  return ref.watch(catalogItemV1WorkspaceRepositoryProvider).watch(kind);
});

/// Cross-kind Owned Copy view used by the collection shelf.
final catalogItemV1AllWorkspacesProvider =
    FutureProvider.autoDispose<List<CatalogItemV1WorkspaceItem>>((ref) async {
  final repository = ref.watch(catalogItemV1WorkspaceRepositoryProvider);
  final kinds = CatalogMediaKind.values.where((kind) => !kind.isUnknown);
  final workspaces = await Future.wait(
    kinds.map((kind) => repository.load(kind, includeWishlistOnly: true)),
  );
  return List.unmodifiable(workspaces.expand((workspace) => workspace));
});
