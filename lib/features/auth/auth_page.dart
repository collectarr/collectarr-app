import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Collectarr')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (auth.error != null)
                  Text(auth.error!, style: const TextStyle(color: Colors.red)),
                FilledButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () {
                          final email = emailController.text.trim();
                          final password = passwordController.text;
                          if (isRegister) {
                            ref
                                .read(authControllerProvider.notifier)
                                .register(email, password);
                          } else {
                            ref
                                .read(authControllerProvider.notifier)
                                .login(email, password);
                          }
                        },
                  icon: Icon(isRegister ? Icons.person_add : Icons.login),
                  label: Text(isRegister ? 'Register' : 'Login'),
                ),
                TextButton(
                  onPressed: () => setState(() => isRegister = !isRegister),
                  child: Text(
                      isRegister ? 'Use existing account' : 'Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
