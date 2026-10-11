import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
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
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_data.dart';
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
      title: title,
      accentColor: request.accent,
      collapsible: false,
      children: [child]);
  return [
    if (model.discs.isNotEmpty) ...[
      Padding(
          padding: const EdgeInsets.all(12),
          child: _MusicInspectorTracks(inspector: request)),
    ],
    if (model.music.credits.isNotEmpty ||
        model.discs.any((disc) => disc.credits.isNotEmpty))
      section('Credits', _MusicInspectorCredits(inspector: request)),
    section('Details', _MusicProductDetails(inspector: request)),
    if (model.discs.isNotEmpty)
      section('Disc Details', _MusicDiscDetails(inspector: request)),
    if (model.entry != null) ...[
      section('Personal', _MusicInspectorDetailsPersonal(inspector: request)),
      section('Listening history', _MusicListeningSection(inspector: request)),
    ],
    if (model.entry?.personal.personalNotes?.trim().isNotEmpty == true)
      section(
          'Notes',
          Text(model.entry!.personal.personalNotes!,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
    if (model.entry?.personal.tags?.trim().isNotEmpty == true)
      section(
          'Tags',
          Wrap(spacing: 8, runSpacing: 4, children: [
            for (final tag in model.entry!.personal.tags!
                .split('|')
                .map((v) => v.trim())
                .where((v) => v.isNotEmpty))
              TextButton.icon(
                  onPressed: request.onFilterByValue == null
                      ? null
                      : () => request.onFilterByValue!(tag),
                  icon: const Icon(Icons.local_offer_outlined, size: 14),
                  label: Text(tag))
          ])),
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
    final boxSetAlbums = music.boxSet?.isNotEmpty == true
        ? (ref.watch(shelfProvider).asData?.value.entries ??
                const <LibraryWorkspaceContext>[])
            .where((entry) =>
                entry.kindPresentationData is MusicWorkspaceData &&
                (entry.kindPresentationData as MusicWorkspaceData)
                        .music
                        .boxSet ==
                    music.boxSet)
            .toList()
        : const <LibraryWorkspaceContext>[];
    return LayoutBuilder(builder: (context, constraints) {
      final sideBySide = preferences.showInspectorBackCover &&
          constraints.maxWidth >= 680 &&
          (back != null || music.backCoverImageUrl?.isNotEmpty == true);
      final coverWidth = sideBySide
          ? 430.0
          : constraints.maxWidth >= 600
              ? 210.0
              : (constraints.maxWidth * .42).clamp(90.0, 150.0);
      Widget valueLink(String value) => InkWell(
          onTap: onFilter == null ? null : () => onFilter(value),
          child: Text(value,
              style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)));
      final metadata =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 4, children: [
          if (label?.isNotEmpty == true) valueLink(label!),
          if (year != null) valueLink('($year)')
        ]),
        if (music.genres.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(spacing: 4, children: [
            for (var i = 0; i < music.genres.length; i++) ...[
              if (i > 0) const Text('|'),
              valueLink(music.genres[i])
            ]
          ])
        ],
        if (MusicLibraryEntryProjection.fromDispatch(
                    inspector.libraryEntryDispatch)
                ?.personal
                .rating
            case final rating?) ...[
          const SizedBox(height: 14),
          Container(
              width: 64,
              height: 40,
              decoration: BoxDecoration(
                  color: inspector.accent,
                  borderRadius: BorderRadius.circular(4)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.star, size: 22, color: Colors.white),
                const SizedBox(width: 6),
                Text('$rating',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ])),
        ],
        const SizedBox(height: 18),
        if (music.barcode?.isNotEmpty == true)
          Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.view_week_outlined, size: 20),
                Text(music.barcode!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700))
              ]),
        if (country != null) valueLink(country),
        Text(
            [
              if (music.formatSummary?.isNotEmpty == true) music.formatSummary!,
              if (model.discs.isNotEmpty)
                '${model.discs.length} ${model.discs.length == 1 ? 'Disc' : 'Discs'}',
              if (trackCount > 0)
                '$trackCount ${trackCount == 1 ? 'Track' : 'Tracks'}',
              if (totalDuration != null) totalDuration
            ].join(' | '),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        if (music.catalogNumber?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: 'CAT NO  ',
                style: TextStyle(color: palette.textMuted, fontSize: 10)),
            TextSpan(
                text: music.catalogNumber!,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))
          ]))
        ],
        if (preferences.ebayNextToCover &&
            preferences
                .allowsEbayLinks(inspector.item.source.isWishlisted)) ...[
          const SizedBox(height: 12),
          InkWell(
              onTap: () => launchEbaySearch(
                  [
                    if (artist?.isNotEmpty == true) artist!,
                    music.title,
                    if (music.catalogNumber?.isNotEmpty == true)
                      music.catalogNumber!
                  ].join(' '),
                  isWishlisted: inspector.item.source.isWishlisted),
              child: Text('Find sold listings on eBay',
                  style: TextStyle(
                      fontSize: 14,
                      color: inspector.accent,
                      decoration: TextDecoration.underline))),
        ],
      ]);
      return Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (music.boxSet?.trim().isNotEmpty == true) ...[
              Text(music.boxSet!,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: inspector.accent)),
              const Divider(height: 18),
              for (var i = 0; i < boxSetAlbums.length; i++)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                        onTap: onFilter == null
                            ? null
                            : () => onFilter(music.boxSet!),
                        child: Text('${i + 1}  ${boxSetAlbums[i].title}',
                            style: TextStyle(
                                fontSize: 14, color: inspector.accent)))),
              const Divider(height: 32),
            ],
            if (artist?.isNotEmpty == true)
              InkWell(
                  onTap: onFilter == null ? null : () => onFilter(artist!),
                  child: Text(artist!,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700))),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text(music.title,
                      style: TextStyle(
                          color: inspector.accent,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.1))),
              if (model.entry?.personal.quantity case final quantity?
                  when quantity > 1)
                Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text('Qty: $quantity',
                        style: const TextStyle(fontWeight: FontWeight.w700))),
              if (isOwned)
                Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Tooltip(
                        message: 'In Collection',
                        child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                color: inspector.accent,
                                borderRadius: BorderRadius.circular(3)),
                            child: Icon(Icons.check,
                                size: 22,
                                color: appContrastingTextColor(
                                    inspector.accent))))),
            ]),
            if (music.subtitle?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(music.subtitle!,
                  style: TextStyle(fontSize: 16, color: palette.textMuted))
            ],
            const SizedBox(height: 12),
            if (constraints.maxWidth < 280) ...[
              SizedBox(
                  width: coverWidth,
                  child: _MusicInspectorCover(
                      title: music.title,
                      item: music,
                      imageUrl: music.coverImageUrl,
                      frontCoverBytes: front?.imageData,
                      backCoverBytes: back?.imageData,
                      sideBySide: false,
                      accent: inspector.accent)),
              const SizedBox(height: 12),
              metadata,
            ] else
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: coverWidth,
                    child: _MusicInspectorCover(
                        title: music.title,
                        item: music,
                        imageUrl: music.coverImageUrl,
                        frontCoverBytes: front?.imageData,
                        backCoverBytes: back?.imageData,
                        sideBySide: sideBySide,
                        accent: inspector.accent)),
                const SizedBox(width: 20),
                Expanded(child: metadata),
              ]),
          ]));
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
    final rawQuery = inspector.searchQuery?.trim().toLowerCase();
    final highlightTerms = inspector.searchTarget.includesTracks
        ? _musicSearchTerms(rawQuery)
        : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          _MusicDiscTable(
            disc: model.discs.firstWhere(
                (disc) => disc.discNumber == groups[index].discNumber),
            storage: model.storageForDisc(groups[index].discNumber),
            accent: inspector.accent,
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
          minCellWidth: 400,
          labelWidth: 132,
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
        border: Border(bottom: BorderSide(color: palette.divider)),
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
              minCellWidth: 400,
              labelWidth: 132,
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
      if (release.extra.isNotEmpty) ('Extra', release.extra.join(' | ')),
    ];
    return LibraryDetailFieldTable(
      minCellWidth: 400,
      labelWidth: 132,
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
      if (entry != null) ('Quantity', entry.personal.quantity.toString()),
      if (entry?.personal.rating != null)
        ('My Rating', '${entry!.personal.rating}/10'),
      if (entry?.personal.ownerLabel != null)
        ('Owner', entry!.personal.ownerLabel!),
      if (entry?.personal.mediaCondition != null)
        ('Media Condition', entry!.personal.mediaCondition!),
      if (entry?.personal.marketValueCents != null)
        (
          'Current Value',
          formatMoney(entry!.personal.marketValueCents, entry.personal.currency)
        ),
      if (entry?.personal.soldAt != null)
        ('Sold Date', formatDate(entry!.personal.soldAt!)),
      if (entry?.personal.soldTo != null) ('Sold To', entry!.personal.soldTo!),
      if (entry?.personal.isDigital != null)
        ('Media entries', entry!.personal.isDigital! ? 'Digital' : 'Physical'),
      if (entry?.personal.condition?.trim().isNotEmpty == true)
        ('Condition', entry!.personal.condition!),
      if (entry?.personal.grade?.trim().isNotEmpty == true)
        ('Grade', entry!.personal.grade!),
      if (source.locationPath?.trim().isNotEmpty == true)
        ('Location', source.locationPath!),
      if (entry?.personal.collectionStatus?.trim().isNotEmpty == true)
        (
          'Collection status',
          libraryCollectionStatusFromValue(entry!.personal.collectionStatus)
              .label
        ),
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
      if (entry?.personal.purchaseDate != null)
        ('Purchase date', formatDate(entry!.personal.purchaseDate!)),
      if (entry?.personal.purchaseStore?.trim().isNotEmpty == true)
        ('Purchase store', entry!.personal.purchaseStore!),
      if (entry?.personal.details.signedBy?.trim().isNotEmpty == true)
        ('Signed by', entry!.personal.details.signedBy!),
      if (entry?.personal.details.lastCleanedDate != null)
        ('Last cleaned', formatDate(entry!.personal.details.lastCleanedDate!)),
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
      minCellWidth: 400,
      labelWidth: 132,
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
    return LibraryDetailFieldTable(
        showHeader: false,
        labelWidth: 132,
        minCellWidth: 400,
        fields: [
          if (release.artist?.isNotEmpty == true)
            LibraryDetailField(label: 'Artist', value: release.artist!),
          for (final row in credits)
            LibraryDetailField(
              label: row.scope == 'Album'
                  ? row.credit.role
                  : '${row.credit.role} / ${row.scope}',
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
    required this.disc,
    required this.storage,
    required this.accent,
    required this.tracks,
    this.highlightTerms = const <String>[],
    this.onFilterByValue,
  });

  final MusicDisc disc;
  final MusicEntryDiscStorageView storage;
  final Color accent;
  final List<MusicTrackListEntry> tracks;
  final List<String> highlightTerms;
  final ValueChanged<String>? onFilterByValue;

  @override
  Widget build(BuildContext context) {
    final discDuration = _formatTotalDuration(tracks);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
            color: accent.withValues(alpha: .2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text(
                      [
                        disc.title?.isNotEmpty == true
                            ? disc.title!
                            : 'Disc #${disc.discNumber}',
                        if (storage.label != '-') '(${storage.label})',
                        if (disc.matrixNumberSideA?.isNotEmpty == true ||
                            disc.matrixNumberSideB?.isNotEmpty == true)
                          '(${[
                            if (disc.matrixNumberSideA?.isNotEmpty == true)
                              'A: ${disc.matrixNumberSideA}',
                            if (disc.matrixNumberSideB?.isNotEmpty == true)
                              'B: ${disc.matrixNumberSideB}'
                          ].join(' | ')})'
                      ].join(' '),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700))),
              if (discDuration != null) ...[
                const SizedBox(width: 8),
                Text(discDuration,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700))
              ],
            ])),
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

class _DiscTrackGroup {
  const _DiscTrackGroup({
    required this.discNumber,
    required this.tracks,
  });

  final int discNumber;
  final List<MusicTrackListEntry> tracks;
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
    final discTracks = byDisc[disc]!;
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
