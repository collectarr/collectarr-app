import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Native mobile chrome: full content viewport without persistent rail or navigation bar;
/// destinations are accessible via the collapsible drawer sidebar.
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.appBar,
    required this.body,
    required this.systemUiStyle,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final SystemUiOverlayStyle systemUiStyle;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiStyle,
        child: Scaffold(
          key: const Key('app.mobile-shell'),
          resizeToAvoidBottomInset: false,
          appBar: appBar,
          body: body,
        ),
      );
}
