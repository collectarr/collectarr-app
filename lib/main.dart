import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/ui/app_zoom.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CollectarrApp()));
}

class CollectarrApp extends ConsumerWidget {
  const CollectarrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Collectarr',
      theme: buildAppShellTheme(),
      builder: (context, child) => AppZoomWrapper(child: child!),
      routerConfig: router,
    );
  }
}
