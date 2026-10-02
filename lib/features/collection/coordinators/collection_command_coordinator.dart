import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/collection/mutations/collection_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';

final class CollectionCommandCoordinator {
  const CollectionCommandCoordinator({
    required this.ownedMutations,
    required this.trackingMutations,
  });

  final CollectionItemMutations ownedMutations;
  final TrackingMutations trackingMutations;

  Future<CollectionItemRef> addCollectionItem(
    AddCollectionItemCommand command, {
    bool syncTracking = true,
  }) async {
    final item = await ownedMutations.addCollectionItem(command);
    if (syncTracking) {
      final tracking = command.tracking;
      await trackingMutations.syncOwnedTrackingState(
        item,
        targetRef: command.catalogRef,
        status: tracking?.status,
        rating: tracking?.rating,
        startedAt: tracking?.startedAt,
        finishedAt: tracking?.finishedAt,
        notes: tracking?.notes,
      );
    }
    return item;
  }

  Future<CollectionItemRef> updateCollectionItem(
    CollectionItemUpdateRequest command, {
    bool syncTracking = true,
  }) async {
    final item = await ownedMutations.updateCollectionItem(command);
    if (syncTracking) {
      await trackingMutations.syncOwnedTrackingState(item);
    }
    return item;
  }
}
