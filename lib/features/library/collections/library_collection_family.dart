import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'library_collection_repository.dart';

List<LibraryKindRegistration> collectionFamilyKinds(String value) {
  final current =
      defaultLibraryKindRegistry.require(catalogMediaKindFromApiValue(value));
  final family = current.identity.collectionFamily;
  if (family == null) return [current];
  return [
    for (final kind in defaultLibraryKindRegistry.allKinds)
      if (kind.identity.collectionFamily == family) kind
  ];
}

final libraryCollectionFamilyProvider = StreamProvider.autoDispose
    .family<List<LibraryCollectionSummary>, String>((ref, kind) =>
        LibraryCollectionRepository(ref.watch(localDatabaseProvider))
            .watchKinds({
          for (final member in collectionFamilyKinds(kind))
            member.kind.apiValue: member.identity.defaultCollectionName,
        }));
