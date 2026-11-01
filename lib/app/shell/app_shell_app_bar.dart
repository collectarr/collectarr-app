import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'app_library_search_bar.dart';
import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/generic/mobile_search_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_shell_brand.dart';
import 'app_account_button.dart';
import 'package:collectarr_app/ui/app_chrome.dart';

import 'package:collectarr_app/features/library/home/kind_menu.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/app/shell/app_update_header_button.dart';
import 'package:collectarr_app/features/sync/presentation/sync_action_button.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';

import 'package:collectarr_app/core/api/dto/media_catalog.dart';

class AppShellAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppShellAppBar(
      {super.key,
      required this.type,
      required this.accent,
      required this.types,
      required this.animationsEnabled,
      required this.onKindSelected,
      required this.onOpenNavigation,
      this.showLibrarySearch = false});
  final LibraryKindRegistration type;
  final Color accent;
  final List<CatalogMediaType> types;
  final bool animationsEnabled;
  final ValueChanged<CatalogMediaType> onKindSelected;
  final VoidCallback onOpenNavigation;
  final bool showLibrarySearch;
  @override
  Size get preferredSize => Size.fromHeight(appShellBarHeight);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolbarIconStyle = appChromeIconButtonStyle(context);
    final nativeSearch =
        appPresentationPlatform.isNativeMobile && showLibrarySearch;
    final searchOpen = nativeSearch &&
        ref.watch(mobileLibrarySearchProvider(type.kind.apiValue));
    final search = nativeSearch
        ? ref.read(mobileLibrarySearchProvider(type.kind.apiValue).notifier)
        : null;
    if (searchOpen) {
      return AppLibrarySearchBar(
          controller: search!,
          kind: type.kind.apiValue,
          pluralLabel: type.identity.pluralLabel,
          accent: accent,
          animationsEnabled: animationsEnabled,
          searchBackground: type.identity.mobileChromeDark);
    }

    return AppBar(
      toolbarHeight: appShellBarHeight,
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
      iconTheme: IconThemeData(
          color: Colors.white,
          size: appPresentationPlatform.isNativeMobile ? 24 : 19),
      flexibleSpace: Stack(fit: StackFit.expand, children: [
        LibraryAccentChrome(
          accent: accent,
          animationDuration: animationsEnabled ? kAppAnimNormal : Duration.zero,
        ),
        if (!appPresentationPlatform.isNativeMobile)
          Center(child: _AccountLibraryLabel(kindTitle: type.identity.title)),
      ]),
      actions: [
        MediaLibraryKindMenu(
          types: types,
          registry: defaultLibraryKindRegistry,
          onSelected: onKindSelected,
        ),
        if (!appPresentationPlatform.isNativeMobile)
          SyncActionButton(style: toolbarIconStyle),
        AppUpdateHeaderButton(style: toolbarIconStyle, kind: type.kind),
        if (!appPresentationPlatform.isNativeMobile)
          AppAccountButton(
              style: toolbarIconStyle,
              kind: type.kind.apiValue,
              animationsEnabled: animationsEnabled),
        if (nativeSearch) ...[
          IconButton(
              tooltip: 'Select ${type.identity.pluralLabel.toLowerCase()}',
              style: toolbarIconStyle,
              onPressed: search!.toggleSelection,
              icon: const Icon(Icons.library_add_check_outlined)),
          PopupMenuButton<LibraryCollectionStatusScope>(
              tooltip: 'Collection status',
              style: toolbarIconStyle,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onSelected: search.setStatus,
              itemBuilder: (_) => [
                    for (final status in LibraryCollectionStatusScope.values)
                      CheckedPopupMenuItem(
                          value: status,
                          checked: status == search.status,
                          child: Text(status.label))
                  ]),
        ],
        if (nativeSearch)
          IconButton(
              key: const Key('app.open-search'),
              tooltip: 'Search library',
              style: toolbarIconStyle,
              onPressed: search!.open,
              icon: const Icon(Icons.search)),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// "account's music", centered like the reference, while signed in to the
/// optional Sync account; nothing for a local-only library.
class _AccountLibraryLabel extends ConsumerWidget {
  const _AccountLibraryLabel({required this.kindTitle});

  final String kindTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authControllerProvider
        .select((s) => s.isAuthenticated ? s.email : null));
    final account = email?.split('@').first.trim();
    if (account == null || account.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: Text("$account's ${kindTitle.toLowerCase()}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400)),
    );
  }
}
