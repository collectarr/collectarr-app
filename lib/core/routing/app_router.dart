import 'package:collectarr_app/features/admin/admin_page.dart';
import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/features/collection/collection_page.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/detail/character_detail_page.dart';
import 'package:collectarr_app/features/library/detail/creator_detail_page.dart';
import 'package:collectarr_app/features/library/detail/library_detail_page.dart';
import 'package:collectarr_app/features/library/detail/series_detail_page.dart';
import 'package:collectarr_app/features/library/detail/story_arc_detail_page.dart';
import 'package:collectarr_app/features/library/home/home_page.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------

abstract final class AppRoutes {
  static const auth = '/auth';
  static const restoring = '/restoring';
  static const libraries = '/libraries';
  static const shelf = '/shelf';
  static const admin = '/admin';
  static const settings = '/settings';
  static const detail = '/detail';
  static const series = '/series/:seriesId';
  static const creator = '/creator/:name';
  static const character = '/character/:name';
  static const storyArc = '/story-arc/:name';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.libraries,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.isRestoring) {
        return location == AppRoutes.restoring ? null : AppRoutes.restoring;
      }
      if (!auth.isAuthenticated) {
        return location == AppRoutes.auth ? null : AppRoutes.auth;
      }
      // Authenticated — redirect away from auth/restoring screens.
      if (location == AppRoutes.auth || location == AppRoutes.restoring) {
        return AppRoutes.libraries;
      }
      // Non-admin trying to reach admin page.
      if (location == AppRoutes.admin && !auth.isAdmin) {
        return AppRoutes.libraries;
      }
      return null;
    },
    routes: [
      // Auth & restoring (outside shell).
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: AppRoutes.restoring,
        builder: (context, state) => const CollectarrRestoreScreen(),
      ),

      // Main shell with tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.libraries,
                builder: (context, state) => const LibraryHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shelf,
                builder: (context, state) => CollectionPage(
                  showOverdueOnly:
                      state.uri.queryParameters['filter'] == 'overdue',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.admin,
                builder: (context, state) => const AdminPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // Detail pages (outside shell — full-screen push).
      GoRoute(
        path: AppRoutes.detail,
        builder: (context, state) {
          final request = state.extra! as LibraryDetailPageRequest;
          final builder =
              request.type.detailPageBuilder ?? _buildDefaultDetailPage;
          return builder(context, request);
        },
      ),
      GoRoute(
        path: AppRoutes.series,
        builder: (context, state) => SeriesDetailPage(
          seriesId: state.pathParameters['seriesId']!,
          seriesTitle: state.uri.queryParameters['title'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.creator,
        builder: (context, state) => CreatorDetailPage(
          creatorName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.character,
        builder: (context, state) => CharacterDetailPage(
          characterName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.storyArc,
        builder: (context, state) => StoryArcDetailPage(
          storyArcName: Uri.decodeComponent(state.pathParameters['name']!),
        ),
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
    entry: request.entry,
    ownedItem: request.ownedItem,
    accent: request.accent,
    onAddOwned: request.onAddOwned,
    onRemoveOwned: request.onRemoveOwned,
    onAddWishlist: request.onAddWishlist,
    onRemoveWishlist: request.onRemoveWishlist,
    onEdit: request.onEdit,
    onFilterByValue: request.onFilterByValue,
  );
}

// ---------------------------------------------------------------------------
// Auth-state → ChangeNotifier bridge for GoRouter.refreshListenable
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
