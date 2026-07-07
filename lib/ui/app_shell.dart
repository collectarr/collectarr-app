import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/providers/library_nav_preferences.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
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
  bool _bottomNavCollapsed = false;

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
  /// 0 = libraries, 1 = shelf, 2 = loans, 3 = calendar, 4 = admin, 5 = settings
  static const _branchLibraries = 0;
  static const _branchShelf = 1;
  static const _branchLoans = 2;
  static const _branchCalendar = 3;
  static const _branchAdmin = 4;
  static const _branchSettings = 5;

  @override
  Widget build(BuildContext context) {
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
      _branchLoans,
      _branchCalendar,
      if (isAdmin) _branchAdmin,
      _branchSettings,
    ];
    final selectedVisualIndex = visibleBranches
        .indexOf(currentBranch)
        .clamp(0, visibleBranches.length - 1);

    final pages = [
      const _ShellPage(label: 'Libraries', icon: Icons.apps_outlined),
      const _ShellPage(label: 'Shelf', icon: Icons.inventory_2),
      const _ShellPage(label: 'Loans', icon: Icons.handshake_outlined),
      const _ShellPage(label: 'Calendar', icon: Icons.calendar_month_outlined),
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
          duration:
              uiPreferences.animationsEnabled ? kAppAnimNormal : Duration.zero,
          curve: Curves.easeOutCubic,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: _bottomNavCollapsed
          ? _BottomNavCollapsedStrip(
              accent: accent,
              onExpand: () {
                setState(() {
                  _bottomNavCollapsed = false;
                });
              },
            )
          : _LibraryAwareNavigationBar(
              pages: pages,
              selectedIndex: selectedVisualIndex,
              accent: accent,
              onToggleCollapsed: () {
                setState(() {
                  _bottomNavCollapsed = true;
                });
              },
              onDestinationSelected: (visualIndex) {
                final branchIndex = visibleBranches[visualIndex];
                widget.navigationShell.goBranch(
                  branchIndex,
                  initialLocation:
                      branchIndex == widget.navigationShell.currentIndex,
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
    return selectedLibraryHomeType(
      visibleTypes,
      canonicalLibraryNavKind(selectedKind) ?? selectedKind,
    ).kind;
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

class _LibraryAwareNavigationBar extends StatelessWidget {
  const _LibraryAwareNavigationBar({
    required this.pages,
    required this.selectedIndex,
    required this.accent,
    required this.onToggleCollapsed,
    required this.onDestinationSelected,
  });

  final List<_ShellPage> pages;
  final int selectedIndex;
  final Color accent;
  final VoidCallback onToggleCollapsed;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    const bottomNavHeight = 36.0;
    final palette = appPalette(context);
    return AnimatedLibraryChromeGradient(
      accent: accent,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      borderBuilder: (animatedAccent, brightness) => Border(
        top: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarTheme.of(context).copyWith(
          backgroundColor: Colors.transparent,
          indicatorColor: palette.isDark
              ? accent.withValues(alpha: 0.52)
              : Color.alphaBlend(
                  accent.withValues(alpha: 0.14),
                  palette.selection,
                ),
          height: bottomNavHeight,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: palette.isDark ? Colors.white : palette.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          iconTheme: WidgetStatePropertyAll(
            IconThemeData(
              color: palette.isDark ? Colors.white : palette.textPrimary,
              size: 20,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                indicatorColor: palette.isDark
                    ? accent.withValues(alpha: 0.52)
                    : Color.alphaBlend(
                        accent.withValues(alpha: 0.14),
                        palette.selection,
                      ),
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: [
                  for (final page in pages)
                    NavigationDestination(
                      icon: page.adminOnly
                          ? Badge(
                              label: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              backgroundColor: Colors.deepOrange.shade700,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(page.icon),
                            )
                          : Icon(page.icon),
                      label: page.label,
                    ),
                ],
              ),
            ),
            Tooltip(
              message: 'Hide bottom navigation',
              child: InkWell(
                onTap: onToggleCollapsed,
                child: SizedBox(
                  width: 44,
                  height: bottomNavHeight,
                  child: Icon(
                    Icons.expand_more,
                    color: palette.isDark ? Colors.white : palette.textPrimary,
                    size: 20,
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

class _BottomNavCollapsedStrip extends StatelessWidget {
  const _BottomNavCollapsedStrip({
    required this.accent,
    required this.onExpand,
  });

  final Color accent;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    const collapsedBarHeight = 6.0;
    final foregroundColor = palette.isDark ? Colors.white : palette.textPrimary;
    final handleBackground = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.2 : 0.12),
      palette.surfaceSubtle.withValues(alpha: palette.isDark ? 0.9 : 1),
    );
    return AnimatedLibraryChromeGradient(
      accent: accent,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      borderBuilder: (animatedAccent, brightness) => Border(
        top: BorderSide(
          color: libraryChromeBorderColor(
            animatedAccent,
            brightness: brightness,
          ),
        ),
      ),
      child: SizedBox(
        height: collapsedBarHeight,
        child: Row(
          children: [
            const Spacer(),
            Tooltip(
              message: 'Show bottom navigation',
              child: InkWell(
                onTap: onExpand,
                child: SizedBox(
                  width: 44,
                  height: collapsedBarHeight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: handleBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.expand_less,
                      size: 6,
                      color: foregroundColor,
                    ),
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
