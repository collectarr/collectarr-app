import 'dart:ui';
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

    final showAny = sync.isSyncing || sync.errorMessage != null || sync.warningMessage != null;
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: palette.isDark ? Colors.red.shade900.withValues(alpha: 0.9) : Colors.red.shade50,
                    border: Border.all(
                      color: palette.isDark ? Colors.red.shade700 : Colors.red.shade300,
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
                        color: palette.isDark ? Colors.red.shade200 : Colors.red.shade800,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sync Connection Issue',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: palette.isDark ? Colors.white : Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sync.errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: palette.isDark ? Colors.red.shade100 : Colors.red.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: palette.isDark ? Colors.white70 : Colors.red.shade800,
                        onPressed: () {
                          ref.read(syncControllerProvider.notifier).dismissError();
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: palette.isDark ? Colors.orange.shade900.withValues(alpha: 0.9) : Colors.orange.shade50,
                    border: Border.all(
                      color: palette.isDark ? Colors.orange.shade700 : Colors.orange.shade300,
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
                        color: palette.isDark ? Colors.orange.shade200 : Colors.orange.shade800,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sync Conflict/Warning',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: palette.isDark ? Colors.white : Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sync.warningMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: palette.isDark ? Colors.orange.shade100 : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: palette.isDark ? Colors.white70 : Colors.orange.shade800,
                        onPressed: () {
                          ref.read(syncControllerProvider.notifier).dismissAllRejectedChanges();
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
