import 'package:collectarr_app/features/library/kinds/music/data/music_owned_item_projection.dart';
import 'package:collectarr_app/features/library/details/library_inspector_info_line.dart';
import 'package:collectarr_app/features/library/details/library_inspector_title_card.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_panel_scaffold.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_medium.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_list_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_view_model.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_providers.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/core/models/money.dart' show OwnedItemId;
import 'package:collectarr_app/core/models/owned_item_projection.dart'
    show OwnedItemRef;
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

MusicInspectorViewModel _musicModel(LibraryProjectionView item) =>
    MusicInspectorViewModel.from(item);

MusicReleaseGroup? _musicGroup(LibraryProjectionView item) =>
    _musicModel(item).group;

Widget buildMusicInspectorPanel(
  BuildContext context,
  LibraryInspectorPanelRequest request,
) {
  return MusicInspectorPanel(request: request);
}

class MusicInspectorPanel extends StatelessWidget {
  const MusicInspectorPanel({super.key, required this.request});

  final LibraryInspectorPanelRequest request;

  @override
  Widget build(BuildContext context) {
    final inspector = request.inspector;
    return LibraryDetailPanelScaffold(
      accent: inspector.accent,
      toolbar: InspectorUnifiedToolbar(
        item: inspector.item,
        detailsLayout: inspector.detailsLayout,
        onEdit: request.onEdit,
        onShare: request.onShare,
        onDuplicate: request.onDuplicate,
        onToggleOwned: request.onToggleOwned,
        onLoan: request.onLoan,
        onRefreshMetadata: request.onRefreshMetadata,
        onUnlinkFromCore: request.onUnlinkFromCore,
        onDetailsLayoutChanged: request.onDetailsLayoutChanged,
      ),
      hero: _MusicInspectorHeader(inspector: inspector),
      sections: [
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.identity,
          title: 'Overview',
          children: [
            _MusicInspectorMain(inspector: inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.media,
          title: 'Track List',
          children: [
            _MusicInspectorTracks(inspector: inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.metadata,
          title: 'Disc Details',
          children: [
            _MusicDiscDetails(inspector: inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.notes,
          title: inspector.item.node is LibraryReleaseNodeRef
              ? 'Release'
              : 'Release group',
          children: [
            _MusicProductDetails(inspector: inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          title: 'Personal',
          slot: LibraryDetailSectionSlot.personal,
          children: [
            _MusicInspectorDetailsPersonal(inspector: inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.progress,
          title: 'Listening history',
          children: [
            _MusicListeningSection(inspector: inspector),
          ],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.relations,
          title: 'Credits',
          headerActions: [
            if (request.onEdit != null)
              _editSectionAction(
                request.onEdit!,
                tooltip: 'Edit credits',
              ),
          ],
          children: [
            _MusicInspectorCredits(inspector: inspector),
          ],
        ),
        if (request.trailingSections.isNotEmpty)
          LibraryDetailSectionSpec(
            slot: LibraryDetailSectionSlot.activity,
            title: 'More',
            children: [...request.trailingSections],
            initiallyExpanded: false,
          ),
      ],
    );
  }

  Widget _editSectionAction(
    VoidCallback onPressed, {
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          onPressed: onPressed,
          child: const Icon(Icons.edit_outlined, size: 16),
        ),
      ),
    );
  }
}

class _MusicListeningSection extends ConsumerWidget {
  const _MusicListeningSection({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = _musicModel(inspector.item);
    final targetRef = libraryTrackingTargetForItem(
          inspector.type,
          inspector.item,
        ) ??
        inspector.item.source.catalogRef;
    if (targetRef == null || !targetRef.isKnown) {
      return const SizedBox.shrink();
    }
    final isRelease = inspector.item.node is LibraryReleaseNodeRef;
    if (isRelease) {
      return _buildReleaseListeningSection(context, ref, model, targetRef);
    }
    final summary = ref.watch(
      musicReleaseGroupTrackingSummaryProvider(
        MusicReleaseGroupId(model.group.id.value),
      ),
    );
    return summary.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (error, _) => Text(
        'Unable to load listening history: $error',
        style: TextStyle(color: appPalette(context).textMuted),
      ),
      data: (stats) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stats.totalListenCount == 0
                        ? 'No listens logged yet.'
                        : '${stats.totalListenCount} ${stats.totalListenCount == 1 ? 'listen' : 'listens'} \u00B7 ${stats.listenedReleaseCount}/${stats.totalReleases} releases \u00B7 Last ${formatDate(stats.lastListened!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appPalette(context).textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (stats.recentEvents.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final event in stats.recentEvents.take(5))
                _MusicListenEventTile(event: event),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReleaseListeningSection(
    BuildContext context,
    WidgetRef ref,
    MusicInspectorViewModel model,
    CatalogEntityRef targetRef,
  ) {
    final events = ref.watch(musicListeningEventsProvider(targetRef));
    return events.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (error, _) => Text(
        'Unable to load listening history: $error',
        style: TextStyle(color: appPalette(context).textMuted),
      ),
      data: (history) {
        final releaseEvents = history
            .where(
              (event) =>
                  event.releaseId == model.release.id.value ||
                  event.targetRef == targetRef,
            )
            .toList(growable: false);
        final lastListened = releaseEvents.firstOrNull?.listenedAt;
        final tracking = inspector.trackingSummary;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    releaseEvents.isEmpty
                        ? 'No listens logged yet.'
                        : '${releaseEvents.length} ${releaseEvents.length == 1 ? 'listen' : 'listens'} \u00B7 Last ${formatDate(lastListened!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appPalette(context).textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _logListen(context, ref, model, targetRef),
                  icon: const Icon(Icons.headphones_outlined, size: 16),
                  label: const Text('Log listen'),
                ),
              ],
            ),
            if (tracking != null) ...[
              const SizedBox(height: 6),
              Text(
                [
                  'Status: ${tracking.statusLabel}',
                  if (tracking.rating != null) 'Rating: ${tracking.rating}/5',
                  if (tracking.notes?.trim().isNotEmpty == true)
                    'Notes: ${tracking.notes!.trim()}',
                ].join(' \u00B7 '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appPalette(context).textMuted,
                    ),
              ),
            ],
            if (releaseEvents.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final event in releaseEvents.take(5))
                _MusicListenEventTile(event: event),
            ],
          ],
        );
      },
    );
  }

  Future<void> _logListen(
    BuildContext context,
    WidgetRef ref,
    MusicInspectorViewModel model,
    CatalogEntityRef targetRef,
  ) async {
    final notesController = TextEditingController();
    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Log listen'),
          content: TextField(
            controller: notesController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Optional listening notes',
            ),
            minLines: 1,
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (shouldSave != true || !context.mounted) return;
      final now = DateTime.now().toUtc();
      final owned = model.owned;
      await ref.read(musicListeningRepositoryProvider).upsert(
            MusicListenEvent(
              id: 'listen-${now.microsecondsSinceEpoch}',
              targetRef: targetRef,
              releaseGroupId: model.group.id.value,
              releaseId: model.release.id.value,
              ownedRef: owned == null
                  ? null
                  : OwnedItemRef(
                      kind: CatalogMediaKind.music,
                      id: OwnedItemId(owned.id.value),
                    ),
              listenedAt: now,
              notes: notesController.text.trim().isEmpty
                  ? null
                  : notesController.text.trim(),
              createdAt: now,
              updatedAt: now,
            ),
          );
      ref.invalidate(musicListeningEventsProvider(targetRef));
      ref.invalidate(shelfProvider);
      ref.invalidate(
        musicReleaseGroupTrackingSummaryProvider(
          MusicReleaseGroupId(model.group.id.value),
        ),
      );
    } finally {
      notesController.dispose();
    }
  }
}

class _MusicListenEventTile extends ConsumerWidget {
  const _MusicListenEventTile({required this.event});

  final MusicListenEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.headphones_outlined, size: 15, color: palette.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(event.listenedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (event.location?.trim().isNotEmpty == true ||
                    event.notes?.trim().isNotEmpty == true)
                  Text(
                    [
                      if (event.location?.trim().isNotEmpty == true)
                        event.location!.trim(),
                      if (event.notes?.trim().isNotEmpty == true)
                        event.notes!.trim(),
                    ].join(' \u00B7 '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                        ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Event actions',
            padding: EdgeInsets.zero,
            iconSize: 18,
            onSelected: (action) {
              switch (action) {
                case 'edit':
                  _edit(context, ref);
                case 'delete':
                  _delete(context, ref);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit notes')),
              PopupMenuItem(value: 'delete', child: Text('Delete event')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final notesController = TextEditingController(text: event.notes ?? '');
    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit listen'),
          content: TextField(
            controller: notesController,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (shouldSave != true || !context.mounted) return;
      final now = DateTime.now().toUtc();
      await ref.read(musicListeningRepositoryProvider).upsert(
            MusicListenEvent(
              id: event.id,
              targetRef: event.targetRef,
              releaseGroupId: event.releaseGroupId,
              releaseId: event.releaseId,
              ownedRef: event.ownedRef,
              listenedAt: event.listenedAt,
              startedAt: event.startedAt,
              finishedAt: event.finishedAt,
              location: event.location,
              notes: notesController.text.trim().isEmpty
                  ? null
                  : notesController.text.trim(),
              createdAt: event.createdAt,
              updatedAt: now,
            ),
          );
      _invalidate(ref);
    } finally {
      notesController.dispose();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listen?'),
        content: const Text('This listen will be removed from active history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(musicListeningRepositoryProvider).markDeleted(
          event,
          DateTime.now().toUtc(),
        );
    _invalidate(ref);
  }

  void _invalidate(WidgetRef ref) {
    ref.invalidate(shelfProvider);
    ref.invalidate(musicListeningEventsProvider(event.targetRef));
    ref.invalidate(
      musicReleaseGroupTrackingSummaryProvider(
        MusicReleaseGroupId(event.releaseGroupId),
      ),
    );
  }
}

class _MusicInspectorHeader extends StatelessWidget {
  const _MusicInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final group = _musicGroup(inspector.item);
    final artist = group?.artist?.trim();
    return LibraryInspectorTitleCard(
      item: inspector.item,
      eyebrow: artist,
      accent: inspector.accent,
    );
  }
}

class _MusicInspectorMain extends StatelessWidget {
  const _MusicInspectorMain({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final model = _musicModel(inspector.item);
    final group = model.group;
    final release = model.release;
    final isRelease = inspector.item.node is LibraryReleaseNodeRef;
    final tracks = model.tracks;
    final palette = appPalette(context);
    final discGroups = _groupTracksByDisc(tracks);
    final discCount = discGroups.length;
    final totalTracks = tracks.where((entry) => !entry.isHeader).length;
    final totalDuration = _formatTotalDuration(tracks);
    final dto = inspector.item.dto;
    final coverUrl = isRelease
        ? release.coverImageUrl ?? group.coverImageUrl
        : group.coverImageUrl ?? release.coverImageUrl;
    final formatLabel = isRelease
        ? release.mediums.firstOrNull?.mediumType ?? release.packaging ?? '-'
        : '${group.releaseCount} ${group.releaseCount == 1 ? 'release' : 'releases'}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 164,
                height: 164,
                child: LibraryInteractiveCover(
                  title: dto.title,
                  imageUrl: coverUrl,
                  accentColor: inspector.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRelease ? release.title : group.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LibraryInspectorInfoLine(
                    icon: Icons.album_outlined,
                    text: [
                      formatLabel,
                      if (discCount > 0)
                        '$discCount ${discCount == 1 ? 'Disc' : 'Discs'}',
                      if (totalTracks > 0)
                        '$totalTracks ${totalTracks == 1 ? 'Track' : 'Tracks'}',
                      if (totalDuration != null) totalDuration,
                    ].join(' | '),
                  ),
                  if (isRelease &&
                      release.catalogNumber?.trim().isNotEmpty == true)
                    LibraryInspectorInfoLine(
                      icon: Icons.confirmation_number_outlined,
                      text: 'Cat No ${release.catalogNumber}',
                    ),
                  if (discGroups.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final group in discGroups)
                          _MusicDiscCard(
                            discNumber: group.discNumber,
                            trackCount: group.tracks.length,
                            duration: _formatTotalDuration(group.tracks),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _MusicCoverCard(
                          title: 'Front cover',
                          coverUrl: coverUrl,
                          accent: inspector.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MusicCoverCard(
                          title: 'Back cover',
                          coverUrl: null,
                          accent: inspector.accent,
                          emptyText: 'Back cover not in metadata',
                        ),
                      ),
                    ],
                  ),
                  if (_ebayUri(inspector.item) case final uri?) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: palette.panel,
                          border: Border.all(color: palette.divider),
                        ),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Text(
                            'Find sold listings on eBay',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicInspectorTracks extends StatelessWidget {
  const _MusicInspectorTracks({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final model = _musicModel(inspector.item);
    final tracks = model.tracks;
    final groups = _groupTracksByDisc(tracks);
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }
    final palette = appPalette(context);
    final rawQuery = inspector.searchQuery?.trim().toLowerCase();
    final highlightTerms = inspector.searchTarget.includesTracks
        ? _musicSearchTerms(rawQuery)
        : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            Text(
              '${tracks.where((track) => !track.isHeader).length} ${tracks.where((track) => !track.isHeader).length == 1 ? 'track' : 'tracks'}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            TextButton.icon(
              onPressed: tracks.isEmpty
                  ? null
                  : () => _copyTracks(context, tracks, group: model.group),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
            ),
            TextButton.icon(
              onPressed: tracks.isEmpty
                  ? null
                  : () => _printTracks(context, tracks, group: model.group),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('Print'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < groups.length; index++) ...[
          _MusicDiscTable(
            discNumber: groups[index].discNumber,
            tracks: groups[index].tracks,
            highlightTerms: highlightTerms,
            onFilterByValue: inspector.onFilterByValue,
          ),
          if (index < groups.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MusicDiscDetails extends StatelessWidget {
  const _MusicDiscDetails({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final model = _musicModel(inspector.item);
    final expectedTrackCount = model.mediums.fold<int>(
      0,
      (total, medium) =>
          total +
          (medium.expectedTrackCount ??
              medium.trackCount ??
              medium.effectiveTrackCount),
    );
    final availableTrackCount = model.mediums.fold<int>(
      0,
      (total, medium) => total + medium.effectiveTrackCount,
    );
    final missingTrackCount = model.mediums.fold<int>(
      0,
      (total, medium) {
        final derived =
            (medium.expectedTrackCount ?? medium.effectiveTrackCount) -
                medium.effectiveTrackCount;
        return total +
            (medium.missingTrackCount ?? (derived > 0 ? derived : 0));
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryDetailFieldTable(
          fields: [
            if (model.mediums.isNotEmpty)
              LibraryDetailField(
                label: 'Media',
                value: '${model.mediums.length}',
              ),
            if (model.mediums.isNotEmpty)
              LibraryDetailField(
                label: 'Tracks',
                value: '$availableTrackCount / $expectedTrackCount',
              ),
            if (missingTrackCount > 0)
              LibraryDetailField(
                label: 'Missing tracks',
                value: missingTrackCount.toString(),
              ),
          ],
        ),
        if (model.mediums.isNotEmpty) const SizedBox(height: 10),
        for (var index = 0; index < model.mediums.length; index++) ...[
          _MusicMediumDetailsCard(
            medium: model.mediums[index],
            storage: model.storageForMedium(model.mediums[index].mediumNumber),
            matrixRunouts:
                model.matrixForMedium(model.mediums[index].mediumNumber),
            showOwnedDetails: model.owned != null,
          ),
          if (index < model.mediums.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MusicMediumDetailsCard extends StatelessWidget {
  const _MusicMediumDetailsCard({
    required this.medium,
    required this.storage,
    required this.matrixRunouts,
    required this.showOwnedDetails,
  });

  final MusicMedium medium;
  final MusicOwnedMediumStorageView storage;
  final List<MusicMatrixRunoutView> matrixRunouts;
  final bool showOwnedDetails;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final playableTracks = medium.effectiveTrackCount;
    final expectedTracks =
        medium.expectedTrackCount ?? medium.trackCount ?? playableTracks;
    final matrix = matrixRunouts
        .where((runout) => runout.text.trim().isNotEmpty)
        .map((runout) => '${runout.side}: ${runout.text.trim()}')
        .join(' | ');
    final rows = <(String, String)>[
      ('Tracks', '$playableTracks / $expectedTracks'),
      if (medium.mediumType?.trim().isNotEmpty == true)
        ('Medium type', medium.mediumType!.trim()),
      if (medium.title?.trim().isNotEmpty == true)
        ('Title', medium.title!.trim()),
      if (medium.soundType?.trim().isNotEmpty == true)
        ('Sound', medium.soundType!.trim()),
      if (medium.spars?.trim().isNotEmpty == true)
        ('SPARS', medium.spars!.trim()),
      if (medium.rpm != null) ('RPM', medium.rpm.toString()),
      if (medium.vinylColor?.trim().isNotEmpty == true)
        ('Vinyl color', medium.vinylColor!.trim()),
      if (medium.vinylWeight?.trim().isNotEmpty == true)
        ('Vinyl weight', medium.vinylWeight!.trim()),
      if (showOwnedDetails && storage.label != '-') ('Storage', storage.label),
      if (showOwnedDetails && matrix.isNotEmpty) ('Matrix / runout', matrix),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        border: Border.all(color: palette.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medium #${medium.mediumNumber}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            LibraryDetailFieldTable(
              fields: [
                for (final row in rows)
                  LibraryDetailField(label: row.$1, value: row.$2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicProductDetails extends StatelessWidget {
  const _MusicProductDetails({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final model = _musicModel(inspector.item);
    final group = model.group;
    final release = model.release;
    if (inspector.item.node is! LibraryReleaseNodeRef) {
      return _MusicReleaseGroupDetails(
        group: group,
        inspector: inspector,
      );
    }
    final medium = release.mediums.firstOrNull;
    final rows = <(String, String)>[
      if (release.subtitle?.trim().isNotEmpty == true)
        ('Edition', release.subtitle!),
      if (release.releaseType?.trim().isNotEmpty == true)
        ('Release type', release.releaseType!),
      if (release.publisher?.trim().isNotEmpty == true)
        ('Label', release.publisher!),
      if (release.catalogNumber?.trim().isNotEmpty == true)
        ('Catalog number', release.catalogNumber!),
      if (release.upc?.trim().isNotEmpty == true) ('UPC', release.upc!),
      if (release.barcode?.trim().isNotEmpty == true)
        ('Barcode', release.barcode!),
      if (medium?.mediumType?.trim().isNotEmpty == true)
        ('Format', medium!.mediumType!),
      if (release.releaseStatus?.trim().isNotEmpty == true)
        ('Release status', release.releaseStatus!),
      if (release.countryCode?.trim().isNotEmpty == true)
        ('Country', release.countryCode!),
      if (release.language?.trim().isNotEmpty == true)
        ('Language', release.language!),
      if (release.boxSetMembership != null) ...[
        ('Part of box set', release.boxSetTitle ?? '-'),
        if (release.boxSetMembership!.sequenceNumber != null)
          (
            'Box set position',
            release.boxSetMembership!.sequenceNumber.toString()
          ),
      ],
      if (medium?.rpm != null) ('RPM', medium!.rpm.toString()),
      if (medium?.soundType?.trim().isNotEmpty == true)
        ('Sound', medium!.soundType!),
      if (medium?.vinylColor?.trim().isNotEmpty == true)
        ('Vinyl color', medium!.vinylColor!),
      if (medium?.vinylWeight?.trim().isNotEmpty == true)
        ('Vinyl weight', medium!.vinylWeight!),
      if (group.metadataJson['local_cover_image_path']
              ?.toString()
              .trim()
              .isNotEmpty ==
          true)
        (
          'Local cover',
          group.metadataJson['local_cover_image_path'].toString()
        ),
      if (group.metadataJson['local_back_image_path']
              ?.toString()
              .trim()
              .isNotEmpty ==
          true)
        ('Local back', group.metadataJson['local_back_image_path'].toString()),
      if (group.metadataJson['local_thumbnail_image_path']
              ?.toString()
              .trim()
              .isNotEmpty ==
          true)
        (
          'Local thumbnail',
          group.metadataJson['local_thumbnail_image_path'].toString()
        ),
    ];
    return LibraryDetailFieldTable(
      fields: [
        for (final row in rows)
          LibraryDetailField(label: row.$1, value: row.$2),
      ],
    );
  }
}

class _MusicReleaseGroupDetails extends StatelessWidget {
  const _MusicReleaseGroupDetails({
    required this.group,
    required this.inspector,
  });

  final MusicReleaseGroup group;
  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final releaseRows = [
      for (var index = 0; index < group.releases.length; index++)
        (
          'Release ${index + 1}',
          _releaseSummary(group.releases[index]),
        ),
    ];
    final rows = <(String, String)>[
      ('Releases', group.releaseCount.toString()),
      if (inspector.item.source.ownedSummary case final owned?) ...[
        if (owned.targetRef?.entityType.apiValue == 'release')
          ('Owned releases', '1'),
        ('Owned copies', owned.quantity.toString()),
      ],
      if (group.genres.isNotEmpty) ('Genres', group.genres.join(', ')),
      if (group.originalReleaseDate != null)
        ('Original release', formatDate(group.originalReleaseDate!)),
      if (group.recordingDate != null)
        ('Recording date', formatDate(group.recordingDate!)),
      if (group.studio?.trim().isNotEmpty == true) ('Studio', group.studio!),
      if (group.synopsis?.trim().isNotEmpty == true) ('Notes', group.synopsis!),
      ...releaseRows,
    ];
    return LibraryDetailFieldTable(
      fields: [
        for (final row in rows)
          LibraryDetailField(label: row.$1, value: row.$2),
      ],
    );
  }
}

String _releaseSummary(MusicRelease release) {
  final values = <String>[
    release.title,
    if (release.publisher?.trim().isNotEmpty == true) release.publisher!,
    if (release.catalogNumber?.trim().isNotEmpty == true)
      'Cat ${release.catalogNumber}',
    if (release.mediums.firstOrNull?.mediumType?.trim().isNotEmpty == true)
      release.mediums.first.mediumType!,
    if (release.boxSetMembership != null)
      'Box set: ${release.boxSetTitle ?? release.boxSetMembership!.boxSetRef.id}',
  ];
  return values.join(' \u00B7 ');
}

class _MusicInspectorDetailsPersonal extends StatelessWidget {
  const _MusicInspectorDetailsPersonal({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final source = inspector.item.source;
    final owned = MusicOwnedItemProjection.fromDispatch(
      inspector.ownedItemDispatch,
    );
    final personalRows = <(String, String)>[
      ('Index', owned?.indexNumber?.toString() ?? '-'),
      ('Quantity', owned?.quantity.toString() ?? '-'),
      if (owned?.isDigital != null)
        ('Media ownership', owned!.isDigital! ? 'Digital' : 'Physical'),
      if (owned?.condition?.trim().isNotEmpty == true)
        ('Condition', owned!.condition!),
      if (owned?.grade?.trim().isNotEmpty == true) ('Grade', owned!.grade!),
      if (source.locationPath?.trim().isNotEmpty == true)
        ('Location', source.locationPath!),
      if (owned?.collectionStatus?.trim().isNotEmpty == true)
        ('Collection status', owned!.collectionStatus!),
      if (owned?.pricePaidCents != null)
        ('Price paid', formatMoney(owned!.pricePaidCents, owned.currency)),
      if (owned?.sellPriceCents != null)
        ('Sell price', formatMoney(owned!.sellPriceCents, owned.currency)),
      if (owned?.marketValueCents != null)
        ('Market value', formatMoney(owned!.marketValueCents, owned.currency)),
      if (owned?.purchaseDate != null)
        ('Purchase date', formatDate(owned!.purchaseDate!)),
      if (owned?.purchaseStore?.trim().isNotEmpty == true)
        ('Purchase store', owned!.purchaseStore!),
      if (owned?.details.signedBy?.trim().isNotEmpty == true)
        ('Signed by', owned!.details.signedBy!),
      if (owned?.details.lastCleanedDate != null)
        ('Last cleaned', formatDate(owned!.details.lastCleanedDate!)),
      if (owned?.tags?.trim().isNotEmpty == true) ('Tags', owned!.tags!),
      if (owned?.personalNotes?.trim().isNotEmpty == true)
        ('Notes', owned!.personalNotes!),
      if (owned?.createdAt != null) ('Added', formatDate(owned!.createdAt!)),
      ('Modified', formatNullableDate(owned?.updatedAt) ?? '-'),
    ];
    List<LibraryDetailField> asFacts(List<(String, String)> rows) {
      return [
        for (final row in rows)
          LibraryDetailField(label: row.$1, value: row.$2),
      ];
    }

    return LibraryDetailFieldTable(
      fields: asFacts(personalRows),
    );
  }
}

class _MusicInspectorCredits extends StatelessWidget {
  const _MusicInspectorCredits({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final release = _musicModel(inspector.item).release;
    final creditRows = libraryCreatorsGroupedByRole([
      for (final contribution in release.contributions) contribution.toJson(),
    ]);
    if (creditRows.isEmpty) {
      return Text(
        '-',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: appPalette(context).textMuted,
              fontWeight: FontWeight.w600,
            ),
      );
    }
    return LibraryDetailFieldTable(
      fields: [
        for (final row in creditRows)
          LibraryDetailField(label: row.$1, value: row.$2),
      ],
    );
  }
}

class _MusicDiscTable extends StatelessWidget {
  const _MusicDiscTable({
    required this.discNumber,
    required this.tracks,
    this.highlightTerms = const <String>[],
    this.onFilterByValue,
  });

  final int discNumber;
  final List<MusicTrackListEntry> tracks;
  final List<String> highlightTerms;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final discDuration = _formatTotalDuration(tracks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Disc #$discNumber',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (discDuration != null) ...[
              const SizedBox(width: 8),
              Text(
                discDuration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        for (final track in tracks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _MusicTrackRow(
              track: track,
              highlight: _matchesTrackTerms(track, highlightTerms),
              onFilterByValue: onFilterByValue,
            ),
          ),
      ],
    );
  }
}

class _MusicTrackRow extends StatelessWidget {
  const _MusicTrackRow({
    required this.track,
    required this.highlight,
    this.onFilterByValue,
  });

  final MusicTrackListEntry track;
  final bool highlight;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final highlightColor = Color.alphaBlend(
      const Color(0xFFE8CF74).withValues(alpha: palette.isDark ? 0.84 : 0.5),
      palette.surface,
    );
    return DecoratedBox(
      key: ValueKey(
          'music-track-row-${track.discNumber}-${track.position}-${track.title}'),
      decoration: BoxDecoration(
        color: highlight ? highlightColor : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          4 + (track.indentLevel * 14),
          track.isHeader ? 5 : 2,
          4,
          track.isHeader ? 5 : 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                track.position,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: track.isHeader
                              ? palette.accent
                              : palette.textPrimary,
                          fontWeight: track.isHeader
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                  ),
                  if (!track.isHeader &&
                      track.artist?.trim().isNotEmpty == true)
                    InkWell(
                      onTap: onFilterByValue == null
                          ? null
                          : () => onFilterByValue!(track.artist!.trim()),
                      borderRadius: BorderRadius.circular(3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          track.artist!.trim(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: onFilterByValue == null
                                        ? palette.textMuted
                                        : inspectorActionColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!track.isHeader && track.durationSeconds != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _formatTrackDuration(track.durationSeconds!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Color inspectorActionColor(BuildContext context) {
  final palette = appPalette(context);
  return palette.accent;
}

Future<void> _copyTracks(
  BuildContext context,
  List<MusicTrackListEntry> tracks, {
  required MusicReleaseGroup group,
}) async {
  final rows = <List<String>>[
    [
      'Release Group Artist',
      'Release Group Title',
      'Release',
      'Disc',
      'Header/Section',
      'Track Number',
      'Track Title',
      'Track Artist',
      'Duration',
      'Catalog Number',
    ],
    for (final track in tracks)
      [
        group.artist ?? '',
        group.title,
        track.releaseTitle ?? '',
        track.discNumber.toString(),
        track.isHeader ? track.title : '',
        track.position,
        track.title,
        track.isHeader || track.artist?.trim().isNotEmpty != true
            ? ''
            : track.artist!.trim(),
        track.isHeader || track.durationSeconds == null
            ? ''
            : _formatTrackDuration(track.durationSeconds!),
        track.catalogNumber ?? '',
      ],
  ];
  await Clipboard.setData(
    ClipboardData(text: _tracksToCsv(rows)),
  );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied track list')),
    );
  }
}

Future<void> _printTracks(
  BuildContext context,
  List<MusicTrackListEntry> tracks, {
  required MusicReleaseGroup group,
}) async {
  final rows = <List<String>>[
    [
      'Release Group Artist',
      'Release Group Title',
      'Release',
      'Disc',
      'Header/Section',
      'Track Number',
      'Track Title',
      'Track Artist',
      'Duration',
      'Catalog Number',
    ],
    for (final track in tracks)
      [
        group.artist ?? '',
        group.title,
        track.releaseTitle ?? '',
        track.discNumber.toString(),
        track.isHeader ? track.title : '',
        track.position,
        track.title,
        track.isHeader || track.artist?.trim().isNotEmpty != true
            ? ''
            : track.artist!.trim(),
        track.isHeader || track.durationSeconds == null
            ? ''
            : _formatTrackDuration(track.durationSeconds!),
        track.catalogNumber ?? '',
      ],
  ];
  final doc = pw.Document(title: 'Track list');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Track list',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2),
                3: pw.FixedColumnWidth(28),
                4: pw.FlexColumnWidth(2),
                5: pw.FixedColumnWidth(34),
                6: pw.FlexColumnWidth(3),
                7: pw.FlexColumnWidth(2),
                8: pw.FixedColumnWidth(44),
                9: pw.FlexColumnWidth(2)
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    for (final value in rows.first) _pdfCell(value, bold: true)
                  ],
                ),
                for (final row in rows.skip(1))
                  pw.TableRow(
                    children: [for (final value in row) _pdfCell(value)],
                  ),
              ],
            ),
          ],
        );
      },
    ),
  );
  await Printing.layoutPdf(
    onLayout: (_) => doc.save(),
    name: 'track_list.pdf',
  );
}

pw.Widget _pdfCell(String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

String _tracksToCsv(List<List<String>> rows) {
  return rows
      .map(
        (row) =>
            row.map((value) => '"${value.replaceAll('"', '""')}"').join(','),
      )
      .join('\n');
}

class _MusicDiscCard extends StatelessWidget {
  const _MusicDiscCard({
    required this.discNumber,
    required this.trackCount,
    this.duration,
  });

  final int discNumber;
  final int trackCount;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Disc #$discNumber',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '$trackCount tracks${duration == null ? '' : ' • $duration'}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicCoverCard extends StatelessWidget {
  const _MusicCoverCard({
    required this.title,
    required this.accent,
    this.coverUrl,
    this.emptyText,
  });

  final String title;
  final String? coverUrl;
  final String? emptyText;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: palette.divider),
          ),
          child: SizedBox(
            height: 120,
            child: coverUrl == null
                ? Center(
                    child: Text(
                      emptyText ?? '-',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                          ),
                    ),
                  )
                : LibraryInteractiveCover(
                    title: title,
                    imageUrl: coverUrl,
                    accentColor: accent,
                    enableFullscreen: false,
                    enableSecondaryControl: false,
                  ),
          ),
        ),
      ],
    );
  }
}

class _DiscTrackGroup {
  const _DiscTrackGroup({
    required this.discNumber,
    required this.tracks,
  });

  final int discNumber;
  final List<MusicTrackListEntry> tracks;
}

int _compareMusicTrackPositions(
  MusicTrackListEntry left,
  MusicTrackListEntry right,
) {
  final leftNumber = _trackPositionNumber(left.position);
  final rightNumber = _trackPositionNumber(right.position);
  if (leftNumber != rightNumber) return leftNumber.compareTo(rightNumber);
  return left.position.toLowerCase().compareTo(right.position.toLowerCase());
}

int _trackPositionNumber(String position) {
  final match = RegExp(r'\d+').firstMatch(position);
  return match == null ? 1 << 30 : int.tryParse(match.group(0)!) ?? 1 << 30;
}

List<_DiscTrackGroup> _groupTracksByDisc(List<MusicTrackListEntry> tracks) {
  if (tracks.isEmpty) {
    return const <_DiscTrackGroup>[];
  }
  final byDisc = <int, List<MusicTrackListEntry>>{};
  for (final track in tracks) {
    final disc = track.discNumber;
    final grouped = byDisc.putIfAbsent(disc, () => <MusicTrackListEntry>[]);
    grouped.add(track);
  }
  final groups = <_DiscTrackGroup>[];
  final sortedDiscs = byDisc.keys.toList(growable: false)..sort();
  for (final disc in sortedDiscs) {
    final discTracks = byDisc[disc]!
      ..sort(
        _compareMusicTrackPositions,
      );
    groups.add(_DiscTrackGroup(discNumber: disc, tracks: discTracks));
  }
  return groups;
}

String _formatTrackDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String? _formatTotalDuration(List<MusicTrackListEntry> tracks) {
  var total = 0;
  for (final track in tracks) {
    if (track.isHeader) continue;
    final duration = track.durationSeconds;
    if (duration != null && duration > 0) {
      total += duration;
    }
  }
  if (total <= 0) {
    return null;
  }
  final minutes = total ~/ 60;
  final seconds = total % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

List<String> _musicSearchTerms(String? query) {
  if (query == null || query.isEmpty) {
    return const <String>[];
  }
  return query
      .split(RegExp(r'\s+'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

bool _matchesTrackTerms(MusicTrackListEntry track, List<String> terms) {
  if (terms.isEmpty) {
    return false;
  }
  final searchable = <String>[
    track.title,
    if (track.artist?.trim().isNotEmpty == true) track.artist!.trim(),
    track.position,
  ].join(' ').toLowerCase();
  return terms.every(searchable.contains);
}

Uri? _ebayUri(LibraryProjectionView item) {
  final dto = item.dto;
  final model = _musicModel(item);
  final group = model.group;
  final release = model.release;
  final barcode = (release.barcode ?? release.upc)?.trim();
  if (barcode == null || barcode.isEmpty) {
    return null;
  }
  final query = <String>[
    barcode,
    if (group.artist?.trim().isNotEmpty == true) group.artist!.trim(),
    dto.title,
    if (release.releaseDate != null) release.releaseDate!.year.toString(),
  ].join(' ');
  return buildEbaySearchUri(
    query: query,
    categoryPath: '/sch/11233/i.html',
    soldOnly: true,
  );
}
