import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';

class LibraryPageBucketCoordinator {
  const LibraryPageBucketCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  Future<void> showBucketManagerFlow(
    LibraryProjection projection, {
    required String mode,
  }) async {
    final workspace = libraryKindWorkspaceForKind(_page.type.kind);
    final fields =
        workspace.fieldsForGroupModeAcrossTargets(mode) ?? workspace.fields;
    final definition = fields.findGroupDefinition(fields.decodeGroupId(mode));
    final vocabulary = definition?.bucketVocabulary;
    if (vocabulary != null) {
      final changes = await showPickListManagerDialog(
        context: _page.context,
        db: _page.ref.read(localDatabaseProvider),
        registry: defaultPickListRegistry,
        initialListName: vocabulary.value,
        initialMediaKind: _page.type.kind.apiValue,
      );
      if (_page.mounted) {
        final selected = _page.selectedBucket;
        if (changes != null && selected != null) {
          _page.rebuild(() =>
              _page.selectedBucket = changes.apply(vocabulary.value, selected));
        }
        _page.invalidateShelf();
      }
      return;
    }
    final allBucketLabel = genericAllBucketLabel(_page.type);
    final entries = [
      for (final bucket in projection.buckets)
        if (bucket.title != allBucketLabel)
          LibraryBucketManagerEntry(
            label: bucket.title,
            count: bucket.count,
          ),
    ];
    if (entries.isEmpty) {
      return;
    }
    await showLibraryBucketManagerDialog(
      context: _page.context,
      type: _page.type,
      groupMode: mode,
      accent: _page.accent,
      entries: entries,
      onRenameBucket: (currentLabel, nextLabel) => mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: nextLabel,
      ),
      onMergeBucket: (currentLabel, targetLabel) => mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: targetLabel,
      ),
      onDeleteBucket: (currentLabel) =>
          mutateBucketValues(projection, mode, currentLabel),
    );
  }

  Future<int> mutateBucketValues(
    LibraryProjection projection,
    String mode,
    String currentLabel, {
    String? replacement,
  }) async {
    final registration = _page.type;
    final workspace = libraryKindWorkspaceForKind(registration.kind);

    final catalogUpdates = <CatalogItemRef, CatalogImportTransport>{};
    final entryUpdates = <LibraryEntryRef, UpdateLibraryEntryCommand>{};
    final catalogRefs = [
      for (final item in projection.allItems)
        if (item.source.sourceCatalogRef case final ref?) ref,
    ];
    final catalogCandidates = await CatalogSnapshotRepository(
      _page.ref.read(localDatabaseProvider),
    ).findTransportsByRefs(catalogRefs);
    for (final item in projection.allItems) {
      final fields = workspace.fieldsForGroupModeAcrossTargets(mode) ??
          workspace.fieldsForTarget(item.target);
      final groupId = fields.decodeGroupId(mode);
      final groupDefinition = fields.findGroupDefinition(groupId);
      if (groupDefinition == null ||
          !groupDefinition.supportsBucketManagement ||
          genericBucketForItemGroup(item, _page.type, groupId) !=
              currentLabel.trim()) {
        continue;
      }

      final catalogTransport = switch (item.source.sourceCatalogRef) {
        final ref? => catalogCandidates[ref],
        null => null,
      };
      if (groupDefinition.bucketValueMutator != null &&
          catalogTransport != null) {
        final updatedCatalog = groupDefinition.bucketValueMutator!.call(
          catalogTransport,
          currentLabel,
          replacement: replacement,
        );
        if (updatedCatalog != null) {
          catalogUpdates[updatedCatalog.ref] = updatedCatalog;
        }
      }

      final libraryEntryDispatch = item.source.libraryEntryDispatch;
      if (libraryEntryDispatch != null) {
        final entryUpdate = groupDefinition.entryBucketValueMutator?.call(
          libraryEntryDispatch,
          currentLabel,
          replacement: replacement,
        );
        if (entryUpdate != null) {
          entryUpdates.putIfAbsent(
              entryUpdate.libraryEntryRef, () => entryUpdate);
        }
      }
    }

    if (catalogUpdates.isEmpty && entryUpdates.isEmpty) {
      return 0;
    }
    final catalogMutations = _page.ref.read(catalogTransportMutationsProvider);
    final entryMutations = _page.ref.read(libraryEntryMutationsProvider);
    if (catalogUpdates.isNotEmpty) {
      await catalogMutations.upsertTransports(
        catalogUpdates.values,
      );
    }
    for (final update in entryUpdates.values) {
      await entryMutations.updateLibraryEntry(update);
    }
    if (!_page.mounted) {
      return catalogUpdates.length + entryUpdates.length;
    }
    _page.rebuild(() {
      if (_page.selectedBucket == currentLabel) {
        final nextBucket = replacement?.trim();
        _page.selectedBucket =
            nextBucket == null || nextBucket.isEmpty ? null : nextBucket;
      }
    });
    return catalogUpdates.length + entryUpdates.length;
  }
}
