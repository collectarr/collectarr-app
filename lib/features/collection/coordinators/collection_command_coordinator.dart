import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/collection/commands/library_entry_commands.dart';
import 'package:collectarr_app/features/collection/mutations/library_entry_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';

final class CollectionCommandCoordinator {
  const CollectionCommandCoordinator({
    required this.entryMutations,
    required this.trackingMutations,
    required this.mutationRunner,
  });

  final LibraryEntryMutations entryMutations;
  final TrackingMutations trackingMutations;
  final CollectionMutationRunner mutationRunner;

  Future<LibraryEntryRef> addLibraryEntry(
    AddLibraryEntryCommand command, {
    bool syncTracking = true,
  }) async {
    return mutationRunner.run(
      action: () async {
        final item = await entryMutations.addLibraryEntry(command);
        if (syncTracking) {
          final tracking = command.tracking;
          await trackingMutations.syncEntryTrackingState(
            item,
            status: tracking?.status,
            rating: tracking?.rating,
            startedAt: tracking?.startedAt,
            finishedAt: tracking?.finishedAt,
            notes: tracking?.notes,
          );
        }
        return item;
      },
    );
  }

  Future<LibraryEntryRef> updateLibraryEntry(
    LibraryEntryUpdateRequest command, {
    bool syncTracking = true,
  }) async {
    return mutationRunner.run(
      action: () async {
        final item = await entryMutations.updateLibraryEntry(command);
        if (syncTracking) {
          await trackingMutations.syncEntryTrackingState(item);
        }
        return item;
      },
    );
  }
}
