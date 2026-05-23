import 'package:collectarr_app/features/auth/auth_page.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_shell.dart';
import 'package:collectarr_app/ui/app_zoom.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
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
      theme: buildAppShellTheme(),
      builder: (context, child) => AppZoomWrapper(child: child!),
      home: const AuthGate(),
    );
  }
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
