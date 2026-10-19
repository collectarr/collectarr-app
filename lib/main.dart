import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/core/localization/app_formats.dart';
import 'dart:async';

import 'package:collectarr_app/core/fonts/local_font_controller.dart';
import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:collectarr_app/ui/app_zoom.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _fallbackFontAsset = 'assets/fonts/PlusJakartaSans-Regular.ttf';

void main() {
  ProviderContainer? container;
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();

      // Capture Flutter framework errors.
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        container?.read(appLogProvider.notifier).error(
              'flutter',
              details.exceptionAsString(),
              detail: details.stack?.toString(),
            );
      };

      await LocalFontController.instance.initialize();
      await loadStartupThemeMode();
      await _logFontDiagnostics(container!);

      runApp(
        UncontrolledProviderScope(
          container: container!,
          child: const CollectarrApp(),
        ),
      );
    },
    (error, stack) {
      final activeContainer = container;
      if (activeContainer == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'zone',
            context: ErrorDescription('while bootstrapping Collectarr'),
          ),
        );
        return;
      }
      activeContainer.read(appLogProvider.notifier).error(
            'zone',
            error.toString(),
            detail: stack.toString(),
          );
    },
  );
}

Future<void> _logFontDiagnostics(ProviderContainer container) async {
  final logger = container.read(appLogProvider.notifier);
  final fallbackLoaded = await _fontAssetAvailable(logger, _fallbackFontAsset);
  final gilroyLoaded = LocalFontController.instance.isGilroyActive;
  final details = <String>[
    'requestedFamily=$kAppFontFamily | activeFamily=$appFontFamily',
    'gilroyActive=$gilroyLoaded'
        ' weights=${LocalFontController.instance.faces.keys.join(',')}',
    'primaryFallback=${kAppFontFamilyFallback.isEmpty ? 'none' : kAppFontFamilyFallback.join(', ')}',
    'fallbackAsset=$_fallbackFontAsset:${fallbackLoaded ? 'loaded' : 'missing'}',
  ].join(' | ');
  if (LocalFontController.instance.startupError case final error?) {
    logger.warn('fonts', error);
  }
  if (fallbackLoaded || gilroyLoaded) {
    logger.info('fonts', 'Font assets loaded', detail: details);
    return;
  }
  logger.warn('fonts', 'Font asset missing, fallback likely', detail: details);
}

Future<bool> _fontAssetAvailable(
    AppLogNotifier logger, String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } on FlutterError catch (error) {
    logger.warn(
      'fonts',
      'Failed to load font asset',
      detail: '$assetPath | $error',
    );
    return false;
  } catch (error) {
    logger.warn(
      'fonts',
      'Unexpected error loading font asset',
      detail: '$assetPath | $error',
    );
    return false;
  }
}

class CollectarrApp extends ConsumerWidget {
  const CollectarrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    // Settings > Localization formats are read synchronously by formatters
    // across the app, so a change rebuilds every element once.
    AppFormats.current = ref.read(uiPreferencesProvider).formats;
    ref.listen(uiPreferencesProvider.select((p) => p.formats), (_, formats) {
      AppFormats.current = formats;
      WidgetsBinding.instance.reassembleApplication();
    });
    final palette = paletteForThemeMode(themeMode);
    return ListenableBuilder(
      listenable: LocalFontController.instance,
      builder: (context, _) => MaterialApp.router(
        title: 'Collectarr',
        debugShowCheckedModeBanner: false,
        theme: buildAppShellTheme(palette: palette),
        builder: (context, child) => AppZoomWrapper(child: child!),
        routerConfig: router,
      ),
    );
  }
}
