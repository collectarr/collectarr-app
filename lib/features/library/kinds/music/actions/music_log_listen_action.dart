import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_target_action_capability.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart'
    show LibraryEditTextField;
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> runMusicLogListenAction(
  LibraryTargetActionContext action,
) async {
  final projection = action.item.dto;
  if (projection is! MusicWorkspaceProjection) return;
  final libraryEntryRef = action.libraryEntry?.ref;
  if (libraryEntryRef == null ||
      libraryEntryRef.kind != CatalogMediaKind.music) {
    return;
  }

  final notesController = TextEditingController();
  try {
    final shouldSave = await showDialog<bool>(
      context: action.buildContext,
      builder: (dialogContext) => AccentAlertDialog(
        title: const Text('Log listen'),
        content: LibraryEditTextField(
          controller: notesController,
          label: 'Notes',
          hint: 'Optional listening notes',
          autofocus: true,
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

    final now = DateTime.now().toUtc();
    final container = ProviderScope.containerOf(action.buildContext);
    await container.read(musicListeningMutationsProvider).upsert(
          MusicListenEvent(
            id: 'listen-${now.microsecondsSinceEpoch}',
            libraryEntryRef: libraryEntryRef,
            listenedAt: now,
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
    container.invalidate(musicListeningEventsProvider(libraryEntryRef));
    container.invalidate(musicEntryListeningSummaryProvider(libraryEntryRef));
  } finally {
    notesController.dispose();
  }
}
