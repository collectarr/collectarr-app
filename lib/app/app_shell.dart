import 'package:collectarr_app/features/settings/backups/automatic_backup_controller.dart';
import 'dart:async';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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

import 'shell/app_shell_app_bar.dart';
import 'shell/app_navigation_drawer.dart';
import 'shell/app_navigation_model.dart';
import 'shell/app_shell_actions.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child, required this.routeUri});

  final Widget child;
  final Uri routeUri;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _didRequestInitialOnlineFirstSync = false;
  DrawerAction? _openDrawerAction;

  late final AppShellActions _actions = AppShellActions(
    ref: ref,
    shellContext: () => context,
    isMounted: () => mounted,
    selectedOverlay: () => _openDrawerAction,
    onSelectionChanged: (action) {
      if (mounted) setState(() => _openDrawerAction = action);
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRequestInitialOnlineFirstSync) {
        return;
      }
      _didRequestInitialOnlineFirstSync = true;
      ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled();
      ref.read(automaticBackupProvider.notifier).backUpIfDue();
    });
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeUri != widget.routeUri) _openDrawerAction = null;
  }

  DrawerAction? get _selectedDrawerAction =>
      _openDrawerAction ?? appDrawerActionForRoute(widget.routeUri.path);

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final catalog = ref.watch(mediaCatalogProvider).maybeWhen(
          data: (value) => value,
          orElse: () => fallbackMediaCatalog,
        );
    final navPreferences = ref.watch(libraryNavPreferencesProvider);
    final libraryTypes = selectableLibraryHomeTypes(catalog, navPreferences);
    final selectedKind = widget.routeUri.queryParameters['kind'] ??
        ref.watch<String>(selectedLibraryKindProvider);
    final activeLibrary = selectedLibraryHomeType(
      libraryTypes,
      canonicalLibraryNavKind(selectedKind) ?? selectedKind,
    ).kind;
    final activeKind = catalogMediaKindFromValue(activeLibrary);
    final activeType = defaultLibraryKindRegistry.require(activeKind);
    final accent = libraryAccentForKind(activeKind);
    final uiPreferences = ref.watch(uiPreferencesProvider);
    final mediaQuery = MediaQuery.maybeOf(context);
    final accentTheme = buildLibraryAccentTheme(Theme.of(context), accent);

    final shell = LibraryAccentScope(
      kind: activeLibrary,
      accent: accent,
      animationsEnabled: uiPreferences.animationsEnabled,
      child: Scaffold(
        appBar: AppShellAppBar(
          type: activeType,
          accent: accent,
          types: libraryTypes,
          animationsEnabled: uiPreferences.animationsEnabled,
          onKindSelected: (type) {
            ref.read(selectedLibraryKindProvider.notifier).select(type.kind);
            context.go(AppRoutes.forKind(AppRoutes.libraries, type.kind));
          },
          onOpenNavigation: () => unawaited(showAppNavigationDrawer(
            context: context,
            animationsEnabled: uiPreferences.animationsEnabled,
            type: activeType,
            selectedAction: _selectedDrawerAction,
            isAdmin: auth.isAdmin,
            accent: accent,
            onAddFromCore: (drawerContext, type) {
              Navigator.of(drawerContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                unawaited(_actions.handle(
                  DrawerAction.addFromCore,
                  type: type,
                  accent: libraryAccentForKind(type.kind),
                ));
              });
            },
            onSelected: (drawerContext, action) {
              Navigator.of(drawerContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                unawaited(_actions.handle(
                  action,
                  type: activeType,
                  accent: accent,
                ));
              });
            },
          )),
        ),
        body: Stack(
          children: [
            AnimatedTheme(
              data: accentTheme,
              duration: uiPreferences.animationsEnabled
                  ? kAppAnimNormal
                  : Duration.zero,
              curve: Curves.easeOutCubic,
              child: widget.child,
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
}
