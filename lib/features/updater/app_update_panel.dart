import 'package:collectarr_app/features/updater/app_update_service.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A panel shown inside the Settings "Updates" tab.
class AppUpdatePanel extends ConsumerWidget {
  const AppUpdatePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateProvider);
    final controller = ref.read(appUpdateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VersionRow(currentVersion: update.currentVersion, update: update),
        const SizedBox(height: 16),
        _StatusSection(update: update, controller: controller),
        const SizedBox(height: 16),
        _AutoCheckToggle(update: update, controller: controller),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.currentVersion, required this.update});
  final String currentVersion;
  final AppUpdateState update;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Text(
          'Current version: $currentVersion',
          style: const TextStyle(fontSize: 14),
        ),
        if (update.release != null) ...[
          const SizedBox(width: 16),
          Text(
            'Latest: ${update.release!.version}',
            style: TextStyle(
              fontSize: 14,
              color: update.status == UpdateStatus.updateAvailable
                  ? Colors.amber
                  : kAppTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.update, required this.controller});
  final AppUpdateState update;
  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
    return switch (update.status) {
      UpdateStatus.idle => _buildCheckButton(),
      UpdateStatus.checking => const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Checking for updates…'),
          ],
        ),
      UpdateStatus.upToDate => Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text('You are on the latest version.'),
            const Spacer(),
            _buildCheckButton(),
          ],
        ),
      UpdateStatus.updateAvailable => _buildUpdateAvailable(context),
      UpdateStatus.downloading => _buildDownloading(),
      UpdateStatus.readyToInstall => _buildReadyToInstall(),
      UpdateStatus.installing => const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Launching installer…'),
          ],
        ),
      UpdateStatus.error => _buildError(),
    };
  }

  Widget _buildCheckButton() {
    return FilledButton.icon(
      onPressed: controller.checkForUpdate,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Check for updates'),
    );
  }

  Widget _buildUpdateAvailable(BuildContext context) {
    final release = update.release!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.new_releases, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Version ${release.version} is available',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (release.body.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: kAppPanelRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Text(
                release.body,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: controller.downloadUpdate,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download & Install'),
            ),
            const SizedBox(width: 12),
            _buildCheckButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDownloading() {
    final pct = (update.downloadProgress * 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: update.downloadProgress,
              ),
            ),
            const SizedBox(width: 12),
            Text('$pct%'),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: controller.cancelDownload,
          icon: const Icon(Icons.cancel, size: 18),
          label: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildReadyToInstall() {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        const Text('Download complete.'),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: controller.installUpdate,
          icon: const Icon(Icons.install_desktop, size: 18),
          label: const Text('Install now'),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                update.errorMessage ?? 'Unknown error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCheckButton(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _AutoCheckToggle extends StatelessWidget {
  const _AutoCheckToggle({required this.update, required this.controller});
  final AppUpdateState update;
  final AppUpdateController controller;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Check for updates automatically'),
      subtitle: const Text('Checks when the app starts'),
      value: update.settings.autoCheck,
      onChanged: (v) {
        controller.updateSettings(update.settings.copyWith(autoCheck: v));
      },
    );
  }
}
