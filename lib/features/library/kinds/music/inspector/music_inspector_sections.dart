import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:collectarr_app/features/library/kinds/music/data/music_library_entry_projection.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart'
    show LibraryEditTextField;
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
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
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
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
import 'package:collectarr_app/features/library/generic/external_links.dart';

MusicInspectorViewModel _musicModel(LibraryProjectionView item) =>
    MusicInspectorViewModel.from(item);

Widget buildMusicInspectorHero(
        BuildContext context, LibraryInspectorRequest request) =>
    _MusicInspectorHeader(inspector: request);

List<Widget> buildMusicInspectorSections(
    BuildContext context, LibraryInspectorRequest request) {
  final model = _musicModel(request.item);
  Widget section(String title, Widget child) => LibraryDetailSection(
      title: title, accentColor: request.accent, children: [child]);
  return [
    if (model.discs.isNotEmpty) ...[
      section('Track List', _MusicInspectorTracks(inspector: request)),
      section('Disc Details', _MusicDiscDetails(inspector: request)),
    ],
    section('Album details', _MusicProductDetails(inspector: request)),
    if (model.entry != null) ...[
      section('Personal', _MusicInspectorDetailsPersonal(inspector: request)),
      section('Listening history', _MusicListeningSection(inspector: request)),
    ],
    section('Credits', _MusicInspectorCredits(inspector: request)),
    if (model.music.externalLinks.isNotEmpty)
      section(
          'Links',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final link in model.music.externalLinks)
              TextButton(
                  onPressed: () => launchUrl(Uri.parse(link.url)),
                  child: Text(link.title ?? link.url)),
          ])),
  ];
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
      musicEntryListeningSummaryProvider(libraryEntryRef),
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
          content: LibraryEditTextField(
            controller: notesController,
            label: 'Notes',
            hint: 'Optional listening notes',
            autofocus: true,
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
      ref.invalidate(musicEntryListeningSummaryProvider(libraryEntryRef));
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
                        fontWeight: FontWeight.w700,
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
          content: LibraryEditTextField(
            controller: notesController,
            label: 'Notes',
            autofocus: true,
            minLines: 1,
            maxLines: 4,
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
      musicEntryListeningSummaryProvider(event.libraryEntryRef),
    );
  }
}

class _MusicInspectorHeader extends ConsumerWidget {
  const _MusicInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = _musicModel(inspector.item);
    final music = model.music;
    final palette = appPalette(context);

    final images = ref
        .watch(musicAlbumImagesProvider(inspector.item.target.id))
        .maybeWhen(
            data: (images) => images, orElse: () => const <MusicAlbumImage>[]);
    final front = images
        .where((image) =>
            image.purpose == MusicAlbumImagePurpose.cover &&
            image.imageType == 'front_cover')
        .firstOrNull;
    final back = images
        .where((image) =>
            image.purpose == MusicAlbumImagePurpose.cover &&
            image.imageType == 'back_cover')
        .firstOrNull;

    final onFilter = inspector.onFilterByValue;
    final isOwned = inspector.item.source.isEntry;
    final artist = music.artist?.trim();
    final year =
        music.releaseDateParts?.year ?? music.originalReleaseDateParts?.year;
    final label = music.publisher?.trim();
    final country = musicCountryName(music.countryCode);
    final trackCount = model.tracks.where((track) => !track.isHeader).length;
    final totalDuration = _formatTotalDuration(model.tracks);

    final preferences = ref.watch(uiPreferencesProvider);
    return LayoutBuilder(builder: (context, constraints) {
      final sideBySide = preferences.showInspectorBackCover &&
          constraints.maxWidth >= 680 &&
          (back != null || music.backCoverImageUrl?.isNotEmpty == true);
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: sideBySide ? 262 : 125,
              child: _MusicInspectorCover(
                title: music.title,
                item: music,
                imageUrl: music.coverImageUrl,
                frontCoverBytes: front?.imageData,
                backCoverBytes: back?.imageData,
                sideBySide: sideBySide,
                accent: inspector.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: artist != null && artist.isNotEmpty
                            ? InkWell(
                                mouseCursor: onFilter != null
                                    ? SystemMouseCursors.click
                                    : MouseCursor.defer,
                                onTap: onFilter != null
                                    ? () => onFilter(artist)
                                    : null,
                                borderRadius: BorderRadius.circular(2),
                                child: Text(
                                  artist,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: palette.isDark
                                            ? Colors.white
                                            : palette.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        height: 1.2,
                                      ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (isOwned) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'In Collection',
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A9FD6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    music.title,
                    style: TextStyle(
                      color: palette.accent,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if ((label != null && label.isNotEmpty) || year != null) ...[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        if (label != null && label.isNotEmpty)
                          InkWell(
                            mouseCursor: onFilter != null
                                ? SystemMouseCursors.click
                                : MouseCursor.defer,
                            onTap:
                                onFilter != null ? () => onFilter(label) : null,
                            borderRadius: BorderRadius.circular(2),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (year != null)
                          InkWell(
                            mouseCursor: onFilter != null
                                ? SystemMouseCursors.click
                                : MouseCursor.defer,
                            onTap: onFilter != null
                                ? () => onFilter(year.toString())
                                : null,
                            borderRadius: BorderRadius.circular(2),
                            child: Text(
                              '($year)',
                              style: TextStyle(
                                color: palette.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (music.genres.isNotEmpty) ...[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        for (var i = 0; i < music.genres.length; i++) ...[
                          InkWell(
                            mouseCursor: onFilter != null
                                ? SystemMouseCursors.click
                                : MouseCursor.defer,
                            onTap: onFilter != null
                                ? () => onFilter(music.genres[i])
                                : null,
                            borderRadius: BorderRadius.circular(2),
                            child: Text(
                              music.genres[i],
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (i < music.genres.length - 1)
                            Text(
                              '|',
                              style: TextStyle(
                                color: palette.divider,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (music.barcode?.isNotEmpty == true || country != null) ...[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        if (music.barcode?.isNotEmpty == true)
                          Text(
                            'Barcode ${music.barcode!}',
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        if (music.barcode?.isNotEmpty == true &&
                            country != null)
                          Text(
                            '•',
                            style: TextStyle(
                              color: palette.divider,
                              fontSize: 10,
                            ),
                          ),
                        if (country != null)
                          Text(
                            country,
                            style: TextStyle(
                              color: palette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Builder(
                    builder: (context) {
                      final metrics = <String>[
                        if (model.discs.isNotEmpty)
                          '${model.discs.length} ${model.discs.length == 1 ? 'Disc' : 'Discs'}',
                        if (trackCount > 0) '$trackCount Tracks',
                        if (totalDuration != null) totalDuration,
                      ];
                      if (metrics.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          metrics.join(' | '),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (music.catalogNumber?.isNotEmpty == true)
                        Text(
                          'cat no ${music.catalogNumber!}',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      if (preferences.ebayNextToCover &&
                          preferences.allowsEbayLinks(
                              inspector.item.source.isWishlisted))
                        InkWell(
                          mouseCursor: SystemMouseCursors.click,
                          onTap: () {
                            final query = [
                              if (music.artist?.trim().isNotEmpty == true)
                                music.artist!.trim(),
                              music.title.trim(),
                              if (music.catalogNumber?.trim().isNotEmpty ==
                                  true)
                                music.catalogNumber!.trim(),
                            ].join(' ');
                            launchEbaySearch(query,
                                isWishlisted:
                                    inspector.item.source.isWishlisted);
                          },
                          borderRadius: BorderRadius.circular(3),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'eBay',
                                  style: TextStyle(
                                    color: palette.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: palette.accent,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.open_in_new,
                                  size: 11,
                                  color: palette.accent,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
                    fontWeight: FontWeight.w700,
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
          showHeader: false,
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
      if (disc.format?.trim().isNotEmpty == true)
        ('Format', disc.format!.trim()),
      if (disc.recordingDate != null)
        ('Recording date', disc.recordingDate!.toString()),
      if (disc.recordingLocations.isNotEmpty)
        ('Recording locations', disc.recordingLocations.join(', ')),
      if (disc.isLive != null) ('Recording', disc.isLive! ? 'Live' : 'Studio'),
      if (disc.sparsCode?.trim().isNotEmpty == true) ('SPARS', disc.sparsCode!),
      if (disc.soundTypes.isNotEmpty) ('Sound', disc.soundTypes.join(', ')),
      if (disc.color?.trim().isNotEmpty == true) ('Color', disc.color!.trim()),
      if (disc.vinylWeightGrams != null)
        ('Weight', '${disc.vinylWeightGrams} g'),
      if (disc.rpm != null) ('RPM', disc.rpm!),
      if (disc.matrixNumber?.trim().isNotEmpty == true)
        ('Matrix / Runout', disc.matrixNumber!.trim()),
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
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            LibraryDetailFieldTable(
              showHeader: false,
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
    this.sideBySide = false,
    required this.accent,
  });

  final String title;
  final MusicAlbum item;
  final String? imageUrl;
  final Uint8List? frontCoverBytes;
  final Uint8List? backCoverBytes;
  final bool sideBySide;
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
    if (kIsWeb || normalizedPath == null || normalizedPath.isEmpty) return null;
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
  bool get _hasBack =>
      _back?.isNotEmpty == true ||
      widget.item.backCoverImageUrl?.isNotEmpty == true;

  Widget _cover({required bool back}) => AspectRatio(
        aspectRatio: 1.0,
        child: LibraryInteractiveCover(
          title: '${widget.title} ${back ? 'back cover' : 'front cover'}',
          imageUrl: back ? widget.item.backCoverImageUrl : widget.imageUrl,
          localBytes: back ? _back : _front,
          fallbackAspectRatio: 1.0,
          fit: BoxFit.contain,
          accentColor: widget.accent,
        ),
      );

  Widget _selectorDot(bool back) {
    final isSelected = _showBack == back;
    return Tooltip(
      message: back
          ? (_hasBack ? 'Back cover' : 'Back cover (empty)')
          : 'Front cover',
      child: GestureDetector(
        onTap: () => setState(() => _showBack = back),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: isSelected ? 8 : 6,
              height: isSelected ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? widget.accent
                    : Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sideBySide && _hasBack) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _cover(back: false)),
        const SizedBox(width: 12),
        Expanded(child: _cover(back: true)),
      ]);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _cover(back: _showBack),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectorDot(false),
              _selectorDot(true),
            ],
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
      if (release.formatSummary?.trim().isNotEmpty == true)
        ('Format', release.formatSummary!),
      if (release.packaging?.trim().isNotEmpty == true)
        ('Packaging', release.packaging!),
      if (musicCountryName(release.countryCode) case final country?)
        ('Country', country),
      if (release.boxSet?.trim().isNotEmpty == true)
        ('Box Set', release.boxSet!),
      if (release.releaseDateParts != null)
        ('Release date', release.releaseDateParts!.toString()),
      if (release.originalReleaseDateParts != null)
        ('Original release date', release.originalReleaseDateParts!.toString()),
      if (release.localCoverImagePath?.trim().isNotEmpty == true)
        ('Local cover', release.localCoverImagePath!),
      if (release.localBackImagePath?.trim().isNotEmpty == true)
        ('Local back', release.localBackImagePath!),
      if (release.localThumbnailImagePath?.trim().isNotEmpty == true)
        ('Local thumbnail', release.localThumbnailImagePath!),
    ];
    return LibraryDetailFieldTable(
      showHeader: false,
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
      showHeader: false,
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
    final credits = [
      for (final credit in release.credits) (credit: credit, scope: 'Album'),
      for (final disc in release.discs)
        for (final credit in disc.credits)
          (credit: credit, scope: 'Disc ${disc.discNumber}'),
    ];
    return LibraryDetailFieldTable(showHeader: false, fields: [
      for (final row in credits)
        LibraryDetailField(
          label: '${row.credit.role} / ${row.scope}',
          value: [
            row.credit.name,
            if (row.credit.instruments.isNotEmpty)
              row.credit.instruments.join(', ')
          ].join(' - '),
          onTap: inspector.onFilterByValue == null
              ? null
              : () => inspector.onFilterByValue!(row.credit.name),
        ),
    ]);
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
                    fontWeight: FontWeight.w700,
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
                              ? FontWeight.w700
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
