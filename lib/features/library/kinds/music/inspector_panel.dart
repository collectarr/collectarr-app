import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_search_target.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_chrome.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final entry = request.inspector.entry;
    final ownedItem = request.inspector.ownedItem;
    final palette = appPalette(context);
    final accent = request.inspector.accent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(
          left: BorderSide(
            color: accent.withValues(alpha: palette.isDark ? 0.3 : 0.22),
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
              child: InspectorBackdrop(entry: entry, ownedItem: ownedItem)),
          ListView(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            children: [
              InspectorUnifiedToolbar(
                entry: entry,
                onEdit: request.onEdit,
                onShare: request.onShare,
                onDuplicate: request.onDuplicate,
                onToggleOwned: request.onToggleOwned,
                onLoan: request.onLoan,
                onRefreshMetadata: request.onRefreshMetadata,
                onUnlinkFromCore: request.onUnlinkFromCore,
                onDetailsLayoutChanged: request.onDetailsLayoutChanged,
              ),
              const SizedBox(height: 8),
              _MusicInspectorHeader(inspector: request.inspector),
              const SizedBox(height: 10),
              _MusicInspectorMain(inspector: request.inspector),
              const SizedBox(height: 10),
              _MusicInspectorTracks(inspector: request.inspector),
              const SizedBox(height: 10),
              _MusicInspectorDetailsPersonal(inspector: request.inspector),
              if (request.trailingSections.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...request.trailingSections,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MusicInspectorHeader extends StatelessWidget {
  const _MusicInspectorHeader({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final entry = inspector.entry;
    final artist = entry.series?.seriesTitle?.trim();
    final palette = appPalette(context);
    final statusIcon =
        entry.isOwned ? Icons.inventory_2_outlined : Icons.star_border;
    final statusLabel = entry.isOwned
        ? 'In collection'
        : entry.isWishlisted
            ? 'Wishlist'
            : 'Catalog';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (artist != null && artist.isNotEmpty)
              Text(
                artist,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: inspector.accent,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.resolvedTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.panel,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: palette.divider),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: inspector.accent),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
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
    );
  }
}

class _MusicInspectorMain extends StatelessWidget {
  const _MusicInspectorMain({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final entry = inspector.entry;
    final music = entry.music;
    final palette = appPalette(context);
    final discGroups =
        _groupTracksByDisc(music?.tracks ?? const <CatalogTrack>[]);
    final discCount = discGroups.length;
    final totalTracks = music?.trackCount ?? (music?.tracks.length ?? 0);
    final totalDuration =
        _formatTotalDuration(music?.tracks ?? const <CatalogTrack>[]);
    final releaseYear = entry.releaseYear?.toString();
    final genreText = entry.genres == null || entry.genres!.isEmpty
        ? null
        : entry.genres!.join(' | ');
    final formatLabel = entry.referenceFormatLabel ?? entry.variant ?? '-';

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
                  title: entry.resolvedTitle,
                  itemNumber: entry.itemNumber,
                  imageUrl: entry.displayCoverUrl,
                  accentColor: inspector.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.publisher?.isNotEmpty == true ||
                      releaseYear != null)
                    Text(
                      [
                        if (entry.publisher?.isNotEmpty == true)
                          entry.publisher!,
                        if (releaseYear != null) '($releaseYear)',
                      ].join(' '),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  if (genreText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      genreText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (entry.barcode?.isNotEmpty == true)
                    _MusicInspectorInfoLine(
                      icon: Icons.qr_code_2,
                      text: entry.barcode!,
                    ),
                  _MusicInspectorInfoLine(
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
                  if (music?.catalogNumber?.isNotEmpty == true)
                    _MusicInspectorInfoLine(
                      icon: Icons.confirmation_number_outlined,
                      text: 'Cat No ${music!.catalogNumber!}',
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
                          coverUrl: entry.displayCoverUrl,
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
                  if (_ebayUri(entry) case final uri?) ...[
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
    final tracks = inspector.entry.music?.tracks ?? const <CatalogTrack>[];
    final groups = _groupTracksByDisc(tracks);
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }
    final rawQuery = inspector.searchQuery?.trim().toLowerCase();
    final highlightTerms = inspector.searchTarget.includesTracks
        ? _musicSearchTerms(rawQuery)
        : const <String>[];

    return LibraryInspectorSection(
      title: 'Tracks',
      accentColor: inspector.accent,
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          _MusicDiscTable(
            discNumber: groups[index].discNumber,
            tracks: groups[index].tracks,
            highlightTerms: highlightTerms,
          ),
          if (index < groups.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MusicInspectorDetailsPersonal extends StatelessWidget {
  const _MusicInspectorDetailsPersonal({required this.inspector});

  final LibraryInspectorRequest inspector;

  @override
  Widget build(BuildContext context) {
    final entry = inspector.entry;
    final owned = inspector.ownedItem;
    final music = entry.music;
    final detailRows = <(String, String)>[
      if (entry.publisher?.trim().isNotEmpty == true)
        ('Label', entry.publisher!),
      if (entry.releaseDate != null || entry.releaseYear != null)
        (
          'Release',
          formatNullableDate(entry.releaseDate) ??
              entry.releaseYear!.toString(),
        ),
      if (music?.originalReleaseDate != null)
        ('Original release', formatDate(music!.originalReleaseDate!)),
      if (music?.recordingDate != null)
        ('Recording date', formatDate(music!.recordingDate!)),
      if (entry.country?.trim().isNotEmpty == true) ('Country', entry.country!),
      if (entry.language?.trim().isNotEmpty == true)
        ('Language', entry.language!),
      if (entry.referenceFormatLabel?.trim().isNotEmpty == true ||
          entry.variant?.trim().isNotEmpty == true)
        ('Format', entry.referenceFormatLabel ?? entry.variant ?? '-'),
      if (music?.releaseStatus?.trim().isNotEmpty == true)
        ('Release status', music!.releaseStatus!),
      if (music?.isLive != null)
        ('Live recording', music!.isLive! ? 'Yes' : 'No'),
      if (music?.rpm?.trim().isNotEmpty == true) ('RPM', music!.rpm!),
      if (music?.spars?.trim().isNotEmpty == true) ('SPARS', music!.spars!),
      if (music?.soundType?.trim().isNotEmpty == true)
        ('Sound', music!.soundType!),
      if (music?.vinylColor?.trim().isNotEmpty == true)
        ('Vinyl color', music!.vinylColor!),
      if (music?.vinylWeight?.trim().isNotEmpty == true)
        ('Vinyl weight', music!.vinylWeight!),
      if (music?.mediaCondition?.trim().isNotEmpty == true)
        ('Media condition', music!.mediaCondition!),
      if (owned?.packaging?.trim().isNotEmpty == true)
        ('Packaging', owned!.packaging!),
      if (owned?.boxSetName?.trim().isNotEmpty == true)
        ('Box set', owned!.boxSetName!),
      if (owned?.features?.trim().isNotEmpty == true)
        ('Extras', owned!.features!),
      if (music?.studio?.trim().isNotEmpty == true) ('Studio', music!.studio!),
      if (music?.catalogNumber?.trim().isNotEmpty == true)
        ('Catalog number', music!.catalogNumber!),
      if (entry.barcode?.trim().isNotEmpty == true) ('Barcode', entry.barcode!),
      if (entry.genres?.isNotEmpty == true)
        ('Genres', entry.genres!.join(', ')),
      if (entry.tags?.trim().isNotEmpty == true) ('Tags', entry.tags!),
    ];
    final personalRows = <(String, String)>[
      ('Index', owned?.indexNumber?.toString() ?? '-'),
      if (owned?.condition?.trim().isNotEmpty == true)
        ('Condition', owned!.condition!),
      if (entry.locationPath?.trim().isNotEmpty == true)
        ('Location', entry.locationPath!),
      if (owned?.collectionStatus?.trim().isNotEmpty == true)
        ('Collection status', owned!.collectionStatus!),
      if (owned?.storageDevice?.trim().isNotEmpty == true)
        ('Storage device', owned!.storageDevice!),
      if (owned?.storageSlot?.trim().isNotEmpty == true)
        ('Storage slot', owned!.storageSlot!),
      if (owned?.pricePaidCents != null)
        ('Price paid', formatMoney(owned!.pricePaidCents, owned.currency)),
      if (owned?.sellPriceCents != null)
        ('Current value', formatMoney(owned!.sellPriceCents, owned.currency)),
      if (owned?.purchaseDate != null)
        ('Purchase date', formatDate(owned!.purchaseDate!)),
      if (owned?.purchaseStore?.trim().isNotEmpty == true)
        ('Purchase store', owned!.purchaseStore!),
      if (owned?.createdAt != null) ('Added', formatDate(owned!.createdAt!)),
      ('Modified', formatNullableDate(owned?.updatedAt) ?? '-'),
    ];
    final creditRows = _buildCreditsRows(entry.creators);
    List<LibraryInspectorFactData> asFacts(List<(String, String)> rows) {
      return [
        for (final row in rows) LibraryInspectorFactData(row.$1, row.$2),
      ];
    }

    return Column(
      children: [
        LibraryInspectorSection(
          title: 'Info',
          accentColor: inspector.accent,
          children: [
            LibraryInspectorFactGrid(facts: asFacts(detailRows)),
          ],
        ),
        LibraryInspectorSection(
          title: 'Personal',
          accentColor: inspector.accent,
          children: [
            LibraryInspectorFactGrid(facts: asFacts(personalRows)),
          ],
        ),
        LibraryInspectorSection(
          title: 'Credits',
          accentColor: inspector.accent,
          children: [
            if (creditRows.isEmpty)
              Text(
                '-',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appPalette(context).textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              )
            else
              LibraryInspectorFactGrid(facts: asFacts(creditRows)),
          ],
        ),
      ],
    );
  }
}

class _MusicDiscTable extends StatelessWidget {
  const _MusicDiscTable({
    required this.discNumber,
    required this.tracks,
    this.highlightTerms = const <String>[],
  });

  final int discNumber;
  final List<CatalogTrack> tracks;
  final List<String> highlightTerms;

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
  });

  final CatalogTrack track;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final highlightColor = Color.alphaBlend(
      const Color(0xFFE8CF74).withValues(alpha: palette.isDark ? 0.84 : 0.5),
      palette.surface,
    );
    return DecoratedBox(
      key: ValueKey(
          'music-track-row-${track.discNumber ?? 1}-${track.position ?? 0}-${track.title}'),
      decoration: BoxDecoration(
        color: highlight ? highlightColor : Colors.transparent,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Text(
                (track.position ?? '-').toString(),
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
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (track.artist?.trim().isNotEmpty == true)
                    Text(
                      track.artist!.trim(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
            ),
            if (track.durationSeconds != null)
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

class _MusicInspectorInfoLine extends StatelessWidget {
  const _MusicInspectorInfoLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: palette.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
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
              'Disc $discNumber',
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
  final List<CatalogTrack> tracks;
}

List<_DiscTrackGroup> _groupTracksByDisc(List<CatalogTrack> tracks) {
  if (tracks.isEmpty) {
    return const <_DiscTrackGroup>[];
  }
  final byDisc = <int, List<CatalogTrack>>{};
  for (final track in tracks) {
    final disc = track.discNumber ?? 1;
    final grouped = byDisc.putIfAbsent(disc, () => <CatalogTrack>[]);
    grouped.add(track);
  }
  final groups = <_DiscTrackGroup>[];
  final sortedDiscs = byDisc.keys.toList(growable: false)..sort();
  for (final disc in sortedDiscs) {
    final discTracks = byDisc[disc]!
      ..sort(
        (a, b) => (a.position ?? 0).compareTo(b.position ?? 0),
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

String? _formatTotalDuration(List<CatalogTrack> tracks) {
  var total = 0;
  for (final track in tracks) {
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

bool _matchesTrackTerms(CatalogTrack track, List<String> terms) {
  if (terms.isEmpty) {
    return false;
  }
  final searchable = <String>[
    track.title,
    if (track.artist?.trim().isNotEmpty == true) track.artist!.trim(),
    if (track.position != null) track.position!.toString(),
  ].join(' ').toLowerCase();
  return terms.every(searchable.contains);
}

List<(String, String)> _buildCreditsRows(List<Map<String, dynamic>>? creators) {
  return libraryCreatorsGroupedByRole(creators);
}

Uri? _ebayUri(LibraryWorkspaceEntry entry) {
  final barcode = entry.barcode?.trim();
  if (barcode == null || barcode.isEmpty) {
    return null;
  }
  final query = <String>[
    barcode,
    if (entry.series?.seriesTitle?.trim().isNotEmpty == true)
      entry.series!.seriesTitle!.trim(),
    entry.resolvedTitle,
    if (entry.releaseYear != null) entry.releaseYear.toString(),
  ].join(' ');
  return buildEbaySearchUri(
    query: query,
    categoryPath: '/sch/11233/i.html',
    soldOnly: true,
  );
}
