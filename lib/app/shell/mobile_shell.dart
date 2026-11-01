import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'app_navigation_model.dart';

/// Native phone and tablet share destinations; local width chooses bar or rail.
class MobileShell extends StatelessWidget {
  const MobileShell(
      {super.key,
      required this.appBar,
      required this.body,
      required this.routeUri,
      required this.onDestinationSelected,
      required this.onMore});
  final PreferredSizeWidget appBar;
  final Widget body;
  final Uri routeUri;
  final ValueChanged<AppDrawerDestination> onDestinationSelected;
  final VoidCallback onMore;
  @override
  Widget build(BuildContext context) {
    final destinations = [
      for (final action in appMobilePrimaryActions) appDrawerDestination(action)
    ];
    final selected =
        destinations.indexWhere((item) => item.routePath == routeUri.path);
    final index = selected < 0 ? destinations.length : selected;
    void select(int value) => value == destinations.length
        ? onMore()
        : onDestinationSelected(destinations[value]);
    final color = appPalette(context).utilityAction;
    return LayoutBuilder(builder: (context, constraints) {
      final rail = constraints.maxWidth >= 840;
      return Scaffold(
          key: const Key('app.mobile-shell'),
          resizeToAvoidBottomInset: false,
          appBar: appBar,
          bottomNavigationBar: rail
              ? null
              : NavigationBar(
                  key: const Key('app.mobile-navigation'),
                  selectedIndex: index,
                  indicatorColor: color.withValues(alpha: .2),
                  onDestinationSelected: select,
                  destinations: [
                      for (final destination in destinations)
                        NavigationDestination(
                            icon: Icon(destination.icon),
                            label: destination.label),
                      const NavigationDestination(
                          icon: Icon(Icons.more_horiz), label: 'More')
                    ]),
          body: rail
              ? Row(children: [
                  NavigationRail(
                      key: const Key('app.mobile-rail'),
                      selectedIndex: index,
                      labelType: NavigationRailLabelType.all,
                      indicatorColor: color.withValues(alpha: .2),
                      onDestinationSelected: select,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                              icon: Icon(destination.icon),
                              label: Text(destination.label)),
                        const NavigationRailDestination(
                            icon: Icon(Icons.more_horiz), label: Text('More'))
                      ]),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ])
              : body);
    });
  }
}
