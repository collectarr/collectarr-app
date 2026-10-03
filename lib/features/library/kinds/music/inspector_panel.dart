import 'dart:io';

import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
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
import 'package:collectarr_app/features/library/kinds/music/domain/music_album.dart';
import 'package:collectarr_app/features/library/kinds/music/music_country_name.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_disc.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track_list_entry.dart';
import 'package:collectarr_app/features/library/kinds/music/inspector/music_inspector_view_model.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_album_image_providers.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_album_image.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

MusicInspectorViewModel _musicModel(LibraryProjectionView item) =>
    MusicInspectorViewModel.from(item);

MusicAlbum? _musicItem(LibraryProjectionView item) => _musicModel(item).music;

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
        onToggleEntry: request.onToggleEntry,
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
          children: [_MusicInspectorTracks(inspector: inspector)],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.metadata,
          title: 'Disc Details',
          children: [_MusicDiscDetails(inspector: inspector)],
        ),
        LibraryDetailSectionSpec(
          slot: LibraryDetailSectionSlot.notes,
          title: 'Album details',
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
    final entry = model.entry;
    if (entry == null) return const SizedBox.shrink();
    final libraryEntryRef = LibraryEntryRef(
      kind: CatalogMediaKind.music,
      id: LibraryEntryId(entry.id.value),
    );
    final summary = ref.watch(
      musicCatalogItemListeningSummaryProvider(libraryEntryRef),
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
                        : '${stats.totalListenCount} ${stats.totalListenCount == 1 ? 'listen' : 'listens'} / Last ${formatDate(stats.lastListened!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appPalette(context).textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _logListen(context, ref, model, libraryEntryRef),
                  icon: const Icon(Icons.headphones_outlined, size: 16),
                  label: const Text('Log listen'),
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

  Future<void> _logListen(
    BuildContext context,
    WidgetRef ref,
    MusicInspectorViewModel model,
    LibraryEntryRef libraryEntryRef,
  ) async {
    final notesController = TextEditingController();
    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AccentAlertDialog(
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
      await ref.read(musicListeningMutationsProvider).upsert(
            MusicListenEvent(
              id: 'listen-${now.microsecondsSinceEpoch}',
              libraryEntryRef: libraryEntryRef,
              listenedAt: now,
              notes: notesController.text.trim().isEmpty
                  ? null
                  : notesController.text.trim(),
              createdAt: now,
              updatedAt: now,
            ),
          );
      ref.invalidate(musicListeningEventsProvider(libraryEntryRef));
      ref.invalidate(musicCatalogItemListeningSummaryProvider(libraryEntryRef));
      ref.invalidate(shelfProvider);
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
                    ].join(' / '),
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
        builder: (dialogContext) => AccentAlertDialog(
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
      await ref.read(musicListeningMutationsProvider).upsert(
            MusicListenEvent(
              id: event.id,
              libraryEntryRef: event.libraryEntryRef,
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
      builder: (dialogContext) => AccentAlertDialog(
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
    await ref.read(musicListeningMutationsProvider).markDeleted(
          event,
          DateTime.now().toUtc(),
        );
    _invalidate(ref);
  }

  void _invalidate(WidgetRef ref) {
    ref.invalidate(shelfProvider);
    ref.invalidate(musicListeningEventsProvider(event.libraryEntryRef));
    ref.invalidate(
      musicCatalogItemListeningSummaryProvider(event.libraryEntryRef),
    );
  }
}

class _MusicInspectorHeader extends StatelessWidget {
  const _MusicInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final music = _musicItem(inspector.item);
    final artist = music?.artist?.trim();
    return LibraryInspectorTitleCard(
      item: inspector.item,
      eyebrow: artist,
      accent: inspector.accent,
    );
  }
}

class _MusicInspectorMain extends ConsumerWidget {
  const _MusicInspectorMain({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = _musicModel(inspector.item);
    final music = model.music;
    final release = music;
    final tracks = model.tracks;
    final palette = appPalette(context);
    final discGroups = _groupTracksByDisc(tracks);
    final discCount = discGroups.length;
    final totalTracks = tracks.where((entry) => !entry.isHeader).length;
    final totalDuration = _formatTotalDuration(tracks);
    final dto = inspector.item.dto;
    final coverUrl = release.coverImageUrl ?? music.coverImageUrl;
    final releaseImages =
        ref.watch(musicAlbumImagesProvider(release.id.value)).maybeWhen(
              data: (images) => images,
              orElse: () => const <MusicAlbumImage>[],
            );
    final releaseFrontCover = releaseImages
        .where((image) =>
            image.purpose == MusicAlbumImagePurpose.cover &&
            image.imageType == 'front_cover')
        .firstOrNull;
    final releaseBackCover = releaseImages
        .where((image) =>
            image.purpose == MusicAlbumImagePurpose.cover &&
            image.imageType == 'back_cover')
        .firstOrNull;
    final formatLabel = release.format ?? release.packaging ?? '-';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showBothCovers = constraints.maxWidth >= 720;
            final coverWidth = showBothCovers ? 236.0 : 164.0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: coverWidth,
                    height: 164,
                    child: _MusicInspectorCover(
                      title: dto.primaryLabel,
                      item: music,
                      imageUrl: coverUrl,
                      frontCoverBytes: releaseFrontCover?.imageData,
                      backCoverBytes: releaseBackCover?.imageData,
                      showBothWhenRoom: showBothCovers,
                      accent: inspector.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        release.title,
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
                      if (release.catalogNumber?.trim().isNotEmpty == true)
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
                              localBytes: releaseFrontCover?.imageData,
                              accent: inspector.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MusicCoverCard(
                              title: 'Back cover',
                              coverUrl: null,
                              localBytes: releaseBackCover?.imageData,
                              accent: inspector.accent,
                              emptyText: 'Back cover not in metadata',
                            ),
                          ),
                        ],
                      ),
                      if (_ebayUri(inspector.item) case final uri?) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          mouseCursor: WidgetStateMouseCursor.clickable,
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
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
            );
          },
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            TextButton.icon(
              onPressed: tracks.isEmpty
                  ? null
                  : () => _copyTracks(context, tracks, item: model.music),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
            ),
            TextButton.icon(
              onPressed: tracks.isEmpty
                  ? null
                  : () => _printTracks(context, tracks, item: model.music),
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
    final trackCount = model.discs.fold<int>(
      0,
      (total, disc) => total + disc.effectiveTrackCount,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LibraryDetailFieldTable(
          fields: [
            if (model.discs.isNotEmpty)
              LibraryDetailField(
                label: 'Discs',
                value: '${model.discs.length}',
              ),
            if (model.discs.isNotEmpty)
              LibraryDetailField(
                label: 'Tracks',
                value: trackCount.toString(),
              ),
          ],
        ),
        if (model.discs.isNotEmpty) const SizedBox(height: 10),
        for (var index = 0; index < model.discs.length; index++) ...[
          _MusicDiscDetailsCard(
            disc: model.discs[index],
            storage: model.storageForDisc(model.discs[index].discNumber),
            showEntryDetails: model.entry != null,
          ),
          if (index < model.discs.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MusicDiscDetailsCard extends StatelessWidget {
  const _MusicDiscDetailsCard({
    required this.disc,
    required this.storage,
    required this.showEntryDetails,
  });

  final MusicDisc disc;
  final MusicEntryDiscStorageView storage;
  final bool showEntryDetails;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final playableTracks = disc.effectiveTrackCount;
    final rows = <(String, String)>[
      ('Tracks', playableTracks.toString()),
      if (disc.title?.trim().isNotEmpty == true) ('Title', disc.title!.trim()),
      if (disc.matrixNumberSideA?.trim().isNotEmpty == true)
        ('Matrix side A', disc.matrixNumberSideA!.trim()),
      if (disc.matrixNumberSideB?.trim().isNotEmpty == true)
        ('Matrix side B', disc.matrixNumberSideB!.trim()),
      if (showEntryDetails && storage.label != '-') ('Storage', storage.label),
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
              'Disc #${disc.discNumber}',
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

final class _MusicInspectorCover extends StatefulWidget {
  const _MusicInspectorCover({
    required this.title,
    required this.item,
    required this.imageUrl,
    this.frontCoverBytes,
    this.backCoverBytes,
    this.showBothWhenRoom = false,
    required this.accent,
  });

  final String title;
  final MusicAlbum item;
  final String? imageUrl;
  final Uint8List? frontCoverBytes;
  final Uint8List? backCoverBytes;
  final bool showBothWhenRoom;
  final Color accent;

  @override
  State<_MusicInspectorCover> createState() => _MusicInspectorCoverState();
}

final class _MusicInspectorCoverState extends State<_MusicInspectorCover> {
  var _showBack = false;
  Uint8List? _frontBytes;
  Uint8List? _backBytes;
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadLocalCovers();
  }

  @override
  void didUpdateWidget(covariant _MusicInspectorCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.localCoverImagePath != widget.item.localCoverImagePath ||
        oldWidget.item.localBackImagePath != widget.item.localBackImagePath ||
        oldWidget.frontCoverBytes != widget.frontCoverBytes ||
        oldWidget.backCoverBytes != widget.backCoverBytes ||
        oldWidget.imageUrl != widget.imageUrl) {
      _showBack = false;
      _frontBytes = null;
      _backBytes = null;
      _loadLocalCovers();
    }
  }

  Future<void> _loadLocalCovers() async {
    final generation = ++_loadGeneration;
    final bytes = await Future.wait<Uint8List?>([
      _readCover(widget.item.localCoverImagePath),
      _readCover(widget.item.localBackImagePath),
    ]);
    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _frontBytes = bytes[0];
      _backBytes = bytes[1];
    });
  }

  Future<Uint8List?> _readCover(String? path) async {
    final normalizedPath = path?.trim();
    if (normalizedPath == null || normalizedPath.isEmpty) return null;
    try {
      final file = File(normalizedPath);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } on FileSystemException {
      return null;
    }
  }

  Uint8List? get _front => widget.frontCoverBytes ?? _frontBytes;
  Uint8List? get _back => widget.backCoverBytes ?? _backBytes;
  bool get _hasBack => _back?.isNotEmpty == true;

  Widget _cover({required bool back}) => LibraryInteractiveCover(
        title: '${widget.title} ${back ? 'back cover' : 'front cover'}',
        imageUrl: back ? null : widget.imageUrl,
        localBytes: back ? _back : _front,
        fit: BoxFit.contain,
        accentColor: widget.accent,
      );

  Widget _selectorDot(bool back) => Tooltip(
        message: back ? 'Back cover' : 'Front cover',
        child: GestureDetector(
          onTap: () => setState(() => _showBack = back),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: _showBack == back ? 10 : 8,
                height: _showBack == back ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _showBack == back
                      ? widget.accent
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final showBoth = widget.showBothWhenRoom && _hasBack;
    return Column(
      children: [
        Expanded(
          child: showBoth
              ? Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _cover(back: false),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: _cover(back: true),
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _cover(back: _showBack),
                ),
        ),
        if (_hasBack)
          SizedBox(
            height: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_selectorDot(false), _selectorDot(true)],
            ),
          ),
      ],
    );
  }
}

class _MusicProductDetails extends StatelessWidget {
  const _MusicProductDetails({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final model = _musicModel(inspector.item);
    final release = model.music;
    final rows = <(String, String)>[
      if (release.subtitle?.trim().isNotEmpty == true)
        ('Edition', release.subtitle!),
      if (release.publisher?.trim().isNotEmpty == true)
        ('Label', release.publisher!),
      if (release.catalogNumber?.trim().isNotEmpty == true)
        ('Catalog number', release.catalogNumber!),
      if (release.barcode?.trim().isNotEmpty == true)
        ('Barcode', release.barcode!),
      if (release.format?.trim().isNotEmpty == true)
        ('Format', release.format!),
      if (release.packaging?.trim().isNotEmpty == true)
        ('Packaging', release.packaging!),
      if (musicCountryName(release.countryCode) case final country?)
        ('Country', country),
      if (release.boxSet?.trim().isNotEmpty == true)
        ('Box Set', release.boxSet!),
      if (release.soundTypes.isNotEmpty)
        ('Sound', release.soundTypes.join(', ')),
      if (release.spars?.trim().isNotEmpty == true) ('SPARS', release.spars!),
      if (release.rpm != null) ('RPM', release.rpm.toString()),
      if (release.vinylColor?.trim().isNotEmpty == true)
        ('Vinyl color', release.vinylColor!),
      if (release.vinylWeight?.trim().isNotEmpty == true)
        ('Vinyl weight', release.vinylWeight!),
      if (release.localCoverImagePath?.trim().isNotEmpty == true)
        ('Local cover', release.localCoverImagePath!),
      if (release.localBackImagePath?.trim().isNotEmpty == true)
        ('Local back', release.localBackImagePath!),
      if (release.localThumbnailImagePath?.trim().isNotEmpty == true)
        ('Local thumbnail', release.localThumbnailImagePath!),
    ];
    return LibraryDetailFieldTable(
      fields: [
        for (final row in rows)
          LibraryDetailField(label: row.$1, value: row.$2),
      ],
    );
  }
}

class _MusicInspectorDetailsPersonal extends StatelessWidget {
  const _MusicInspectorDetailsPersonal({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final source = inspector.item.source;
    final entry = MusicLibraryEntryProjection.fromDispatch(
      inspector.libraryEntryDispatch,
    );
    final personalRows = <(String, String)>[
      ('Index', entry?.personal.indexNumber?.toString() ?? '-'),
      if (entry?.personal.isDigital != null)
        ('Media entries', entry!.personal.isDigital! ? 'Digital' : 'Physical'),
      if (entry?.personal.condition?.trim().isNotEmpty == true)
        ('Condition', entry!.personal.condition!),
      if (entry?.personal.grade?.trim().isNotEmpty == true)
        ('Grade', entry!.personal.grade!),
      if (source.locationPath?.trim().isNotEmpty == true)
        ('Location', source.locationPath!),
      if (entry?.personal.collectionStatus?.trim().isNotEmpty == true)
        ('Collection status', entry!.personal.collectionStatus!),
      if (entry?.personal.pricePaidCents != null)
        (
          'Price paid',
          formatMoney(entry!.personal.pricePaidCents, entry.personal.currency)
        ),
      if (entry?.personal.sellPriceCents != null)
        (
          'Sell price',
          formatMoney(entry!.personal.sellPriceCents, entry.personal.currency)
        ),
      if (entry?.personal.marketValueCents != null)
        (
          'Market value',
          formatMoney(entry!.personal.marketValueCents, entry.personal.currency)
        ),
      if (entry?.personal.purchaseDate != null)
        ('Purchase date', formatDate(entry!.personal.purchaseDate!)),
      if (entry?.personal.purchaseStore?.trim().isNotEmpty == true)
        ('Purchase store', entry!.personal.purchaseStore!),
      if (entry?.personal.details.signedBy?.trim().isNotEmpty == true)
        ('Signed by', entry!.personal.details.signedBy!),
      if (entry?.personal.details.lastCleanedDate != null)
        ('Last cleaned', formatDate(entry!.personal.details.lastCleanedDate!)),
      if (entry?.personal.tags?.trim().isNotEmpty == true)
        ('Tags', entry!.personal.tags!),
      if (entry?.personal.personalNotes?.trim().isNotEmpty == true)
        ('Notes', entry!.personal.personalNotes!),
      if (entry?.createdAt != null) ('Added', formatDate(entry!.createdAt!)),
      ('Modified', formatNullableDate(entry?.updatedAt) ?? '-'),
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
    final release = _musicModel(inspector.item).music;
    final contributions = release.contributions;
    final creditRows = libraryCreatorsGroupedByRole([
      for (final contribution in contributions) contribution.toJson(),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      mouseCursor: WidgetStateMouseCursor.clickable,
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
  required MusicAlbum item,
}) async {
  final rows = <List<String>>[
    [
      'Album Artist',
      'Album',
      'Edition',
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
        item.artist ?? '',
        item.title,
        track.albumTitle ?? '',
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
  required MusicAlbum item,
}) async {
  final rows = <List<String>>[
    [
      'Album Artist',
      'Album',
      'Edition',
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
        item.artist ?? '',
        item.title,
        track.albumTitle ?? '',
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
        fontSize: 12,
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
              '$trackCount tracks${duration == null ? '' : ' / $duration'}',
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
    this.localBytes,
    this.emptyText,
  });

  final String title;
  final String? coverUrl;
  final Uint8List? localBytes;
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
            child: coverUrl == null && localBytes == null
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
                    localBytes: localBytes,
                    accentColor: accent,
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
  final music = model.music;
  final release = music;
  final barcode = release.barcode?.trim();
  if (barcode == null || barcode.isEmpty) {
    return null;
  }
  final query = <String>[
    barcode,
    if (music.artist?.trim().isNotEmpty == true) music.artist!.trim(),
    dto.primaryLabel,
    if (release.releaseDate != null) release.releaseDate!.year.toString(),
  ].join(' ');
  return buildEbaySearchUri(
    query: query,
    categoryPath: '/sch/11233/i.html',
    soldOnly: true,
  );
}
