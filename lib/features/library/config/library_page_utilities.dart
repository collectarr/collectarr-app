import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';

import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared utilities for library pages (comics and generic).
mixin LibraryPageUtilities<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  // ---------------------------------------------------------------------------
  // Bulk actions
  // ---------------------------------------------------------------------------

  LibraryBulkActions bulkActions() => LibraryBulkActions(
        coordinator: ref.read(collectionCommandCoordinatorProvider),
        ownedMutations: ref.read(ownedItemMutationsProvider),
        wishlistMutations: ref.read(wishlistMutationsProvider),
        trackingMutations: ref.read(trackingMutationsProvider),
        catalogSnapshots: CatalogSnapshotRepository(
          ref.read(localDatabaseProvider),
        ),
      );

  /// Show a confirmation dialog for bulk removal and return the user's choice.
  Future<bool> confirmBulkRemove(
    BuildContext context, {
    required int count,
    String itemLabel = 'items',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text('Remove selected $itemLabel?'),
        content: Text(
          'This removes $count selected item${count == 1 ? '' : 's'} '
          'from the local shelf and queues the change for sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<bool> confirmSingleRemove(
    BuildContext context, {
    required String title,
    required String itemLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text('Remove $itemLabel?'),
        content: Text(
          'Remove "$title" from the local shelf and queue the change for sync?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// Show the bulk edit dialog and return the selection (null = cancelled).
  Future<LibraryBulkEditSelection?> showBulkEditDialog(
    BuildContext context, {
    required LibraryKindRegistration type,
    required int selectedCount,
  }) {
    return showDialog<LibraryBulkEditSelection>(
      context: context,
      builder: (context) => LibraryBulkEditDialog(
        type: type,
        selectedCount: selectedCount,
      ),
    );
  }
}
