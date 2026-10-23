import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manual sync action, hosted by the main app bar on every library page.
class SyncActionButton extends ConsumerWidget {
  const SyncActionButton({super.key, required this.style});
  final ButtonStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    return IconButton(
        key: const Key('app.sync'),
        tooltip: sync.isSyncing
            ? 'Personal sync is running'
            : sync.isOffline
                ? 'Personal sync is offline. Try again'
                : sync.pendingCount > 0
                    ? 'Run personal sync now (${sync.pendingCount} pending)'
                    : 'Run personal sync now',
        style: style,
        visualDensity: VisualDensity.compact,
        onPressed: sync.isSyncing
            ? null
            : () => ref.read(syncControllerProvider.notifier).syncNow(),
        icon: sync.isSyncing
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            // The switcher's 20 px SVG paints a 16 px glyph inside its viewBox.
            : const Icon(AppIcons.sync, size: 16));
  }
}
