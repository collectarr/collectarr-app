import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_entity_action_capability.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_entity_ownership.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> runMusicLogListenAction(
  LibraryEntityActionContext action,
) async {
  final projection = action.item.dto;
  if (projection is! MusicWorkspaceProjection || projection.release == null) {
    return;
  }
  final root = action.item.source.catalogRef;
  if (root == null) return;

  final notesController = TextEditingController();
  try {
    final shouldSave = await showDialog<bool>(
      context: action.buildContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log listen'),
        content: TextField(
          controller: notesController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Optional listening notes',
          ),
          minLines: 1,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (shouldSave != true || !action.buildContext.mounted) return;

    final release = projection.release!;
    final releaseRef = musicReleaseRefForRoot(root, release.id.value);
    final now = DateTime.now().toUtc();
    final ownedRef = action.ownedItem?.ref;
    final container = ProviderScope.containerOf(action.buildContext);
    await container.read(musicListeningRepositoryProvider).upsert(
          MusicListenEvent(
            id: 'listen-${now.microsecondsSinceEpoch}',
            releaseRef: releaseRef,
            targetRef: releaseRef,
            ownedRef:
                ownedRef?.kind == CatalogMediaKind.music ? ownedRef : null,
            listenedAt: now,
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    container.invalidate(musicListeningEventsProvider(releaseRef));
    container.invalidate(
      musicReleaseGroupTrackingSummaryProvider(
        MusicReleaseGroupId(root.rootScope.id),
      ),
    );
  } finally {
    notesController.dispose();
  }
}
