import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/features/sync/presentation/sync_status_overlay.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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

  /// Branch indices in the GoRouter StatefulShellRoute:
  /// 0 = libraries, 1 = shelf, 2 = loans, 3 = calendar, 4 = admin, 5 = settings
  static const _branchLibraries = 0;
  static const _branchShelf = 1;
  static const _branchLoans = 2;
  static const _branchCalendar = 3;
  static const _branchAdmin = 4;
  static const _branchSettings = 5;

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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final activeLibrary = _activeLibraryKind();
    final accent =
        libraryAccentForKind(catalogMediaKindFromValue(activeLibrary));
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final mediaQuery = MediaQuery.maybeOf(context);
    final accentTheme = buildLibraryAccentTheme(Theme.of(context), accent);

    final shell = LibraryAccentScope(
      kind: activeLibrary,
      accent: accent,
      animationsEnabled: uiPreferences.animationsEnabled,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40,
          automaticallyImplyLeading: false,
          leadingWidth: 44,
          leading: Builder(
            builder: (context) => IconButton(
              key: const Key('app.open-navigation'),
              tooltip: 'Open navigation',
              visualDensity: VisualDensity.compact,
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
          titleSpacing: 2,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.library_music_outlined, size: 19),
              SizedBox(width: 7),
              Text('Collectarr'),
            ],
          ),
          backgroundColor: libraryAccentChromeFallbackColor(accent),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 19),
          flexibleSpace: LibraryAccentChrome(
            accent: accent,
            animationDuration: uiPreferences.animationsEnabled
                ? kAppAnimNormal
                : Duration.zero,
          ),
          actions: [
            IconButton(
              key: const Key('nav.settings'),
              tooltip: 'Settings',
              visualDensity: VisualDensity.compact,
              onPressed: () => widget.navigationShell.goBranch(
                _branchSettings,
                initialLocation:
                    widget.navigationShell.currentIndex == _branchSettings,
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 4),
          ],
        ),
        drawer: _AppNavigationDrawer(
          currentBranch: widget.navigationShell.currentIndex,
          isAdmin: auth.isAdmin,
          accent: accent,
          onBranchSelected: (drawerContext, branch) {
            Navigator.of(drawerContext).pop();
            widget.navigationShell.goBranch(
              branch,
              initialLocation: branch == widget.navigationShell.currentIndex,
            );
          },
        ),
        body: Stack(
          children: [
            AnimatedTheme(
              data: accentTheme,
              duration: uiPreferences.animationsEnabled
                  ? kAppAnimNormal
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              child: widget.navigationShell,
            ),
            const SyncStatusOverlay(),
          ],
        ),
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
    return selectedLibraryHomeType(
      visibleTypes,
      canonicalLibraryNavKind(selectedKind) ?? selectedKind,
    ).kind;
  }
}

class _AppNavigationDrawer extends StatelessWidget {
  const _AppNavigationDrawer({
    required this.currentBranch,
    required this.isAdmin,
    required this.accent,
    required this.onBranchSelected,
  });

  final int currentBranch;
  final bool isAdmin;
  final Color accent;
  final void Function(BuildContext context, int branch) onBranchSelected;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.86)
          .clamp(0.0, 320.0)
          .toDouble(),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: 76,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              color: libraryAccentChromeFallbackColor(accent),
              child: const Row(
                children: [
                  Icon(Icons.library_music_outlined,
                      color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Collectarr',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerSectionLabel('Collection', color: palette.textMuted),
                  _destination(
                    context,
                    branch: _AppShellState._branchLibraries,
                    label: 'Libraries',
                    icon: Icons.apps_outlined,
                    key: const Key('nav.library'),
                  ),
                  _destination(
                    context,
                    branch: _AppShellState._branchShelf,
                    label: 'Shelf',
                    icon: Icons.inventory_2_outlined,
                    key: const Key('nav.shelf'),
                  ),
                  const Divider(height: 18),
                  _DrawerSectionLabel('Tools', color: palette.textMuted),
                  _destination(
                    context,
                    branch: _AppShellState._branchLoans,
                    label: 'Loans',
                    icon: Icons.handshake_outlined,
                    key: const Key('nav.loans'),
                  ),
                  _destination(
                    context,
                    branch: _AppShellState._branchCalendar,
                    label: 'Calendar',
                    icon: Icons.calendar_month_outlined,
                    key: const Key('nav.calendar'),
                  ),
                  if (isAdmin) ...[
                    const Divider(height: 18),
                    _DrawerSectionLabel('Administration',
                        color: palette.textMuted),
                    _destination(
                      context,
                      branch: _AppShellState._branchAdmin,
                      label: 'Admin',
                      icon: Icons.admin_panel_settings_outlined,
                      key: const Key('nav.admin'),
                    ),
                  ],
                  const Divider(height: 18),
                  _DrawerSectionLabel('Customization',
                      color: palette.textMuted),
                  _destination(
                    context,
                    branch: _AppShellState._branchSettings,
                    label: 'Settings',
                    icon: Icons.settings_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _destination(
    BuildContext context, {
    required int branch,
    required String label,
    required IconData icon,
    Key? key,
  }) {
    final selected = currentBranch == branch;
    final palette = appPalette(context);
    return ListTile(
      key: key,
      dense: true,
      visualDensity: VisualDensity.compact,
      selected: selected,
      selectedTileColor: accent.withValues(alpha: palette.isDark ? 0.2 : 0.1),
      leading: Icon(
        icon,
        size: 19,
        color: selected ? accent : palette.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? palette.textPrimary : null,
        ),
      ),
      onTap: () => onBranchSelected(context, branch),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 7, 12, 5),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
