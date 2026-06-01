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
import 'package:collectarr_app/ui/mobile_ux.dart';
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
  /// 0 = libraries, 1 = shelf, 2 = calendar, 3 = admin, 4 = settings
  static const _branchLibraries = 0;
  static const _branchShelf = 1;
  static const _branchCalendar = 2;
  static const _branchAdmin = 3;
  static const _branchSettings = 4;

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
    final showBottomNavigationBar =
      !ResponsiveLayout.isDesktop(context) ||
      currentBranch != _branchLibraries;
    final visibleBranches = [
      _branchLibraries,
      _branchShelf,
      _branchCalendar,
      if (isAdmin) _branchAdmin,
      _branchSettings,
    ];
    final selectedVisualIndex = visibleBranches.indexOf(currentBranch).clamp(0, visibleBranches.length - 1);

    final pages = [
      const _ShellPage(label: 'Libraries', icon: Icons.apps_outlined),
      const _ShellPage(label: 'Shelf', icon: Icons.inventory_2),
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
          duration: uiPreferences.animationsEnabled
              ? kAppAnimNormal
              : Duration.zero,
          curve: Curves.easeOutCubic,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: showBottomNavigationBar
          ? _LibraryAwareNavigationBar(
              pages: pages,
              selectedIndex: selectedVisualIndex,
              accent: accent,
              animationsEnabled: uiPreferences.animationsEnabled,
              onDestinationSelected: (visualIndex) {
                final branchIndex = visibleBranches[visualIndex];
                widget.navigationShell.goBranch(
                  branchIndex,
                  initialLocation:
                      branchIndex == widget.navigationShell.currentIndex,
                );
              },
            )
          : null,
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
        animationsEnabled ? kAppAnimNormal : Duration.zero;
    final palette = appPalette(context);
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: accent),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, color, child) {
        final animatedAccent = color ?? accent;
        final indicatorColor = palette.isDark
            ? animatedAccent.withValues(alpha: 0.52)
            : Color.alphaBlend(
                animatedAccent.withValues(alpha: 0.14),
                palette.selection,
              );
        final chromeTextColor =
            palette.isDark ? Colors.white : palette.textPrimary;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: libraryChromeGradient(
              animatedAccent,
              brightness: palette.brightness,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              top: BorderSide(
                color: libraryChromeBorderColor(
                  animatedAccent,
                  brightness: palette.brightness,
                ),
              ),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarTheme.of(context).copyWith(
              backgroundColor: Colors.transparent,
              indicatorColor: indicatorColor,
              height: 58,
              labelTextStyle: WidgetStatePropertyAll(
                TextStyle(
                  color: chromeTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              iconTheme: WidgetStatePropertyAll(
                IconThemeData(color: chromeTextColor, size: 20),
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
                            label: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            backgroundColor: Colors.deepOrange.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
