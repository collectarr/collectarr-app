import 'dart:async';

import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:collectarr_app/ui/app_zoom.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';

void main() {
  final container = ProviderContainer();

  // Capture Flutter framework errors.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    container.read(appLogProvider.notifier).error(
          'flutter',
          details.exceptionAsString(),
          detail: details.stack?.toString(),
        );
  };

  // Capture uncaught async errors.
  runZonedGuarded(
    () {
      // Register per-kind LibraryAdd builders so the generic add dialog
      // can discover custom panes at runtime.
      registerLibraryAddBuilders();

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const CollectarrApp(),
        ),
      );
    },
    (error, stack) {
      container.read(appLogProvider.notifier).error(
            'zone',
            error.toString(),
            detail: stack.toString(),
          );
    },
  );
}

class CollectarrApp extends ConsumerWidget {
  const CollectarrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final palette = paletteForThemeMode(themeMode);
    return MaterialApp.router(
      title: 'Collectarr',
      theme: buildAppShellTheme(palette: palette),
      builder: (context, child) => AppZoomWrapper(child: child!),
      routerConfig: router,
    );
  }
}
