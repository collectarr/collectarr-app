import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/sync_settings_dialog.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _didRequestInitialOnlineFirstSync = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRequestInitialOnlineFirstSync) {
        return;
      }
      _didRequestInitialOnlineFirstSync = true;
      ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled();
    });
  }

  /// Branch indices in the GoRouter StatefulShellRoute:
  /// 0 = libraries, 1 = shelf, 2 = admin, 3 = settings
  static const _branchLibraries = 0;
  static const _branchShelf = 1;
  static const _branchAdmin = 2;
  static const _branchSettings = 3;

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final activeLibrary = _activeLibraryKind();
    final accent = libraryAccentForKind(activeLibrary);
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final mediaQuery = MediaQuery.maybeOf(context);
    final accentTheme = buildLibraryAccentTheme(Theme.of(context), accent);
    final isAdmin = auth.isAdmin;

    // Map GoRouter branch index to visible nav destinations.
    final currentBranch = widget.navigationShell.currentIndex;
    final visibleBranches = [
      _branchLibraries,
      _branchShelf,
      if (isAdmin) _branchAdmin,
      _branchSettings,
    ];
    final selectedVisualIndex = visibleBranches.indexOf(currentBranch).clamp(0, visibleBranches.length - 1);
    final isOnLibraries = currentBranch == _branchLibraries;

    final pages = [
      const _ShellPage(label: 'Libraries', icon: Icons.apps_outlined),
      const _ShellPage(label: 'Shelf', icon: Icons.inventory_2),
      if (isAdmin)
        const _ShellPage(
          label: 'Admin',
          icon: Icons.admin_panel_settings_outlined,
          adminOnly: true,
        ),
      const _ShellPage(label: 'Settings', icon: Icons.settings_outlined),
    ];

    final shell = Scaffold(
      body: LibraryAccentScope(
        accent: accent,
        animationsEnabled: uiPreferences.animationsEnabled,
        child: AnimatedTheme(
          data: accentTheme,
          duration: uiPreferences.animationsEnabled
              ? const Duration(milliseconds: 360)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          child: widget.navigationShell,
        ),
      ),
      floatingActionButton: isOnLibraries
          ? LibraryAwareSyncButton(
              sync: sync,
              accent: accent,
              animationsEnabled: uiPreferences.animationsEnabled,
              tooltip: _syncTooltip(sync),
              onPressed: sync.isSyncing ? null : _syncNow,
            )
          : null,
      bottomNavigationBar: _LibraryAwareNavigationBar(
        pages: pages,
        selectedIndex: selectedVisualIndex,
        accent: accent,
        animationsEnabled: uiPreferences.animationsEnabled,
        onDestinationSelected: (visualIndex) {
          final branchIndex = visibleBranches[visualIndex];
          widget.navigationShell.goBranch(
            branchIndex,
            initialLocation: branchIndex == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
    if (mediaQuery == null) {
      return shell;
    }
    return MediaQuery(
      data: mediaQuery.copyWith(
        disableAnimations:
            mediaQuery.disableAnimations || !uiPreferences.animationsEnabled,
      ),
      child: shell,
    );
  }

  String _activeLibraryKind() {
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final selectedKind = ref.watch(selectedLibraryKindProvider);
    final allTypes = orderedLibraryHomeTypes(catalog, navPreferences);
    final visibleTypes = visibleLibraryHomeTypes(allTypes, navPreferences);
    return selectedLibraryHomeType(visibleTypes, selectedKind).kind;
  }

  Future<void> _syncNow() async {
    final accent = libraryAccentForKind(_activeLibraryKind());
    final confirmed = await showSyncSettingsDialog(
      context: context,
      accent: accent,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(syncControllerProvider.notifier).syncNow();
    if (!mounted) {
      return;
    }
    final sync = ref.read(syncControllerProvider);
    final message = _syncResultMessage(sync);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _syncTooltip(SyncState sync) {
    if (sync.isOffline) {
      return sync.errorMessage ?? 'Sync unavailable';
    }
    if (sync.warningMessage != null) {
      return sync.warningMessage!;
    }
    final pending = sync.pendingCount == 0
        ? 'no pending changes'
        : '${sync.pendingCount} pending';
    final last = sync.lastSyncedAt == null
        ? 'never synced'
        : 'last sync ${_formatSyncTime(sync.lastSyncedAt!)}';
    return 'Sync personal data - $pending, $last';
  }

  String _syncResultMessage(SyncState sync) {
    if (sync.errorMessage != null) {
      return 'Personal sync unavailable: ${sync.errorMessage}';
    }
    return sync.warningMessage ?? 'Personal sync complete';
  }

  String _formatSyncTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
  }
}

class _ShellPage {
  const _ShellPage({
    required this.label,
    required this.icon,
    this.adminOnly = false,
  });

  final String label;
  final IconData icon;
  final bool adminOnly;
}

class LibraryAwareSyncButton extends StatelessWidget {
  const LibraryAwareSyncButton({
    super.key,
    required this.sync,
    required this.accent,
    required this.animationsEnabled,
    required this.tooltip,
    required this.onPressed,
  });

  final SyncState sync;
  final Color accent;
  final bool animationsEnabled;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final duration =
        animationsEnabled ? const Duration(milliseconds: 360) : Duration.zero;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, color, child) {
        final animatedAccent = color ?? accent;
        final actionAccent = libraryAccentActionColor(animatedAccent);
        const onAccent = Colors.white;
        return FloatingActionButton.small(
          tooltip: tooltip,
          backgroundColor: actionAccent,
          foregroundColor: onAccent,
          onPressed: onPressed,
          child: sync.isSyncing
              ? SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: onAccent,
                  ),
                )
              : Badge(
                  isLabelVisible: sync.pendingCount > 0,
                  backgroundColor: onAccent,
                  textColor: actionAccent,
                  label: Text(sync.pendingCount.toString()),
                  child: Icon(sync.isOffline ? Icons.cloud_off : Icons.sync),
                ),
        );
      },
    );
  }
}

class _LibraryAwareNavigationBar extends StatelessWidget {
  const _LibraryAwareNavigationBar({
    required this.pages,
    required this.selectedIndex,
    required this.accent,
    required this.animationsEnabled,
    required this.onDestinationSelected,
  });

  final List<_ShellPage> pages;
  final int selectedIndex;
  final Color accent;
  final bool animationsEnabled;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final duration =
        animationsEnabled ? const Duration(milliseconds: 360) : Duration.zero;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, color, child) {
        final animatedAccent = color ?? accent;
        final indicatorColor = animatedAccent.withValues(alpha: 0.52);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: libraryChromeGradient(
              animatedAccent,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              top: BorderSide(
                color: Color.alphaBlend(
                  Colors.white.withValues(alpha: 0.12),
                  animatedAccent,
                ),
              ),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarTheme.of(context).copyWith(
              backgroundColor: Colors.transparent,
              indicatorColor: indicatorColor,
              height: 58,
              labelTextStyle: const WidgetStatePropertyAll(
                TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              iconTheme: const WidgetStatePropertyAll(
                IconThemeData(color: Colors.white, size: 20),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: indicatorColor,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final page in pages)
                  NavigationDestination(
                    icon: page.adminOnly
                        ? Badge(
                            label: const Icon(
                              Icons.shield_outlined,
                              size: 9,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.white24,
                            child: Icon(page.icon),
                          )
                        : Icon(page.icon),
                    label: page.label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
