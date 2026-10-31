import 'package:collectarr_app/features/activity/global_activity_page.dart';
import 'package:collectarr_app/features/account/my_account_page.dart';
import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/features/calendar/calendar_page.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/loans/loan_add_page.dart';
import 'package:collectarr_app/features/loans/loan_manager_page.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/detail/page.dart';
import 'package:collectarr_app/features/library/home/page.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_routes.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/app/app_shell.dart';
import 'package:collectarr_app/core/routing/app_route_page.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
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

final appPageNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(notifier.dispose);
  // Pages opened with openPage show their own address in the browser.
  GoRouter.optionURLReflectsImperativeAPIs = true;

  return GoRouter(
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
                )),
          ),
          // Full-page item details retain the shared application chrome.
          GoRoute(
            path: AppRoutes.detail,
            redirect: (context, state) {
              return state.extra is LibraryDetailPageRequest
                  ? null
                  : AppRoutes.libraries;
            },
            pageBuilder: (context, state) {
              final request = state.extra as LibraryDetailPageRequest?;
              final Widget child;
              if (request == null) {
                child = LibraryHomePage(routeUri: state.uri);
              } else {
                child = _buildDefaultDetailPage(context, request);
              }
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: request == null
                    ? child
                    : Scaffold(
                        appBar: AppPageHeader(
                          title: Text(request.item.source.title),
                          icon: request.type.identity.icon,
                        ),
                        body: child,
                      ),
                transitionDuration: const Duration(milliseconds: 150),
                reverseTransitionDuration: const Duration(milliseconds: 120),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    ),
                    child: child,
                  );
                },
              );
            },
          ),
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

Widget _buildDefaultDetailPage(
  BuildContext context,
  LibraryDetailPageRequest request,
) {
  return LibraryDetailPage(
    type: request.type,
    item: request.item,
    libraryEntrySummary: request.libraryEntrySummary,
    libraryEntryDispatch: request.libraryEntryDispatch,
    projection: request.projection,
    searchQuery: request.searchQuery,
    searchTarget: request.searchTarget,
    onDetailsLayoutChanged: request.onDetailsLayoutChanged,
    accent: request.accent,
    onAddEntry: request.onAddEntry,
    onRemoveEntry: request.onRemoveEntry,
    onAddWishlist: request.onAddWishlist,
    onRemoveWishlist: request.onRemoveWishlist,
    onEdit: request.onEdit,
    onFilterByValue: request.onFilterByValue,
  );
}

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
