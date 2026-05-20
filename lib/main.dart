import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:collectarr_app/ui/app_zoom.dart';
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
      builder: (context, child) => AppZoomWrapper(child: child!),
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
  const selection = Color(0xFF075F75);
  const yellow = Color(0xFFFFD400);
  const divider = Color(0xFF4A4A4A);
  const muted = Color(0xFFB8B8B8);
  const field = Color(0xFF101010);
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    surface: panel,
  );
  return base.copyWith(
    visualDensity: VisualDensity.compact,
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
    canvasColor: canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: topBar,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 42,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: toolbar,
      indicatorColor: selection,
      height: 58,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
      iconTheme: const WidgetStatePropertyAll(
        IconThemeData(color: Colors.white, size: 20),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: panel,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
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
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(panelRaised),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: field,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      labelStyle: TextStyle(color: muted),
      hintStyle: TextStyle(color: muted),
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
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF343434),
        disabledForegroundColor: const Color(0xFF777777),
        disabledBackgroundColor: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        visualDensity: VisualDensity.compact,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? selection : toolbar;
        }),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        side: const WidgetStatePropertyAll(BorderSide(color: divider)),
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      dividerColor: divider,
      indicatorColor: accent,
      labelColor: Colors.white,
      unselectedLabelColor: muted,
      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      unselectedLabelStyle:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: const WidgetStatePropertyAll(field),
      hintStyle: const WidgetStatePropertyAll(TextStyle(color: muted)),
      textStyle: const WidgetStatePropertyAll(TextStyle(color: Colors.white)),
      elevation: const WidgetStatePropertyAll(0),
      padding:
          const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          side: const BorderSide(color: divider),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF343434),
      selectedColor: selection,
      labelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(toolbar),
      dataRowColor: WidgetStatePropertyAll(panel),
      dividerThickness: 1,
      headingTextStyle:
          TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      dataTextStyle: TextStyle(color: Colors.white),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: panelRaised,
        border: Border.all(color: divider),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
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
      return const CollectarrRestoreScreen();
    }
    return auth.isAuthenticated ? const AppShell() : const AuthPage();
  }
}
