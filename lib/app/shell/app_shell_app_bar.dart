import 'app_shell_brand.dart';
import 'package:collectarr_app/ui/app_chrome.dart';

import 'package:collectarr_app/features/library/home/home_kind_menu.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/sync/presentation/sync_action_button.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';

import 'package:collectarr_app/core/api/dto/media_catalog.dart';

class AppShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppShellAppBar(
      {super.key,
      required this.type,
      required this.accent,
      required this.types,
      required this.animationsEnabled,
      required this.onKindSelected,
      required this.onOpenNavigation,
      required this.onSettings});
  final LibraryKindRegistration type;
  final Color accent;
  final List<CatalogMediaType> types;
  final bool animationsEnabled;
  final ValueChanged<CatalogMediaType> onKindSelected;
  final VoidCallback onSettings;
  final VoidCallback onOpenNavigation;
  @override
  Size get preferredSize => const Size.fromHeight(shellAppBarHeight);
  @override
  Widget build(BuildContext context) {
    final toolbarIconStyle = appChromeIconButtonStyle(context);
    return AppBar(
      toolbarHeight: shellAppBarHeight,
      automaticallyImplyLeading: false,
      leadingWidth: 44,
      leading: Builder(
        builder: (context) => IconButton(
          key: const Key('app.open-navigation'),
          tooltip: 'Open navigation',
          visualDensity: VisualDensity.compact,
          style: toolbarIconStyle,
          onPressed: onOpenNavigation,
          icon: const Icon(AppIcons.menu),
        ),
      ),
      titleSpacing: 2,
      title: AppShellBrand(
        icon: type.identity.icon,
        kindTitle: type.identity.title,
        iconKey: const Key('app.kind-icon'),
        titleKey: const Key('app.brand-title'),
      ),
      backgroundColor: libraryAccentChromeFallbackColor(accent),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: Colors.white, size: 19),
      flexibleSpace: LibraryAccentChrome(
        accent: accent,
        animationDuration: animationsEnabled ? kAppAnimNormal : Duration.zero,
      ),
      actions: [
        MediaLibraryKindMenu(
          types: types,
          registry: defaultLibraryKindRegistry,
          onSelected: onKindSelected,
        ),
        SyncActionButton(style: toolbarIconStyle),
        IconButton(
          key: const Key('nav.settings'),
          tooltip: 'Settings',
          visualDensity: VisualDensity.compact,
          style: toolbarIconStyle,
          onPressed: onSettings,
          icon: const Icon(AppIcons.settings),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
