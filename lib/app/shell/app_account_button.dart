import 'dart:async';

import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/core/utils/app_toast.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/ui/app_chrome.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/app_motion.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppAccountButton extends ConsumerWidget {
  const AppAccountButton(
      {super.key,
      required this.style,
      required this.kind,
      required this.animationsEnabled});

  final ButtonStyle style;
  final String kind;
  final bool animationsEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        key: const Key('app.account'),
        tooltip: 'Account',
        style: style,
        visualDensity: VisualDensity.compact,
        icon: const Icon(AppIcons.user, size: 20),
        onPressed: () => unawaited(_show(context, ref)),
      );

  Future<void> _show(BuildContext context, WidgetRef ref) =>
      showAppDialog<void>(
        context: context,
        barrierDismissible: true,
        useSafeArea: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration:
            animationsEnabled && !MediaQuery.disableAnimationsOf(context)
                ? appNavigationSlideDuration
                : Duration.zero,
        transitionBuilder: (_, animation, __, child) => Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(animation),
                child: child)),
        builder: (drawerContext) => Consumer(builder: (_, drawerRef, __) {
          final auth = drawerRef.watch(authControllerProvider);
          void close() => Navigator.of(drawerContext).pop();
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 300) {
                close();
              }
            },
            child: Drawer(
              key: const Key('account.drawer'),
              width: (MediaQuery.sizeOf(drawerContext).width * .86)
                  .clamp(0, 320)
                  .toDouble(),
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              backgroundColor: appPalette(drawerContext).sidebar,
              child: SafeArea(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(drawerContext, close),
                  const Divider(height: 1),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                          auth.isAuthenticated
                              ? auth.email ?? 'Signed in'
                              : 'Local library',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: appPalette(drawerContext).textPrimary))),
                  ListTile(
                      dense: true,
                      leading: const Icon(AppIcons.user, size: 16),
                      title: const Text('My Account'),
                      onTap: () {
                        close();
                        context.go(AppRoutes.forKind(AppRoutes.account, kind));
                      }),
                  if (auth.isAuthenticated || auth.token != null)
                    ListTile(
                        dense: true,
                        leading: const Icon(AppIcons.logout, size: 16),
                        title: const Text('Logout'),
                        onTap: () async {
                          final controller =
                              ref.read(authControllerProvider.notifier);
                          close();
                          await _logout(context, controller);
                        })
                  else
                    ListTile(
                        dense: true,
                        leading: const Icon(AppIcons.login, size: 16),
                        title: const Text('Sign in'),
                        enabled: !auth.isRestoring,
                        onTap: () {
                          close();
                          context.go(AppRoutes.auth);
                        }),
                ],
              )),
            ),
          );
        }),
      );

  Future<void> _logout(BuildContext context, AuthController controller) async {
    try {
      await controller.logout();
    } catch (_) {
      if (context.mounted) {
        showAppToast(context, 'Could not sign out. Please try again.',
            tone: AppToastTone.error);
      }
    }
  }

  Widget _header(BuildContext context, VoidCallback close) => SizedBox(
        height: drawerHeaderHeight,
        child: Row(children: [
          const SizedBox(width: 16),
          const Expanded(
              child: Text('Account',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
          IconButton(
              tooltip: 'Close account',
              onPressed: close,
              style: IconButton.styleFrom(
                  foregroundColor: appPalette(context).textPrimary,
                  backgroundColor: Colors.transparent),
              icon: Icon(AppIcons.close,
                  size: 16, color: appPalette(context).textPrimary)),
        ]),
      );
}
