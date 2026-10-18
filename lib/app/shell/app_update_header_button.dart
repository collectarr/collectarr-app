import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/routing/app_router.dart';
import 'package:collectarr_app/features/settings/settings_page.dart';
import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Header button, right of Sync, shown once a newer release is found (the
/// startup check runs when the header first builds). It opens
/// Settings > Updates, where the release is downloaded and installed.
class AppUpdateHeaderButton extends ConsumerWidget {
  const AppUpdateHeaderButton(
      {super.key, required this.style, required this.kind});

  final ButtonStyle style;
  final CatalogMediaKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) return const SizedBox.shrink();
    final update = ref.watch(appUpdateProvider);
    final version = update.release?.version;
    final tooltip = switch (update.status) {
      UpdateStatus.updateAvailable => 'Collectarr $version is available',
      UpdateStatus.downloading =>
        'Downloading Collectarr $version (${(update.downloadProgress * 100).round()}%)',
      UpdateStatus.readyToInstall => 'Collectarr $version is ready to install',
      _ => null,
    };
    if (tooltip == null) return const SizedBox.shrink();
    return IconButton(
      key: const Key('app.update'),
      tooltip: tooltip,
      style: style,
      visualDensity: VisualDensity.compact,
      onPressed: () => context.go(AppRoutes.forKind(
          AppRoutes.settings, kind.apiValue,
          parameters: {'section': SettingsSection.updates.name})),
      icon: const Icon(AppIcons.appUpdate),
    );
  }
}
