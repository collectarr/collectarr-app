import 'package:flutter/material.dart';
import 'app_navigation_model.dart';

/// Native mobile chrome: full content viewport without persistent rail or navigation bar;
/// destinations are accessible via the collapsible drawer sidebar.
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.appBar,
    required this.body,
    required this.routeUri,
    required this.onDestinationSelected,
    required this.onMore,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Uri routeUri;
  final ValueChanged<AppDrawerDestination> onDestinationSelected;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: const Key('app.mobile-shell'),
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: body,
      );
}
