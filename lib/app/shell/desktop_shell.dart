import 'package:flutter/material.dart';

/// Desktop/web chrome stays independent from native navigation and width classes.
class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key, required this.appBar, required this.body});
  final PreferredSizeWidget appBar;
  final Widget body;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: appBar, body: body);
}
