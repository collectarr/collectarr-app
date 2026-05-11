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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6F73)),
        useMaterial3: true,
      ),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isAuthenticated ? const AppShell() : const AuthPage();
  }
}
