import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';

/// Catalog transport mutations are kept separate from Owned mutations.
final class CatalogTransportMutations {
  const CatalogTransportMutations({
    required this.catalogTransport,
    required this.mutationRunner,
  });

  final CatalogTransportRepository catalogTransport;
  final CollectionMutationRunner mutationRunner;

  Future<void> upsertTransport(
    CatalogImportTransport item,
  ) async {
    await mutationRunner.run(
      action: () async {
        await catalogTransport.upsertTransports([item]);
      },
      eventsToEmit: [CatalogItemChanged(item.ref)],
    );
  }

  Future<void> upsertTransports(Iterable<CatalogImportTransport> items) async {
    final pending = items.toList(growable: false);
    if (pending.isEmpty) return;

    await mutationRunner.run(
      action: () async {
        await catalogTransport.upsertTransports(pending);
      },
      eventsToEmit: [
        for (final item in pending) CatalogItemChanged(item.ref),
      ],
    );
  }
}
