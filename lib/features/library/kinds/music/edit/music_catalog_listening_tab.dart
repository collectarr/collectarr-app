import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_providers.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CRUD for listening events attached to one concrete Music Catalog Item.
final class MusicCatalogListeningTab extends ConsumerWidget {
  const MusicCatalogListeningTab({
    super.key,
    required this.item,
    required this.accent,
  });

  final CatalogSearchCandidate item;
  final Color accent;

  CatalogItemRef get catalogRef => CatalogItemRef(
        kind: CatalogMediaKind.music,
        id: item.reference.rootScope.id,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(musicListeningEventsProvider(catalogRef));
    return EditTabShell(
      children: [
        EditSection(
          title: 'Listening history',
          accent: accent,
          child: events.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (error, _) =>
                Text('Unable to load listening history: $error'),
            data: (history) => _body(context, ref, history),
          ),
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    List<MusicListenEvent> history,
  ) {
    final lastListened = history.firstOrNull?.listenedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                history.isEmpty
                    ? 'No listens logged yet.'
                    : '${history.length} ${history.length == 1 ? 'listen' : 'listens'} / Last ${formatDate(lastListened!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appPalette(context).textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _logListen(context, ref),
              icon: const Icon(Icons.headphones_outlined, size: 16),
              label: const Text('Log listen'),
            ),
          ],
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final event in history)
            _MusicCatalogListenEventRow(
              event: event,
              accent: accent,
              onEdit: () => _editListen(context, ref, event),
              onDelete: () => _deleteListen(context, ref, event),
            ),
        ],
      ],
    );
  }

  Future<void> _logListen(BuildContext context, WidgetRef ref) async {
    final date = await showLibraryDateEntryDialog(
      context,
      label: 'Listen date',
      initialDate: DateTime.now(),
    );
    if (date == null || !context.mounted) return;
    final notes = await _notesDialog(context, title: 'Log listen');
    if (notes == null || !context.mounted) return;
    final listenedAt = DateTime.utc(date.year, date.month, date.day);
    await ref.read(musicListeningRepositoryProvider).upsert(
          MusicListenEvent(
            id: 'listen-${DateTime.now().microsecondsSinceEpoch}',
            catalogRef: catalogRef,
            listenedAt: listenedAt,
            notes: notes,
            createdAt: listenedAt,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    _invalidate(ref);
  }

  Future<void> _editListen(
    BuildContext context,
    WidgetRef ref,
    MusicListenEvent event,
  ) async {
    final notes = await _notesDialog(
      context,
      title: 'Edit listen',
      initial: event.notes,
    );
    if (notes == null || !context.mounted) return;
    await ref.read(musicListeningRepositoryProvider).upsert(
          MusicListenEvent(
            id: event.id,
            catalogRef: event.catalogRef,
            ownedRef: event.ownedRef,
            listenedAt: event.listenedAt,
            startedAt: event.startedAt,
            finishedAt: event.finishedAt,
            location: event.location,
            notes: notes,
            createdAt: event.createdAt,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    _invalidate(ref);
  }

  Future<void> _deleteListen(
    BuildContext context,
    WidgetRef ref,
    MusicListenEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AccentAlertDialog(
        title: const Text('Delete listen?'),
        content: const Text('This listen will be removed from active history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(musicListeningRepositoryProvider).markDeleted(
          event,
          DateTime.now().toUtc(),
        );
    _invalidate(ref);
  }

  Future<String?> _notesDialog(
    BuildContext context, {
    required String title,
    String? initial,
  }) async {
    final controller = TextEditingController(text: initial ?? '');
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AccentAlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional listening notes',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text.trim(),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _invalidate(WidgetRef ref) {
    ref.invalidate(shelfProvider);
    ref.invalidate(musicListeningEventsProvider(catalogRef));
    ref.invalidate(musicCatalogItemListeningSummaryProvider(catalogRef));
  }
}

final class _MusicCatalogListenEventRow extends StatelessWidget {
  const _MusicCatalogListenEventRow({
    required this.event,
    required this.accent,
    required this.onEdit,
    required this.onDelete,
  });

  final MusicListenEvent event;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.headphones_outlined, size: 15, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(event.listenedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (event.notes?.trim().isNotEmpty == true)
                  Text(
                    event.notes!.trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appPalette(context).textMuted,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit listen',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 17),
          ),
          IconButton(
            tooltip: 'Delete listen',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 17),
          ),
        ],
      ),
    );
  }
}
