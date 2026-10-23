import 'dart:async';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/library/providers/selected_library_provider.dart';
import 'package:collectarr_app/state/app_version_provider.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_page_header.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    if (!_syncedStoredEmail && auth.email != null && auth.email!.isNotEmpty) {
      emailController.text = auth.email!;
      _syncedStoredEmail = true;
    }
    return _AuthFrame(
        title: 'Sign in',
        child: _AuthFormPanel(
          auth: auth,
          emailController: emailController,
          passwordController: passwordController,
          obscurePassword: obscurePassword,
          onTogglePassword: () =>
              setState(() => obscurePassword = !obscurePassword),
          onSubmit: _submit,
          onUseDevCredentials: _useDevCredentials,
        ));
  }

  void _submit() {
    final auth = ref.read(authControllerProvider);
    if (auth.isLoading || auth.isRestoring) return;
    unawaited(ref
        .read(authControllerProvider.notifier)
        .login(emailController.text.trim(), passwordController.text));
  }

  void _useDevCredentials() {
    emailController.text = 'user@example.com';
    passwordController.text = 'password123';
    unawaited(
        ref.read(authControllerProvider.notifier).loginWithDevCredentials());
  }
}

class _AuthFrame extends ConsumerWidget {
  const _AuthFrame(
      {required this.title, required this.child, this.restoring = false});
  final String title;
  final Widget child;
  final bool restoring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    void openLibrary() => context.go(AppRoutes.forKind(
        AppRoutes.libraries, ref.read(selectedLibraryKindProvider)));
    return Theme(
      data: buildLibraryAccentTheme(Theme.of(context), palette.utilityAction),
      child: Scaffold(
        backgroundColor: appManagementCanvasColor(context),
        appBar: AppPageHeader(
            title: Text(title),
            icon: AppIcons.user,
            leading: restoring
                ? const SizedBox.shrink()
                : AppPageBackButton(onPressed: openLibrary),
            actions: const [_InstalledVersionLabel()]),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Material(
                color: appManagementPanelColor(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: palette.divider)),
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _AuthBrand(),
                          const SizedBox(height: 24),
                          child,
                          if (!restoring) ...[
                            const SizedBox(height: 18),
                            Divider(color: palette.divider),
                            const SizedBox(height: 10),
                            Text(
                                'Your local library is available without an account.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: palette.textSecondary)),
                            const SizedBox(height: 4),
                            TextButton(
                                onPressed: openLibrary,
                                child: const Text('Continue to library')),
                          ],
                        ])),
              )),
        ))),
      ),
    );
  }
}

class _InstalledVersionLabel extends ConsumerWidget {
  const _InstalledVersionLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(installedAppVersionProvider).asData?.value;
    if (version == null) return const SizedBox.shrink();
    return Center(
        child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text('v$version',
                    key: const Key('auth.version'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: appPalette(context).textSecondary)))));
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) => Column(children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(AppIcons.appLogoPng,
                key: const Key('auth.app-logo'),
                width: 96,
                height: 96,
                excludeFromSemantics: true)),
        const SizedBox(height: 16),
        Text('Collectarr',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: appPalette(context).textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700)),
      ]);
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel(
      {required this.auth,
      required this.emailController,
      required this.passwordController,
      required this.obscurePassword,
      required this.onTogglePassword,
      required this.onSubmit,
      required this.onUseDevCredentials});
  final AuthState auth;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onUseDevCredentials;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final busy = auth.isLoading || auth.isRestoring;
    return AutofillGroup(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Text(
              auth.isRestoring
                  ? 'Checking your saved session…'
                  : 'Sign in to your account',
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.textSecondary)),
          const SizedBox(height: 24),
          TextField(
              key: const Key('auth.email'),
              controller: emailController,
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email
              ],
              decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(AppIcons.user, size: 16))),
          const SizedBox(height: 14),
          TextField(
              key: const Key('auth.password'),
              controller: passwordController,
              enabled: !busy,
              obscureText: obscurePassword,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) {
                if (!busy) onSubmit();
              },
              decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(AppIcons.lock, size: 16),
                  suffixIcon: IconButton(
                      tooltip:
                          obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: busy ? null : onTogglePassword,
                      icon: Icon(
                          obscurePassword ? AppIcons.eye : AppIcons.eyeSlash,
                          size: 16)))),
          if (auth.error case final message?) ...[
            const SizedBox(height: 14),
            _AuthError(message: message),
          ],
          const SizedBox(height: 20),
          SizedBox(
              height: 40,
              child: FilledButton.icon(
                  key: const Key('auth.submit'),
                  onPressed: busy ? null : onSubmit,
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(AppIcons.login, size: 16),
                  label: Text(auth.isRestoring ? 'Restoring…' : 'Sign in'))),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
                onPressed: busy ? null : onUseDevCredentials,
                icon: const Icon(AppIcons.bug, size: 14),
                label: const Text('Use dev credentials')),
          ],
        ]));
  }
}

class CollectarrRestoreScreen extends StatelessWidget {
  const CollectarrRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) => _AuthFrame(
      title: 'Restoring session',
      restoring: true,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 16),
        Text('Checking your saved session…',
            textAlign: TextAlign.center,
            style: TextStyle(color: appPalette(context).textSecondary)),
      ]));
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: palette.errorBackground,
              border: Border.all(color: palette.errorBorder),
              borderRadius: BorderRadius.circular(4)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(AppIcons.warning, size: 16, color: palette.errorForeground),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message,
                    style: TextStyle(color: palette.errorForeground))),
          ]),
        ));
  }
}
