import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CollectarrApp()));
}

class CollectarrApp extends StatelessWidget {
  const CollectarrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collectarr',
      theme: _collectarrDarkTheme(),
      home: const AuthGate(),
    );
  }
}

ThemeData _collectarrDarkTheme() {
  const topBar = Color(0xFF4DBBD5);
  const toolbar = Color(0xFF2B2B2B);
  const panel = Color(0xFF1D1D1D);
  const panelRaised = Color(0xFF2F2F2F);
  const canvas = Color(0xFF141414);
  const accent = Color(0xFF10A8D8);
  const yellow = Color(0xFFFFD400);
  const divider = Color(0xFF4A4A4A);
  const muted = Color(0xFFB8B8B8);
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    surface: panel,
  );
  return base.copyWith(
    colorScheme: scheme.copyWith(
      primary: accent,
      secondary: yellow,
      surface: panel,
      surfaceContainerLowest: canvas,
      surfaceContainerLow: panel,
      surfaceContainer: toolbar,
      surfaceContainerHigh: panelRaised,
      surfaceContainerHighest: const Color(0xFF3A3A3A),
      outline: divider,
      outlineVariant: const Color(0xFF373737),
    ),
    scaffoldBackgroundColor: canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: topBar,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: toolbar,
      indicatorColor: const Color(0xFF075F75),
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      iconTheme: const WidgetStatePropertyAll(
        IconThemeData(color: Colors.white),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: panel,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: divider),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: panelRaised,
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(color: Colors.white),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF101010),
      isDense: true,
      labelStyle: TextStyle(color: muted),
      border: OutlineInputBorder(borderSide: BorderSide(color: divider)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: divider)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: accent)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accent),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF343434),
      selectedColor: const Color(0xFF075F75),
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: panelRaised,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth.isRestoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isAuthenticated ? const AppShell() : const AuthPage();
  }
}
