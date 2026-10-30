import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/covers/provider_cover_downloads.dart';
import 'package:collectarr_app/features/library/covers/provider_cover_fetch.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Offers to keep a kind's provider covers with the library.
Future<void> showDownloadCoversDialog(
  BuildContext context, {
  required CatalogMediaKind kind,
  required String pluralLabel,
}) =>
    showAppDialog<void>(
      context: context,
      builder: (_) =>
          _DownloadCoversDialog(kind: kind, pluralLabel: pluralLabel),
    );

class _DownloadCoversDialog extends ConsumerStatefulWidget {
  const _DownloadCoversDialog({required this.kind, required this.pluralLabel});
  final CatalogMediaKind kind;
  final String pluralLabel;

  @override
  ConsumerState<_DownloadCoversDialog> createState() =>
      _DownloadCoversDialogState();
}

class _DownloadCoversDialogState extends ConsumerState<_DownloadCoversDialog> {
  late final Future<int> _pending = ref
      .read(providerCoverDownloadsProvider.notifier)
      .pendingCount(widget.kind);

  @override
  Widget build(BuildContext context) {
    final download = ref.watch(providerCoverDownloadsProvider);
    final current = download?.kind == widget.kind ? download : null;
    return AccentAlertDialog(
      headerIcon: AppIcons.downloadCovers,
      title: const Text('Download Covers'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: FutureBuilder<int>(
          future: _pending,
          builder: (context, snapshot) {
            if (!providerCoversDownloadable) {
              return const Text(
                  'Covers linked from other sites, such as CLZ, cannot be '
                  'downloaded in the browser because those sites do not '
                  'allow it. Download them in the desktop or mobile app; '
                  'Sync then brings them here.');
            }
            if (current != null) {
              final progress = current.progress;
              final failed = progress.done - progress.stored;
              return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                        value: progress.total == 0
                            ? null
                            : progress.done / progress.total),
                    const SizedBox(height: 8),
                    Text(current.running
                        ? '${progress.done} of ${progress.total} covers'
                        : 'Kept ${progress.stored} covers with your '
                            '${widget.pluralLabel}.'
                            '${failed > 0 ? ' $failed could not be '
                                'downloaded and keep their links.' : ''}'),
                  ]);
            }
            final count = snapshot.data;
            if (count == null) return const LinearProgressIndicator();
            return Text(count == 0
                ? 'All covers of your ${widget.pluralLabel} are already kept '
                    'with your library.'
                : '$count ${widget.pluralLabel} show covers linked from other '
                    'sites. Download them to keep them with your library, '
                    'also offline.');
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(current?.running == true ? 'Hide' : 'Close'),
        ),
        if (providerCoversDownloadable && current == null)
          FutureBuilder<int>(
            future: _pending,
            builder: (context, snapshot) => FilledButton(
              onPressed: (snapshot.data ?? 0) == 0
                  ? null
                  : () => ref
                      .read(providerCoverDownloadsProvider.notifier)
                      .start(widget.kind),
              child: const Text('Download'),
            ),
          ),
      ],
    );
  }
}
