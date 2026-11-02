import 'package:flutter/material.dart';

/// Native mobile chrome: full content viewport without persistent rail or navigation bar;
/// destinations are accessible via the collapsible drawer sidebar.
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.appBar,
    required this.body,
  });

  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: const Key('app.mobile-shell'),
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: body,
      );
}
