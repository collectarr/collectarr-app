import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';

import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MediaLibraryActionsBar extends StatelessWidget {
  const MediaLibraryActionsBar({
    super.key,
    required this.overdueLoanCount,
    required this.selectedOverdueLoanCount,
    required this.selectedLabel,
    this.animationDuration = kAppAnimNormal,
  });

  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final accentData = LibraryAccentScope.of(context);
    return AnimatedLibraryChromeGradient(
      accent: accentData.accent,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      duration: animationDuration,
      borderBuilder: (animatedAccent, brightness) => Border(
        top: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
        bottom: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
      ),
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              _MediaLibraryOverdueActions(
                overdueLoanCount: overdueLoanCount,
                selectedOverdueLoanCount: selectedOverdueLoanCount,
                selectedLabel: selectedLabel,
              ),
              const Spacer(),
              const _LibraryTopNavSyncButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaLibraryOverdueActions extends StatelessWidget {
  const _MediaLibraryOverdueActions({
    required this.overdueLoanCount,
    required this.selectedOverdueLoanCount,
    required this.selectedLabel,
  });

  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (overdueLoanCount > 0) ...[
            _OverdueLoanChip(
              overdueLoanCount: overdueLoanCount,
              selectedOverdueLoanCount: selectedOverdueLoanCount,
              selectedLabel: selectedLabel,
              onPressed: () => context.go(AppRoutes.loans),
            ),
          ],
        ],
      ),
    );
  }
}

class _LibraryTopNavSyncButton extends ConsumerWidget {
  const _LibraryTopNavSyncButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncControllerProvider);
    return Tooltip(
      message: sync.isSyncing
          ? 'Personal sync is running'
          : sync.pendingCount > 0
              ? 'Run personal sync now (${sync.pendingCount} pending)'
              : 'Run personal sync now',
      child: SizedBox.square(
        dimension: kLibraryToolbarControlHeight,
        child: IconButton(
          onPressed: sync.isSyncing
              ? null
              : () => ref.read(syncControllerProvider.notifier).syncNow(),
          icon: Icon(
            sync.isOffline ? Icons.cloud_off_outlined : Icons.sync_outlined,
            size: 18,
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            width: kLibraryToolbarControlHeight,
            height: kLibraryToolbarControlHeight,
          ),
          style: IconButton.styleFrom(
            foregroundColor: appPalette(context).textMuted,
            backgroundColor: appPalette(context).surface,
            side: BorderSide(color: appPalette(context).divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverdueLoanChip extends StatelessWidget {
  const _OverdueLoanChip({
    required this.overdueLoanCount,
    required this.selectedOverdueLoanCount,
    required this.selectedLabel,
    required this.onPressed,
  });

  final int overdueLoanCount;
  final int selectedOverdueLoanCount;
  final String selectedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = '$overdueLoanCount overdue';
    final tooltip = selectedOverdueLoanCount > 0
        ? '$overdueLoanCount overdue loan${overdueLoanCount == 1 ? '' : 's'} · '
            '$selectedOverdueLoanCount in $selectedLabel · Open Loans'
        : '$overdueLoanCount overdue loan${overdueLoanCount == 1 ? '' : 's'} · Open Loans';
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: WidgetStateMouseCursor.clickable,
          borderRadius: BorderRadius.circular(3),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kAppOverdueBackground,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: kAppOverdueBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: kAppOverdueText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
