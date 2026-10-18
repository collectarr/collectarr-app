import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/settings/settings_layout.dart';
import 'package:collectarr_app/features/settings/settings_reference_controls.dart';
import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings > Updates: the installed version, the newest release on the
/// chosen channel, and downloading and installing it.
class SettingsUpdatesSection extends ConsumerWidget {
  const SettingsUpdatesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The web build is served fresh on every load and has no installer.
    if (kIsWeb) {
      return const SettingsTabBody(children: [
        SettingsPanel(
          icon: Icons.system_update_alt,
          title: 'Updates',
          child: Text('The web app updates when the page is reloaded.'),
        ),
      ]);
    }
    final update = ref.watch(appUpdateProvider);
    final controller = ref.read(appUpdateProvider.notifier);
    return SettingsTabBody(children: [
      SettingsPanel(
        icon: Icons.system_update_alt,
        title: 'Updates',
        child: _UpdateStatus(update: update, controller: controller),
      ),
      SettingsPanel(
        icon: Icons.tune,
        title: 'Update settings',
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SettingsCheck(
            label: 'Check for updates when the app starts',
            value: update.settings.autoCheck,
            onChanged: (value) => controller
                .updateSettings(update.settings.copyWith(autoCheck: value)),
          ),
          const SizedBox(height: 10),
          const SettingsLegend('Release channel'),
          SettingsSelect<UpdateChannel>(
            value: update.settings.channel,
            values: UpdateChannel.values,
            labelOf: _channelLabel,
            onChanged: (channel) async {
              await controller
                  .updateSettings(update.settings.copyWith(channel: channel));
              await controller.checkForUpdate();
            },
          ),
        ]),
      ),
    ]);
  }
}

String _channelLabel(UpdateChannel channel) => switch (channel) {
      UpdateChannel.stable => 'Stable',
      UpdateChannel.beta => 'Beta (includes pre-releases)',
      UpdateChannel.nightly => 'Nightly',
    };

class _UpdateStatus extends StatelessWidget {
  const _UpdateStatus({required this.update, required this.controller});

  final AppUpdateState update;
  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
    final release = update.release;
    final installed = update.currentVersion.isEmpty
        ? 'Reading the installed version...'
        : 'Installed version: ${update.currentVersion}';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(installed),
      const SizedBox(height: 6),
      Text(_statusText(update),
          key: const Key('settings.updates.status'),
          style: update.status == UpdateStatus.error
              ? TextStyle(color: Theme.of(context).colorScheme.error)
              : null),
      if (update.status == UpdateStatus.downloading) ...[
        const SizedBox(height: 10),
        LinearProgressIndicator(
            value:
                update.downloadProgress > 0 ? update.downloadProgress : null),
      ],
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: _actions(context)),
      if (release != null && release.body.trim().isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
            '${release.name} - ${AppFormats.current.formatDate(release.publishedAt)}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: SingleChildScrollView(child: SelectableText(release.body)),
        ),
      ],
    ]);
  }

  List<Widget> _actions(BuildContext context) {
    final release = update.release;
    final busy = update.status == UpdateStatus.checking ||
        update.status == UpdateStatus.downloading ||
        update.status == UpdateStatus.installing;
    return [
      OutlinedButton(
        key: const Key('settings.updates.check'),
        onPressed: busy ? null : controller.checkForUpdate,
        child: const Text('Check for updates'),
      ),
      if (release != null && update.status == UpdateStatus.updateAvailable)
        _PrimaryButton(
          key: const Key('settings.updates.download'),
          label: 'Download ${release.version}',
          onPressed: controller.downloadUpdate,
        ),
      if (update.status == UpdateStatus.downloading)
        OutlinedButton(
          onPressed: controller.cancelDownload,
          child: const Text('Cancel download'),
        ),
      if (update.status == UpdateStatus.readyToInstall)
        _PrimaryButton(
          key: const Key('settings.updates.install'),
          label: 'Install ${release?.version ?? 'update'}',
          onPressed: controller.installUpdate,
        ),
    ];
  }
}

String _statusText(AppUpdateState update) {
  final version = update.release?.version;
  return switch (update.status) {
    UpdateStatus.idle => 'Not checked yet.',
    UpdateStatus.checking => 'Checking for updates...',
    UpdateStatus.upToDate => 'Collectarr is up to date.',
    UpdateStatus.updateAvailable => 'Version $version is available.',
    UpdateStatus.downloading =>
      'Downloading $version... ${(update.downloadProgress * 100).round()}%',
    UpdateStatus.readyToInstall =>
      'Version $version is downloaded. Installing closes Collectarr.',
    UpdateStatus.installing => 'Starting the installer...',
    UpdateStatus.error =>
      'Could not update: ${update.errorMessage ?? 'unknown error'}',
  };
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: appPalette(context).utilityAction,
            foregroundColor: Colors.white),
        onPressed: onPressed,
        child: Text(label),
      );
}
