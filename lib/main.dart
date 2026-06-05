import 'dart:async';

import 'package:collectarr_app/core/logging/app_log.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/dev/dev_seed.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/theme_mode_provider.dart';
import 'package:collectarr_app/ui/app_zoom.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';

const _interFontAsset = 'assets/fonts/Inter-Variable.ttf';
const _monoFontAsset = 'assets/fonts/JetBrainsMono-Variable.ttf';

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

      // Register per-kind LibraryAdd builders so the generic add dialog
      // can discover custom panes at runtime.
      registerLibraryAddBuilders();
      await _logFontDiagnostics(container!);

      if (kDebugMode && kIsWeb) {
        await seedLocalDatabase(container!.read(localDatabaseProvider));
      }

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
  final interLoaded = await _fontAssetAvailable(logger, _interFontAsset);
  final monoLoaded = await _fontAssetAvailable(logger, _monoFontAsset);
  final details = <String>[
    'primaryFamily=$kClzPrimaryFontFamily',
    'primaryFallback=${kClzFontFallback.join(', ')}',
    'primaryAsset=$_interFontAsset:${interLoaded ? 'loaded' : 'missing'}',
    'monoFamily=$kClzMonospaceFontFamily',
    'monoFallback=${kClzMonospaceFontFallback.join(', ')}',
    'monoAsset=$_monoFontAsset:${monoLoaded ? 'loaded' : 'missing'}',
  ].join(' | ');
  if (interLoaded && monoLoaded) {
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
    final palette = paletteForThemeMode(themeMode);
    return MaterialApp.router(
      title: 'Collectarr',
      theme: buildAppShellTheme(palette: palette),
      builder: (context, child) => AppZoomWrapper(child: child!),
      routerConfig: router,
    );
  }
}
