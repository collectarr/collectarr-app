import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color _authTopBar = kAppTopBar;
const Color _authCanvas = kAppCanvas;
const Color _authPanel = kAppGridCanvas;
const Color _authPanelRaised = Color(0xFF2D2D2D);
const Color _authAccent = kAppAccent;
const Color _authYellow = kAppHighlight;
const Color _authDivider = Color(0xFF484848);
const Color _authMuted = kAppTextMuted;

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
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
          fillColor: kAppFieldDark,
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
              borderRadius: BorderRadius.circular(2),
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
                          obscurePassword: obscurePassword,
                          onTogglePassword: () => setState(
                            () => obscurePassword = !obscurePassword,
                          ),
                          onFillDevCredentials: _fillDevCredentials,
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
              const _AuthStatusBar(),
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
    final auth = ref.read(authControllerProvider);
    if (auth.isLoading || auth.isRestoring) {
      return;
    }
    final email = emailController.text.trim();
    final password = passwordController.text;
    ref.read(authControllerProvider.notifier).login(email, password);
  }

  void _fillDevCredentials() {
    emailController.text = 'user@example.com';
    passwordController.text = 'password123';
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
          Icon(Icons.cloud_queue, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text(
            'Collectarr',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          Spacer(),
          Text(
            'v1.0',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
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
            const _MiniWorkspacePreview(),
            const SizedBox(height: 28),
            Text(
              'Collectarr',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: _authAccent,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your self-hosted media collection manager',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comics, manga, movies, games, music, books — all in one place. '  
              'Your data stays on your server.',
              style: TextStyle(color: _authMuted, height: 1.35),
            ),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _AuthFeatureChip(icon: Icons.storage, label: 'Self-hosted'),
                _AuthFeatureChip(icon: Icons.qr_code_scanner, label: 'Barcode scan'),
                _AuthFeatureChip(icon: Icons.sync, label: 'Multi-device sync'),
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
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onFillDevCredentials,
    required this.onSubmit,
  });

  final AuthState auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onFillDevCredentials;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isBusy = auth.isLoading || auth.isRestoring;
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
                  auth.isRestoring
                      ? Icons.hourglass_top
                      : Icons.login,
                  color: _authYellow,
                ),
                const SizedBox(width: 8),
                Text(
                  auth.isRestoring
                      ? 'Restoring session'
                      : 'Login',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _AuthModeStrip(),
            if (auth.email != null && auth.email!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _RememberedAccount(email: auth.email!),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              enabled: !isBusy,
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
              enabled: !isBusy,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: isBusy ? null : onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              obscureText: obscurePassword,
              onSubmitted: (_) => isBusy ? null : onSubmit(),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              _AuthError(message: auth.error!),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onSubmit,
                icon: auth.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  auth.isRestoring
                      ? 'Restoring...'
                      : 'Login',
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onFillDevCredentials,
              icon: const Icon(Icons.science_outlined, size: 18),
              label: const Text('Fill dev credentials'),
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

class _AuthModeStrip extends StatelessWidget {
  const _AuthModeStrip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kAppCardBackground,
        border: Border.all(color: _authDivider),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.lock_person_outlined, color: _authAccent, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Metadata account gates server search only. Personal shelf data stays in the local database.',
                style: TextStyle(color: _authMuted, fontSize: 12, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniWorkspacePreview extends StatelessWidget {
  const _MiniWorkspacePreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kAppField,
          border: Border.all(color: _authDivider),
        ),
        child: Column(
          children: [
            Container(
              height: 28,
              color: const Color(0xFF2C2C2C),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    for (final label in const [
                      'All',
                      '0-9',
                      'A',
                      'B',
                      'C',
                      'D'
                    ])
                      _AlphaTab(label: label, selected: label == 'All'),
                    Container(
                      width: 116,
                      height: 20,
                      margin: const EdgeInsets.only(right: 8),
                      color: const Color(0xFF0F0F0F),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const Text(
                        'Search comics...',
                        style: TextStyle(color: _authMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: Row(
                children: [
                  SizedBox(width: 134, child: _PreviewSeriesList()),
                  VerticalDivider(width: 1, color: _authDivider),
                  Expanded(child: _PreviewCoverGrid()),
                  VerticalDivider(width: 1, color: _authDivider),
                  SizedBox(width: 130, child: _PreviewInspector()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlphaTab extends StatelessWidget {
  const _AlphaTab({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: label.length > 1 ? 36 : 28,
      height: 20,
      margin: const EdgeInsets.only(right: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? _authAccent : kAppFieldDark,
        border: Border.all(color: _authDivider),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _PreviewSeriesList extends StatelessWidget {
  const _PreviewSeriesList();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Amazing Spider-Man', '17'),
      ('Batman', '11'),
      ('Locke & Key', '6'),
      ('Superman, Vol. 4', '94'),
      ('The Punisher', '37'),
      ('X-Men', '52'),
    ];
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Container(
            height: 20,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: const Color(0xFF0E0E0E),
            child: const Text(
              'Search series...',
              style: TextStyle(color: _authMuted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final row = rows[index];
                return Container(
                  height: 22,
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  color: row.$1 == 'Superman, Vol. 4'
                      ? const Color(0xFF0B7893)
                      : Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          row.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        color: kAppSurface,
                        child: Text(row.$2, style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCoverGrid extends StatelessWidget {
  const _PreviewCoverGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kAppGridCanvas,
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.68,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var index = 0; index < 15; index++)
            _PreviewComic(
              index: index,
              selected: index == 7,
              owned: index == 2 || index == 7 || index == 11,
            ),
        ],
      ),
    );
  }
}

class _PreviewInspector extends StatelessWidget {
  const _PreviewInspector();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171717),
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Superman, Vol. 4',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _authAccent, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text('#8A', style: TextStyle(color: _authYellow)),
            const SizedBox(height: 8),
            const SizedBox(
              width: 52,
              height: 72,
              child: _PreviewComic(index: 7, selected: false, owned: true),
            ),
            const SizedBox(height: 8),
            const _TinyMeta(label: 'Release', value: 'Oct 05, 2016'),
            const _TinyMeta(label: 'Grade', value: '5.0'),
            const _TinyMeta(label: 'Status', value: 'Owned'),
          ],
        ),
      ),
    );
  }
}

class _RememberedAccount extends StatelessWidget {
  const _RememberedAccount({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        border: Border.all(color: _authDivider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.history, color: _authAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Last account: $email',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _authMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewComic extends StatelessWidget {
  const _PreviewComic({
    required this.index,
    this.selected = false,
    this.owned = false,
  });

  final int index;
  final bool selected;
  final bool owned;

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
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: selected ? _authAccent : Colors.white24),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black54),
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
                          fontSize: 10,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (owned)
            const Positioned(
              right: 3,
              bottom: 3,
              child: Icon(Icons.check_circle, color: _authAccent, size: 15),
            ),
        ],
      ),
    );
  }
}

class _TinyMeta extends StatelessWidget {
  const _TinyMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: const TextStyle(color: _authMuted, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthStatusBar extends StatelessWidget {
  const _AuthStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
        border: Border(top: BorderSide(color: _authDivider)),
      ),
      child: const Row(
        children: [
          Icon(Icons.storage, color: _authAccent, size: 16),
          SizedBox(width: 6),
          Text('Local personal database', style: TextStyle(fontSize: 11)),
          VerticalDivider(width: 18, color: _authDivider),
          Expanded(
            child: Text(
              'Server stores catalog metadata only',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _authMuted, fontSize: 11),
            ),
          ),
          Text('Ready', style: TextStyle(color: _authMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class CollectarrRestoreScreen extends StatelessWidget {
  const CollectarrRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _authAccent,
          brightness: Brightness.dark,
          surface: _authPanel,
        ),
      ),
      child: const Scaffold(
        backgroundColor: _authCanvas,
        body: SafeArea(
          child: Column(
            children: [
              _AuthTopBar(),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 340,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _authPanelRaised,
                        border: Border.fromBorderSide(
                          BorderSide(color: _authDivider),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_sync,
                              color: _authAccent,
                              size: 34,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Restoring session',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 12),
                            LinearProgressIndicator(),
                            SizedBox(height: 14),
                            Text(
                              'Checking the stored JWT and reconnecting metadata search.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _authMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _AuthStatusBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthFeatureChip extends StatelessWidget {
  const _AuthFeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _authAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _authAccent.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _authAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
