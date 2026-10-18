import 'dart:async';
import 'package:collectarr_app/core/device/device_identity.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/features/settings/settings_connection_widgets.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';

final _deviceIdentityProvider = FutureProvider.autoDispose<String>((ref) async {
  return DeviceIdentity().getOrCreate();
});

/// Settings > Account: device identity, session and permissions.
class SettingsAccountSection extends ConsumerStatefulWidget {
  const SettingsAccountSection({super.key});

  @override
  ConsumerState<SettingsAccountSection> createState() =>
      _SettingsAccountSectionState();
}

class _SettingsAccountSectionState
    extends ConsumerState<SettingsAccountSection> {
  @override
  Widget build(BuildContext context) => _buildAccountSection(
      ref.watch(authControllerProvider), ref.watch(_deviceIdentityProvider));

  Widget _buildAccountSection(
    AuthState auth,
    AsyncValue<String> deviceId,
  ) {
    return SettingsTabBody(
      children: [
        SettingsPanel(
          icon: Icons.devices_outlined,
          title: 'Device identity',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(deviceId.value ?? 'Loading device id...'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: deviceId.isLoading ? null : _regenerateDeviceId,
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Regenerate device id'),
                ),
              ),
            ],
          ),
        ),
        SettingsPanel(
          icon: Icons.account_circle_outlined,
          title: 'Account',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(auth.email ?? 'Not signed in'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (auth.token != null || auth.isExpired)
                    SettingsStatusChip(
                      icon: auth.isExpired
                          ? Icons.lock_clock_outlined
                          : Icons.verified_user_outlined,
                      label: _sessionStatusLabel(auth),
                      isError: auth.isExpired,
                    ),
                  if (auth.isAuthenticated)
                    SettingsStatusChip(
                      icon: auth.isAdmin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline,
                      label: auth.isAdmin ? 'Core admin' : 'Standard account',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                auth.isAuthenticated
                    ? auth.isAdmin
                        ? 'Full admin access: dashboard, logs, system management, and all catalog operations.'
                        : 'Catalog search, proposals, and corrections are available. Admin-only tools (dashboard, logs) are hidden.'
                    : 'You can browse the app and send metadata proposals without signing in. Admin sign in is only needed for admin/server features.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (auth.isAuthenticated) ...[
                    OutlinedButton.icon(
                      onPressed: _refreshAccountPermissions,
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: const Text('Refresh permissions'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ] else
                    FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.auth),
                      icon: const Icon(Icons.login),
                      label: const Text('Admin sign in'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _refreshAccountPermissions() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshCurrentUser();
      if (!mounted) {
        return;
      }
      final auth = ref.read(authControllerProvider);
      showSettingsToast(
        auth.isAdmin
            ? 'Account permissions refreshed: admin'
            : 'Account permissions refreshed: standard account',
        tone: AppToastTone.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showSettingsToast(
        'Could not refresh permissions: ${describeSettingsError(error)}',
        tone: AppToastTone.error,
      );
    }
  }

  Future<void> _regenerateDeviceId() async {
    await DeviceIdentity().regenerate();
    ref.invalidate(_deviceIdentityProvider);
    if (mounted) {
      showSettingsToast('Device id regenerated', tone: AppToastTone.success);
    }
  }

  String _sessionStatusLabel(AuthState auth) {
    if (auth.isExpired) {
      return 'Session expired';
    }
    final expiresAt = auth.expiresAt;
    if (expiresAt == null) {
      return 'Session expiry unavailable';
    }
    return 'Session expires ${formatSettingsTime(expiresAt)}';
  }
}
