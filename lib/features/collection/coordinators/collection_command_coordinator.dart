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
  }) async {
    final item = await ownedMutations.addOwnedItem(command);
    if (syncTracking) {
      final tracking = command.tracking;
      await trackingMutations.syncOwnedTrackingEntry(
        item,
        anchor: command.anchor,
        status: tracking?.status,
        rating: tracking?.rating,
        startedAt: tracking?.startedAt,
        finishedAt: tracking?.finishedAt,
        notes: tracking?.notes,
      );
    }
    return item;
  }

  Future<OwnedItem> updateOwnedItem(
    UpdateOwnedItemCommand command, {
    bool syncTracking = true,
  }) async {
    final item = await ownedMutations.updateOwnedItem(command);
    if (syncTracking) {
      await trackingMutations.syncOwnedTrackingEntry(item);
    }
    return item;
  }
}
