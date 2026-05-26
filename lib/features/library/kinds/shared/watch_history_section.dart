import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchHistorySection extends ConsumerWidget {
  const WatchHistorySection({
    super.key,
    required this.itemId,
    required this.accent,
  });

  final String itemId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions =
        ref.watch(watchSessionsByItemProvider)[itemId] ?? const <WatchSession>[];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD51C1F21),
        border: Border.all(color: accent.withValues(alpha: 0.33)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Watch history',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                  ),
                ),
                _AddWatchSessionButton(
                  itemId: itemId,
                  accent: accent,
                ),
              ],
            ),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No watches logged yet.',
                  style: TextStyle(color: kAppTextMuted, fontSize: 12),
                ),
              )
            else ...[
              const SizedBox(height: 4),
              Text(
                '${sessions.length} ${sessions.length == 1 ? 'watch' : 'watches'}',
                style: const TextStyle(color: kAppTextMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              for (final session in sessions)
                _WatchSessionTile(
                  session: session,
                  accent: accent,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddWatchSessionButton extends ConsumerWidget {
  const _AddWatchSessionButton({
    required this.itemId,
    required this.accent,
  });

  final String itemId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.add_circle_outline, color: accent, size: 22),
      tooltip: 'Log a watch',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () => _showAddDialog(context, ref),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (pickedDate == null || !context.mounted) return;
    final mutations = ref.read(collectionMutationsProvider);
    await mutations.addWatchSession(
      itemId,
      watchedAt: DateTime.utc(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        now.hour,
        now.minute,
        now.second,
      ),
    );
  }
}

class _WatchSessionTile extends ConsumerWidget {
  const _WatchSessionTile({
    required this.session,
    required this.accent,
  });

  final WatchSession session;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localDate = session.watchedAt.toLocal();
    final dateLabel =
        '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.visibility, color: accent.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateLabel,
              style: const TextStyle(color: kAppTextBright, fontSize: 13),
            ),
          ),
          if (session.rating != null)
            Text(
              '${session.rating}/10',
              style: TextStyle(color: accent, fontSize: 12),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: kAppTextMuted),
            tooltip: 'Remove',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () async {
              final mutations = ref.read(collectionMutationsProvider);
              await mutations.removeWatchSession(session);
            },
          ),
        ],
      ),
    );
  }
}
