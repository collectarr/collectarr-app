import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _authTopBar = Color(0xFF4DBBD5);
const Color _authCanvas = Color(0xFF141414);
const Color _authPanel = Color(0xFF202020);
const Color _authPanelRaised = Color(0xFF2D2D2D);
const Color _authAccent = Color(0xFF10A8D8);
const Color _authYellow = Color(0xFFFFD400);
const Color _authDivider = Color(0xFF484848);
const Color _authMuted = Color(0xFFB8B8B8);

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;
  bool obscurePassword = true;
  bool _syncedStoredEmail = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    _syncStoredEmail(auth.email);
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _authAccent,
          brightness: Brightness.dark,
          surface: _authPanel,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF111111),
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: _authDivider),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _authDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _authAccent),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _authAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: _authCanvas,
        body: SafeArea(
          child: Column(
            children: [
              const _AuthTopBar(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 760;
                        final form = _AuthFormPanel(
                          auth: auth,
                          emailController: emailController,
                          passwordController: passwordController,
                          isRegister: isRegister,
                          obscurePassword: obscurePassword,
                          onToggleMode: () =>
                              setState(() => isRegister = !isRegister),
                          onTogglePassword: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                          onSubmit: _submit,
                        );
                        return ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 980),
                          child: compact
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _AuthBrandPanel(),
                                    const SizedBox(height: 14),
                                    form,
                                  ],
                                )
                              : Row(
                                  children: [
                                    const Expanded(child: _AuthBrandPanel()),
                                    const SizedBox(width: 22),
                                    SizedBox(width: 390, child: form),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncStoredEmail(String? email) {
    if (_syncedStoredEmail || email == null || email.isEmpty) {
      return;
    }
    emailController.text = email;
    _syncedStoredEmail = true;
  }

  void _submit() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (isRegister) {
      ref.read(authControllerProvider.notifier).register(email, password);
    } else {
      ref.read(authControllerProvider.notifier).login(email, password);
    }
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _authTopBar,
        border: Border(bottom: BorderSide(color: Color(0xFF1B6F80))),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_queue, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Collectarr',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Spacer(),
          Text('Local-first collector workspace'),
        ],
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _authPanel,
        border: Border.all(color: _authDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _MiniShelfPreview(),
            const SizedBox(height: 28),
            Text(
              'Collectarr Comics',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _authAccent,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to your metadata hub. Your owned comics, wishlist, grades, prices, notes, and shelves stay local on this device unless you connect your own sync service.',
              style: TextStyle(color: _authMuted, height: 1.35),
            ),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AuthBadge(icon: Icons.storage, label: 'Local library'),
                _AuthBadge(icon: Icons.cloud_queue, label: 'Metadata core'),
                _AuthBadge(icon: Icons.sync, label: 'Optional sync'),
                _AuthBadge(icon: Icons.qr_code_scanner, label: 'Barcode ready'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.auth,
    required this.emailController,
    required this.passwordController,
    required this.isRegister,
    required this.obscurePassword,
    required this.onToggleMode,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final AuthState auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isRegister;
  final bool obscurePassword;
  final VoidCallback onToggleMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _authPanelRaised,
        border: Border.all(color: _authDivider),
        boxShadow: const [
          BoxShadow(
            color: Color(0xAA000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isRegister ? Icons.person_add : Icons.login,
                  color: _authYellow,
                ),
                const SizedBox(width: 8),
                Text(
                  isRegister ? 'Create account' : 'Login',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              obscureText: obscurePassword,
              onSubmitted: (_) => auth.isLoading ? null : onSubmit(),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              _AuthError(message: auth.error!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: FilledButton.icon(
                onPressed: auth.isLoading ? null : onSubmit,
                icon: auth.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isRegister ? Icons.person_add : Icons.login),
                label: Text(isRegister ? 'Register' : 'Login'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: auth.isLoading ? null : onToggleMode,
              child:
                  Text(isRegister ? 'Use existing account' : 'Create account'),
            ),
            const Divider(height: 24),
            const Text(
              'Dev credentials: user@example.com / password123',
              textAlign: TextAlign.center,
              style: TextStyle(color: _authMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniShelfPreview extends StatelessWidget {
  const _MiniShelfPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < 7; index++) ...[
            _PreviewComic(index: index),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _PreviewComic extends StatelessWidget {
  const _PreviewComic({required this.index});

  final int index;

  static const colors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF8E24AA),
    Color(0xFFFB8C00),
    Color(0xFF00ACC1),
  ];

  @override
  Widget build(BuildContext context) {
    final color = colors[index % colors.length];
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(height: 18, color: Colors.white24),
            ),
            Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'COMIC ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBadge extends StatelessWidget {
  const _AuthBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        border: Border.all(color: _authDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: _authAccent),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF4A1E1E),
        border: Border.all(color: const Color(0xFFB94A48)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFFB4AB)),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
