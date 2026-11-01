import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/state/local_database_provider.dart';

/// Reuses shelf hydration and kind-owned catalog projections, including offline entries.
final restorableDetailItemProvider = FutureProvider.autoDispose
    .family<LibraryProjectionItem?, LibraryTargetRef>((ref, target) async {
  final type = defaultLibraryKindRegistry.tryGet(target.kind);
  if (type == null) return null;
  final shelf = await ref.watch(shelfProvider.future);
  final source =
      shelf.entries.where((item) => item.target == target).firstOrNull;
  if (source != null && source.kindPresentationData != null) {
    return LibraryProjectionItem.fromShelf(source, type);
  }
  if (target is! CatalogTargetRef) return null;
  final db = ref.watch(localDatabaseProvider);
  final data =
      await CatalogWorkspaceDataRepository(db).findCatalogItems([target.ref]);
  final summary =
      await CatalogDisplaySummaryRepository(db).findByRefs([target.ref]);
  if (data[target.ref] == null || summary[target.ref] == null) return null;
  return LibraryProjectionItem.fromShelf(
      LibraryWorkspaceContext(
          item: WorkspaceItem(
              target: target,
              presentation: summary[target.ref],
              kindPresentationData: data[target.ref]),
          personal: const PersonalOverlay()),
      type);
});
