import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/library/covers/provider_cover_fetch.dart';
import 'package:collectarr_app/features/library/covers/provider_cover_localizer.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProviderCoverDownload = ({
  CatalogMediaKind kind,
  ProviderCoverProgress progress,
  bool running,
});

/// The download of a kind's provider covers, after an import or on request.
final providerCoverDownloadsProvider =
    NotifierProvider<ProviderCoverDownloads, ProviderCoverDownload?>(
        ProviderCoverDownloads.new);

class ProviderCoverDownloads extends Notifier<ProviderCoverDownload?> {
  @override
  ProviderCoverDownload? build() => null;

  ProviderCoverLocalizer get _localizer => ProviderCoverLocalizer(
        database: ref.read(localDatabaseProvider),
        mutations: ref.read(libraryEntryMutationsProvider),
        coreBaseUrl: ref.read(connectionSettingsProvider).metadataBaseUrl,
      );

  /// Entries of [kind] whose covers are still provider links.
  Future<int> pendingCount(CatalogMediaKind kind) async =>
      (await _localizer.pendingEntries(kind)).length;

  /// Downloads the pending covers of [kind]; one download runs at a time.
  Future<void> start(CatalogMediaKind kind) async {
    if (!providerCoversDownloadable || state?.running == true) return;
    final localizer = _localizer;
    final pending = await localizer.pendingEntries(kind);
    if (pending.isEmpty) return;
    state = (
      kind: kind,
      progress: (done: 0, stored: 0, total: pending.length),
      running: true,
    );
    final result = await localizer.localize(pending,
        onProgress: (progress) =>
            state = (kind: kind, progress: progress, running: true));
    state = (kind: kind, progress: result, running: false);
  }
}
