import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_management_content.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// A local overview across every library, available without a cloud account.
class MyAccountPage extends ConsumerWidget {
  const MyAccountPage({super.key, this.kind});
  final String? kind;

  String _route(String path, {String? section}) =>
      Uri(path: path, queryParameters: {
        if (kind != null) 'kind': kind!,
        if (section != null) 'section': section
      }).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final shelf = ref.watch(shelfProvider);
    final sync = ref.watch(syncControllerProvider);
    final palette = appPalette(context);
    return Theme(
        data: buildLibraryAccentTheme(Theme.of(context), palette.utilityAction),
        child: Scaffold(
          appBar: const AppPageHeader(
              title: Text('My Account'), icon: AppIcons.user),
          body: AppManagementContent(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsPanel(
                      icon: AppIcons.user,
                      title: auth.isAuthenticated
                          ? auth.email ?? 'My Account'
                          : 'Local library',
                      child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(auth.isAuthenticated
                                ? (auth.isAdmin ? 'Administrator' : 'Signed in')
                                : 'Your collection is available without signing in.'),
                            TextButton(
                                onPressed: () => context.go(_route(
                                    AppRoutes.settings,
                                    section: 'account')),
                                child: const Text('Account settings')),
                            if (!auth.isAuthenticated)
                              TextButton.icon(
                                  onPressed: () => context.go(AppRoutes.auth),
                                  icon: const Icon(AppIcons.login, size: 14),
                                  label: const Text('Sign in')),
                          ])),
                  const SizedBox(height: 20),
                  shelf.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Column(children: [
                      const Text('Could not load your library overview.'),
                      TextButton(
                          onPressed: () => ref.invalidate(shelfProvider),
                          child: const Text('Try again')),
                    ]),
                    data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Library totals on this device',
                              style: TextStyle(color: palette.textMuted)),
                          const SizedBox(height: 10),
                          LayoutBuilder(builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 700
                                ? 4
                                : constraints.maxWidth >= 300
                                    ? 2
                                    : 1;
                            final width =
                                (constraints.maxWidth - (columns - 1) * 12) /
                                    columns;
                            return Wrap(spacing: 12, runSpacing: 12, children: [
                              for (final metric in [
                                ('Items', data.entryCount),
                                ('Wishlist', data.wishlistCount),
                                ('Sold', data.soldCount),
                                ('Pending sync', sync.pendingCount),
                              ])
                                SizedBox(
                                    width: width,
                                    child: Material(
                                        color: palette.panel,
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('${metric.$2}',
                                                      style: const TextStyle(
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                  Text(metric.$1,
                                                      style: TextStyle(
                                                          color: palette
                                                              .textSecondary)),
                                                ])))),
                            ]);
                          }),
                          const SizedBox(height: 24),
                          SettingsPanel(
                              icon: AppIcons.libraries,
                              title: 'Libraries',
                              child: Column(children: [
                                const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Row(children: [
                                      Expanded(child: Text('Library')),
                                      SizedBox(
                                          width: 70,
                                          child: Text('Items',
                                              textAlign: TextAlign.right)),
                                      SizedBox(
                                          width: 70,
                                          child: Text('Wishlist',
                                              textAlign: TextAlign.right)),
                                      SizedBox(width: 24)
                                    ])),
                                for (final library
                                    in defaultLibraryKindRegistry.allKinds)
                                  InkWell(
                                      onTap: () => context.go(AppRoutes.forKind(
                                          AppRoutes.libraries,
                                          library.kind.apiValue)),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: Row(children: [
                                            if (library.identity
                                                    .collectionIconSvgAsset
                                                case final asset?)
                                              SvgPicture.asset(asset,
                                                  width: 18,
                                                  height: 18,
                                                  colorFilter: ColorFilter.mode(
                                                      library.identity.accent,
                                                      BlendMode.srcIn))
                                            else
                                              Icon(library.identity.icon,
                                                  size: 18,
                                                  color:
                                                      library.identity.accent),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child: Text(
                                                    library.identity.isTopLevel
                                                        ? library.identity.title
                                                        : library.identity
                                                            .pluralLabel)),
                                            SizedBox(
                                                width: 70,
                                                child: Text(
                                                    '${data.libraryEntryCountByKind[library.kind.apiValue] ?? 0}',
                                                    textAlign:
                                                        TextAlign.right)),
                                            SizedBox(
                                                width: 70,
                                                child: Text(
                                                    '${data.wishlistItemCountByKind[library.kind.apiValue] ?? 0}',
                                                    textAlign:
                                                        TextAlign.right)),
                                            const SizedBox(width: 10),
                                            Icon(AppIcons.chevronRight,
                                                size: 14, color: palette.link),
                                          ]))),
                              ])),
                        ]),
                  ),
                  const SizedBox(height: 24),
                  SettingsPanel(
                      icon: AppIcons.sync,
                      title: 'Sync & activity',
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sync.isSyncing
                                ? 'Syncing…'
                                : sync.isOffline
                                    ? 'Offline'
                                    : 'Ready to sync'),
                            const SizedBox(height: 6),
                            Text(
                                sync.lastSyncedAt == null
                                    ? 'No sync completed yet'
                                    : 'Last synced ${formatSettingsTime(sync.lastSyncedAt!)}',
                                style: TextStyle(color: palette.textSecondary)),
                            const SizedBox(height: 10),
                            Wrap(spacing: 8, runSpacing: 8, children: [
                              TextButton.icon(
                                  onPressed: () =>
                                      context.go(_route(AppRoutes.activity)),
                                  icon: const Icon(AppIcons.history, size: 14),
                                  label: const Text('Activity')),
                              TextButton.icon(
                                  onPressed: () => context.go(_route(
                                      AppRoutes.settings,
                                      section: 'connection')),
                                  icon: const Icon(AppIcons.plug, size: 14),
                                  label: const Text('Connection settings')),
                            ]),
                          ])),
                ]),
          )),
        ));
  }
}
