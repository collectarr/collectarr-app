import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kind-appropriate labels for the per-item session history section. The same
/// underlying watch_session store backs reads, watches, listens and plays.
class SessionHistoryLabels {
  const SessionHistoryLabels({
    required this.title,
    required this.nounSingular,
    required this.nounPlural,
    required this.addTooltip,
    required this.emptyText,
    required this.icon,
  });

  final String title;
  final String nounSingular;
  final String nounPlural;
  final String addTooltip;
  final String emptyText;
  final IconData icon;

  static const watch = SessionHistoryLabels(
    title: 'Watch history',
    nounSingular: 'watch',
    nounPlural: 'watches',
    addTooltip: 'Log a watch',
    emptyText: 'No watches logged yet.',
    icon: Icons.visibility,
  );

  static const read = SessionHistoryLabels(
    title: 'Read history',
    nounSingular: 'read',
    nounPlural: 'reads',
    addTooltip: 'Log a read',
    emptyText: 'No reads logged yet.',
    icon: Icons.menu_book_outlined,
  );

  static const listen = SessionHistoryLabels(
    title: 'Listen history',
    nounSingular: 'listen',
    nounPlural: 'listens',
    addTooltip: 'Log a listen',
    emptyText: 'No listens logged yet.',
    icon: Icons.headphones_outlined,
  );

  static const play = SessionHistoryLabels(
    title: 'Play history',
    nounSingular: 'play',
    nounPlural: 'plays',
    addTooltip: 'Log a play',
    emptyText: 'No plays logged yet.',
    icon: Icons.sports_esports_outlined,
  );
}

/// Maps a media kind's apiValue to its session-history labels.
SessionHistoryLabels sessionHistoryLabelsForKind(String apiValue) {
  switch (apiValue) {
    case 'comic':
    case 'manga':
    case 'book':
      return SessionHistoryLabels.read;
    case 'music':
      return SessionHistoryLabels.listen;
    case 'game':
    case 'boardgame':
      return SessionHistoryLabels.play;
    default:
      return SessionHistoryLabels.watch;
  }
}

class WatchHistorySection extends ConsumerWidget {
  const WatchHistorySection({
    super.key,
    required this.itemId,
    required this.accent,
    this.labels = SessionHistoryLabels.watch,
  });

  final String itemId;
  final Color accent;
  final SessionHistoryLabels labels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions =
        ref.watch(watchSessionsByItemProvider)[itemId] ?? const <WatchSession>[];
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: appPalette(context).surfaceSubtle,
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
                    labels.title,
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
                  labels: labels,
                ),
              ],
            ),
            if (sessions.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  labels.emptyText,
                  style: TextStyle(color: palette.textMuted, fontSize: 12),
                ),
              )
            else ...[
              const SizedBox(height: 4),
              Text(
                '${sessions.length} '
                '${sessions.length == 1 ? labels.nounSingular : labels.nounPlural}',
                style: TextStyle(color: palette.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              for (final session in sessions)
                _WatchSessionTile(
                  session: session,
                  accent: accent,
                  labels: labels,
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
    required this.labels,
  });

  final String itemId;
  final Color accent;
  final SessionHistoryLabels labels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.add_circle_outline, color: accent, size: 22),
      tooltip: labels.addTooltip,
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
    required this.labels,
  });

  final WatchSession session;
  final Color accent;
  final SessionHistoryLabels labels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final localDate = session.watchedAt.toLocal();
    final dateLabel =
        '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(labels.icon, color: accent.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateLabel,
              style: TextStyle(color: palette.textPrimary, fontSize: 13),
            ),
          ),
          if (session.rating != null)
            Text(
              '${session.rating}/10',
              style: TextStyle(color: accent, fontSize: 12),
            ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: palette.textMuted),
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
