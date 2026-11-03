import 'package:collectarr_app/ui/adaptive/platform_layout.dart';
import 'package:collectarr_app/features/library/detail/route_page.dart';
import 'package:collectarr_app/features/activity/global_activity_page.dart';
import 'package:collectarr_app/features/account/my_account_page.dart';
import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/features/calendar/calendar_page.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/loans/loan_add_page.dart';
import 'package:collectarr_app/features/loans/loan_manager_page.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/home/page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_routes.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/routing/app_route_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------

abstract final class AppRoutes {
  static const auth = '/auth';
  static const account = '/account';
  static const restoring = '/restoring';
  static const libraries = '/libraries';
  static const loans = '/loans';
  static const loanAdd = '/loans/add';
  static String forKind(String path, String kind,
          {Map<String, String> parameters = const {}}) =>
      Uri(path: path, queryParameters: {...parameters, 'kind': kind})
          .toString();
  static String loansForKind(CatalogMediaKind kind) =>
      forKind(loans, kind.apiValue);
  static const calendar = '/calendar';
  static const activity = '/activity';
  static const admin = '/admin';
  static const settings = '/settings';
  static const detail = '/detail';
}

extension AppPageNavigation on BuildContext {
  /// Opens a page over the current one, so its Back pops it with the page
  /// transition; going to a route replaces the stack without one. A page
  /// already on top is replaced in place instead of stacked again.
  void openPage(String location) {
    final router = GoRouter.of(this);
    final current = router.routerDelegate.currentConfiguration.uri.path;
    if (Uri.parse(location).path == current) {
      router.replace<void>(location);
    } else {
      router.push<void>(location);
    }
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final appRootNavigatorKey = GlobalKey<NavigatorState>();

final appPageNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(notifier.dispose);
  // Pages opened with openPage show their own address in the browser.
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final detailRoute = GoRoute(
      path: AppRoutes.detail,
      pageBuilder: (context, state) => appRoutePage(
          state,
          RestorableLibraryDetailPage(
              uri: state.uri,
              hint: state.extra is LibraryDetailPageRequest
                  ? state.extra as LibraryDetailPageRequest
                  : null)));
  return GoRouter(
    navigatorKey: appRootNavigatorKey,
    restorationScopeId: 'collectarr-router',
    initialLocation: AppRoutes.libraries,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.isRestoring) {
        return location == AppRoutes.restoring ? null : AppRoutes.restoring;
      }
      if (location == AppRoutes.restoring) {
        return AppRoutes.libraries;
      }
      if (location == AppRoutes.auth && auth.isAuthenticated) {
        return AppRoutes.libraries;
      }
      // Non-admin trying to reach admin-only system pages.
      // The /admin page itself is accessible to all authenticated
      // users for catalog search, proposals, and corrections.
      return null;
    },
    routes: [
      if (appPresentationPlatform.isNativeMobile) detailRoute,
      // Auth & restoring (outside shell).
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => appRoutePage(state, const AuthPage()),
      ),
      GoRoute(
        path: AppRoutes.restoring,
        pageBuilder: (context, state) =>
            appRoutePage(state, const CollectarrRestoreScreen()),
      ),

      ShellRoute(
        navigatorKey: appPageNavigatorKey,
        builder: (context, state, child) => AppShell(
          routeUri: state.uri,
          child: child,
        ),
        routes: [
          GoRoute(
              path: AppRoutes.account,
              pageBuilder: (context, state) => appRoutePage(state,
                  MyAccountPage(kind: state.uri.queryParameters['kind']))),
          GoRoute(
            path: AppRoutes.libraries,
            pageBuilder: (context, state) =>
                appRoutePage(state, LibraryHomePage(routeUri: state.uri)),
          ),
          GoRoute(
            path: AppRoutes.loans,
            pageBuilder: (context, state) => appRoutePage(
                state,
                LoanManagerPage(
                  kind: state.uri.queryParameters['kind'] == null
                      ? null
                      : catalogMediaKindFromApiValue(
                          state.uri.queryParameters['kind']!),
                )),
          ),
          GoRoute(
            path: AppRoutes.loanAdd,
            redirect: (context, state) =>
                state.extra is LoanAddRequest ? null : AppRoutes.libraries,
            pageBuilder: (context, state) => appRoutePage(
                state, LoanAddPage(request: state.extra! as LoanAddRequest)),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (context, state) =>
                appRoutePage(state, const CalendarPage()),
          ),
          GoRoute(
            path: AppRoutes.admin,
            pageBuilder: (context, state) =>
                appRoutePage(state, const AdminPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => appRoutePage(
                state,
                SettingsPage(
                  initialSection: settingsSectionFromRouteValue(
                    state.uri.queryParameters['section'],
                  ),
                  initialKind: state.uri.queryParameters['settingsKind'],
                )),
          ),
          if (!appPresentationPlatform.isNativeMobile) detailRoute,
          GoRoute(
            path: AppRoutes.activity,
            pageBuilder: (context, state) =>
                appRoutePage(state, const GlobalActivityPage()),
          ),
          ...collectarrKindRoutes,
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Auth-state Ã¢â€ â€™ ChangeNotifier bridge for GoRouter.refreshListenable
// ---------------------------------------------------------------------------

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _sub = _ref.listen(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
