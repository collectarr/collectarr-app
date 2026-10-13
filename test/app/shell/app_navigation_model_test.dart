import 'package:collectarr_app/app/shell/app_navigation_model.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each action has one destination and route selection is unambiguous',
      () {
    final actions =
        appDrawerDestinations.map((destination) => destination.action);
    expect(actions.toSet(), DrawerAction.values.toSet());
    expect(actions.length, actions.toSet().length);
    final routes = appDrawerDestinations
        .map((destination) => destination.routePath)
        .whereType<String>();
    expect(routes.length, routes.toSet().length);
    expect(appDrawerActionForRoute(AppRoutes.loans), DrawerAction.loanManager);
    expect(appDrawerActionForRoute(AppRoutes.settings), DrawerAction.settings);
    expect(appDrawerActionForRoute('/unknown'), isNull);
    expect(
        appDrawerDestination(DrawerAction.statistics).resetsToLibrary, isTrue);
    expect(
        appDrawerDestination(DrawerAction.exportXml).resetsToLibrary, isFalse);
    expect(appDrawerDestination(DrawerAction.admin).adminOnly, isTrue);
  });
}
