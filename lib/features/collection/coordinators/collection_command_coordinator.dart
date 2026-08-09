import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';

final class CollectionCommandCoordinator {
  const CollectionCommandCoordinator({
    required this.ownedMutations,
    required this.trackingMutations,
  });

  final OwnedItemMutations ownedMutations;
  final TrackingMutations trackingMutations;

  Future<OwnedItem> addOwnedItem(
    AddOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final item = await ownedMutations.addOwnedItem(
      command,
      syncTracking: syncTracking,
      notify: notify,
    );
    final hasTrackingInfo = command.common.rating != null ||
        command.common.readStatus != null ||
        command.common.startedAt != null ||
        command.common.finishedAt != null;
    if (syncTracking && hasTrackingInfo) {
      await trackingMutations.syncOwnedTrackingEntry(item);
    }
    return item;
  }

  Future<OwnedItem> updateOwnedItem(
    UpdateOwnedItemCommand command, {
    bool syncTracking = true,
    bool notify = true,
  }) async {
    final item = await ownedMutations.updateOwnedItem(
      command,
      syncTracking: syncTracking,
      notify: notify,
    );
    if (syncTracking) {
      await trackingMutations.syncOwnedTrackingEntry(item);
    }
    return item;
  }
}
