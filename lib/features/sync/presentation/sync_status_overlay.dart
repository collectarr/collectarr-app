import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/ui/app_close_button.dart';
import 'dart:ui';
import 'package:collectarr_app/features/sync/presentation/sync_conflict_review.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';

import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncStatusOverlay extends ConsumerWidget {
  const SyncStatusOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    final palette = appPalette(context);
    void openLogs({required bool error}) {
      final lastSyncTime = sync.syncLog.lastOrNull?.timestamp;
      final existing = ref
          .read(appLogProvider)
          .where((entry) =>
              entry.source == 'sync' &&
              (error
                  ? entry.level == AppLogLevel.error &&
                      lastSyncTime != null &&
                      entry.timestamp.isAtSameMomentAs(lastSyncTime)
                  : entry.level == AppLogLevel.warning &&
                      entry.message == sync.warningMessage))
          .lastOrNull;
      var timestamp = existing?.timestamp;
      if (existing == null) {
        timestamp = DateTime.now().toUtc();
        final logger = ref.read(appLogProvider.notifier);
        if (error) {
          logger.error('sync',
              sync.syncLog.lastOrNull?.errorMessage ?? sync.errorMessage!,
              timestamp: timestamp);
        } else {
          logger.warn('sync', sync.warningMessage!, timestamp: timestamp);
        }
      }
      context.openPage(AppRoutes.forKind(
          AppRoutes.settings, ref.read(selectedLibraryKindProvider),
          parameters: {
            'section': 'logs',
            'logTime': timestamp!.toIso8601String(),
          }));
    }

    final showAny = sync.isSyncing ||
        sync.errorMessage != null ||
        sync.warningMessage != null;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !showAny,
        child: Stack(
          children: [
            // 1. Syncing Indicator (Bottom Right)
            if (sync.isSyncing)
              Positioned(
                bottom: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: sync.isSyncing ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: palette.surface.withValues(alpha: 0.85),
                          border: Border.all(
                            color: palette.accent.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    palette.accent),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              sync.pendingCount > 0
                                  ? 'Syncing (${sync.pendingCount} pending)...'
                                  : 'Syncing...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 2. Error Banner (Top Center)
            if (sync.errorMessage != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: palette.isDark
                          ? Colors.red.shade900.withValues(alpha: 0.9)
                          : Colors.red.shade50,
                      border: Border.all(
                        color: palette.isDark
                            ? Colors.red.shade700
                            : Colors.red.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: palette.isDark
                              ? Colors.red.shade200
                              : Colors.red.shade800,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SyncBannerMessage(
                            title: sync.isOffline
                                ? 'Sync Connection Issue'
                                : 'Sync could not finish',
                            message: sync.errorMessage!,
                            color: palette.isDark
                                ? Colors.red.shade100
                                : Colors.red.shade900,
                            onOpenLogs: () => openLogs(error: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppCloseButton(
                          size: 32,
                          hoverColor:
                              (palette.isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.12),
                          icon: Icons.close,
                          iconSize: 18,
                          color: palette.isDark
                              ? Colors.white70
                              : Colors.red.shade800,
                          onPressed: () {
                            ref
                                .read(syncControllerProvider.notifier)
                                .dismissError();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (sync.warningMessage != null)
              // 3. Warning/Rejected Changes Banner (Top Center)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: palette.isDark
                          ? Colors.orange.shade900.withValues(alpha: 0.9)
                          : Colors.orange.shade50,
                      border: Border.all(
                        color: palette.isDark
                            ? Colors.orange.shade700
                            : Colors.orange.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: palette.isDark
                              ? Colors.orange.shade200
                              : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SyncBannerMessage(
                            title: 'Sync Conflict/Warning',
                            message: sync.warningMessage!,
                            color: palette.isDark
                                ? Colors.orange.shade100
                                : Colors.orange.shade900,
                            onOpenLogs: () => openLogs(error: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (sync.rejectedChanges.isNotEmpty)
                          TextButton(
                            key: const Key('sync.conflicts.review'),
                            onPressed: () => showSyncConflictReview(context),
                            style: TextButton.styleFrom(
                              foregroundColor: palette.isDark
                                  ? Colors.white
                                  : Colors.orange.shade900,
                            ),
                            child: const Text('Review'),
                          ),
                        AppCloseButton(
                          size: 32,
                          hoverColor:
                              (palette.isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.12),
                          icon: Icons.close,
                          iconSize: 18,
                          tooltip: 'Keep the other version',
                          color: palette.isDark
                              ? Colors.white70
                              : Colors.orange.shade800,
                          onPressed: () {
                            ref
                                .read(syncControllerProvider.notifier)
                                .dismissAllRejectedChanges();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SyncBannerMessage extends StatelessWidget {
  const _SyncBannerMessage(
      {required this.title,
      required this.message,
      required this.color,
      required this.onOpenLogs});
  final String title;
  final String message;
  final Color color;
  final VoidCallback onOpenLogs;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'View full message in Logs',
        child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onOpenLogs,
              mouseCursor: SystemMouseCursors.click,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    const SizedBox(height: 2),
                    Text(message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: color)),
                    const SizedBox(height: 4),
                    Text('View in Logs',
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            decoration: TextDecoration.underline)),
                  ]),
            )),
      );
}
