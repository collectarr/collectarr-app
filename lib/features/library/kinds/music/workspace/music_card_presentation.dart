import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_browser_scope.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a music workspace entry.
///
/// [musicVertical] selects between the album-grid layout (true) and the
/// horizontal tracklist-style layout (false).
LibraryCardPresentation buildMusicCardPresentation(
  LibraryWorkspaceEntry entry, {
  required bool musicVertical,
}) {
  return LibraryCardPresentation(
    compactBadges: const [],
    customCardBuilder: (context, delegate) {
      if (musicVertical) {
        return _buildMusicVerticalCard(
          context: context,
          delegate: delegate,
        );
      }
      return _buildMusicHorizontalCard(
        context: context,
        delegate: delegate,
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Music horizontal card (tracklist / album list layout).
// ---------------------------------------------------------------------------

Widget _buildMusicHorizontalCard({
  required BuildContext context,
  required LibraryWorkspaceCardDelegate delegate,
}) {
  final entry = delegate.entry;
  final palette = appPalette(context);
  final background = delegate.selected
      ? libraryWorkspaceSelectionBackground(
          context,
          accentColor: delegate.accentColor,
          baseColor: palette.cardBackground,
        )
      : palette.cardBackground;
  final titleColor = delegate.selected ? delegate.selectedTitleColor : palette.textPrimary;
  final subtitleColor =
      delegate.selected ? delegate.selectedTitleColor.withValues(alpha: 0.9) : delegate.mutedColor;
  final supportColor = delegate.selected
      ? delegate.selectedTitleColor.withValues(alpha: 0.82)
      : palette.textSecondary;
  final artist = musicCardArtist(entry);
  final year = entry.releaseYear?.toString() ?? '';
  final format = entry.referenceFormatLabel?.trim();
  final tracks = musicCardTrackCount(entry);
  final duration = musicCardDuration(entry);
  final metaLine = [
    if (format != null && format.isNotEmpty) format,
    if (year.isNotEmpty) year,
  ].join(' – ');

  return RepaintBoundary(
    child: AnimatedContainer(
      duration: kAppAnimFast,
      decoration: BoxDecoration(
        color: background,
        borderRadius: kAppRadiusSmall,
        border: Border.all(
          color: delegate.selected ? delegate.accentColor : palette.cardBorder,
          width: delegate.selected ? 2 : 1,
        ),
        boxShadow: delegate.selected
            ? [
                BoxShadow(
                  color: delegate.accentColor.withValues(alpha: 0.24),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: delegate.onTap,
          onDoubleTap: delegate.onDoubleTap,
          onSecondaryTapUp: delegate.onSecondaryTapUp,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: delegate.coverWidth,
                      child: LibraryInteractiveCover(
                        title: entry.resolvedTitle,
                        itemNumber: entry.itemNumber,
                        imageUrl: entry.displayCoverUrl,
                        targetCacheWidth: delegate.coverCacheWidth,
                        ownedItemId: entry.ownedItemId,
                        accentColor: delegate.accentColor,
                        fit: BoxFit.cover,
                        borderRadius: 2,
                        enableFullscreen: false,
                        enableSecondaryControl: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.resolvedTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: titleColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          if (artist != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                          const Spacer(),
                          if (metaLine.isNotEmpty)
                            Text(
                              metaLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          if (delegate.customFieldBadges.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final badge in delegate.customFieldBadges)
                                  _MusicCompactMetaPill(
                                    icon: Icons.tune,
                                    label: badge,
                                    accentColor: delegate.accentColor,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (tracks != null || duration != null) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (tracks != null)
                            Text(
                              '\u266b$tracks',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: supportColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          if (duration != null)
                            Text(
                              duration,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: supportColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (delegate.selectionMode || delegate.selected)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: LibraryTileSelectionToggleButton(
                    onTap: delegate.onSelectionToggleTap,
                    child: LibraryTileSelectionToggle(
                      selected: delegate.selected,
                      accentColor: delegate.accentColor,
                      coverSize: delegate.coverWidth,
                    ),
                  ),
                ),
              if (delegate.onEditTap != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: LibraryTileHoverActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit item',
                    onTap: delegate.onEditTap!,
                  ),
                ),
              Positioned(
                right: 6,
                bottom: 6,
                child: _musicScopeBadge(context, entry, delegate.accentColor),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Music vertical card (album grid layout).
// ---------------------------------------------------------------------------

Widget _buildMusicVerticalCard({
  required BuildContext context,
  required LibraryWorkspaceCardDelegate delegate,
}) {
  final entry = delegate.entry;
  final palette = appPalette(context);
  final background = delegate.selected
      ? libraryWorkspaceSelectionBackground(
          context,
          accentColor: delegate.accentColor,
          baseColor: palette.cardBackground,
        )
      : palette.cardBackground;
  final titleColor = delegate.selected ? delegate.selectedTitleColor : palette.textPrimary;
  final subtitleColor =
      delegate.selected ? delegate.selectedTitleColor.withValues(alpha: 0.9) : delegate.mutedColor;
  final artist = musicCardArtist(entry);
  final year = entry.releaseYear?.toString() ?? '';
  return RepaintBoundary(
    child: AnimatedContainer(
      duration: kAppAnimFast,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: kAppRadiusSmall,
        border: Border.all(
          color: delegate.selected ? delegate.accentColor : palette.cardBorder,
          width: delegate.selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: delegate.onTap,
          onDoubleTap: delegate.onDoubleTap,
          onSecondaryTapUp: delegate.onSecondaryTapUp,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LibraryInteractiveCover(
                        title: entry.resolvedTitle,
                        itemNumber: entry.itemNumber,
                        imageUrl: entry.displayCoverUrl,
                        ownedItemId: entry.ownedItemId,
                        targetCacheWidth: delegate.coverCacheWidth,
                        accentColor: delegate.accentColor,
                        fit: BoxFit.cover,
                        borderRadius: 0,
                        enableFullscreen: false,
                        enableSecondaryControl: false,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        entry.resolvedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    if (artist != null || year.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          [
                            if (artist != null) artist,
                            if (year.isNotEmpty) year,
                          ].join(' – '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: subtitleColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              if (delegate.selectionMode || delegate.selected)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: LibraryTileSelectionToggleButton(
                    onTap: delegate.onSelectionToggleTap,
                    child: LibraryTileSelectionToggle(
                      selected: delegate.selected,
                      accentColor: delegate.accentColor,
                      coverSize: delegate.coverWidth,
                    ),
                  ),
                ),
              if (delegate.onEditTap != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: LibraryTileHoverActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit item',
                    onTap: delegate.onEditTap!,
                  ),
                ),
              Positioned(
                right: 6,
                bottom: 6,
                child: _musicScopeBadge(context, entry, delegate.accentColor),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _musicScopeBadge(
  BuildContext context,
  LibraryWorkspaceEntry entry,
  Color accentColor,
) {
  final palette = appPalette(context);
  final scope = resolveLibraryCollectionStatusScope(entry);
  return LibraryTileScopePill(
    icon: scope.icon,
    label: scope.label,
    color: libraryCollectionStatusScopeColor(
      scope,
      accentColor,
      palette.textMuted,
    ),
  );
}

class _MusicCompactMetaPill extends StatelessWidget {
  const _MusicCompactMetaPill({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.tableBottomBorder,
        borderRadius: kAppRadiusSmall,
        border: Border.all(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: accentColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers used by the generic card for the music layouts.
// Kept here so the generic card does not need to know about music domain.
// ---------------------------------------------------------------------------

/// Returns the primary artist name for a music entry.
String? musicCardArtist(LibraryWorkspaceEntry entry) {
  final creators = entry.creators ?? const <Map<String, dynamic>>[];
  String? fallbackName;
  for (final creator in creators) {
    final rawName =
        (creator['name'] ?? creator['display_name'] ?? '').toString().trim();
    if (rawName.isEmpty) continue;
    fallbackName ??= rawName;
    final role =
        (creator['role'] ?? creator['type'] ?? '').toString().toLowerCase();
    if (role.contains('artist') ||
        role.contains('performer') ||
        role.contains('musician') ||
        role.contains('band')) {
      return rawName;
    }
  }
  final publisher = entry.publisher?.trim();
  if (publisher != null && publisher.isNotEmpty) {
    return publisher;
  }
  return fallbackName;
}

/// Returns a formatted duration string for the album.
String? musicCardDuration(LibraryWorkspaceEntry entry) {
  final runtimeFact = _metadataFactValue(
    _metadataPresentationForEntry(entry),
    'Runtime',
  );
  if (runtimeFact != null && runtimeFact.isNotEmpty) {
    return runtimeFact;
  }
  final totalSeconds = entry.music?.tracks.fold<int>(
    0,
    (sum, track) => sum + (track.durationSeconds ?? 0),
  );
  if (totalSeconds == null || totalSeconds <= 0) {
    return null;
  }
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Returns the track count for the album.
int? musicCardTrackCount(LibraryWorkspaceEntry entry) {
  return entry.music?.trackCount ??
      int.tryParse(
        _metadataFactValue(
              _metadataPresentationForEntry(entry),
              'Tracks',
            ) ??
            '',
      );
}

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryWorkspaceEntry entry,
) {
  final type = collectarrLibraryTypes.byKind(entry.mediaType);
  if (type == null) return null;
  return type.presentation.builder.buildMetadataPresentation(
    singularLabel: type.singularLabel,
    mediaFields: type.mediaFields,
    releaseFields: type.releaseFields,
    entry: entry,
    includeIdentityFacts: true,
    tapFor: (_) => null,
  );
}

String? _metadataFactValue(
  LibraryMetadataPresentation? presentation,
  String label,
) {
  if (presentation == null) return null;
  for (final fact in presentation.allFacts) {
    if (fact.label == label) {
      final value = fact.value.trim();
      if (value.isNotEmpty && value != '-') {
        return value;
      }
    }
  }
  return null;
}
