import 'dart:math' as math;

import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_tokens.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_card_presentation.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_tile.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_compact_meta_pill.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_group.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release_relations.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/music/workspace/music_workspace_dto.dart';
import 'package:collectarr_app/features/library/generic/toolbar/toolbar_auxiliary_controls.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Builds the [LibraryCardPresentation] for a music workspace entry.
///
/// [coverFocused] selects between the album-grid layout (true) and the
/// horizontal tracklist-style layout (false).
LibraryCardPresentation buildMusicCardPresentation(
  LibraryProjectionView item, {
  required bool coverFocused,
}) {
  final musicDto = item.dto is MusicWorkspaceProjection
      ? item.dto as MusicWorkspaceProjection
      : null;
  return LibraryCardPresentation(
    itemNumber: null,
    variant: musicDto?.format,
    releaseDate: musicDto?.releaseDate,
    format: musicDto?.format,
    seriesTitle: musicDto?.artist,
    identifierCode: musicDto?.identifierCode,
    currency: musicDto?.currency,
    contextFacts: [
      musicDto?.publisher,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList(),
    compactBadges: const [],
    customCardBuilder: (context, delegate) {
      if (coverFocused) {
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
  final item = delegate.item;
  final dto = item.dto;
  final palette = appPalette(context);
  final background = delegate.selected
      ? libraryWorkspaceSelectionBackground(
          context,
          accentColor: delegate.accentColor,
          baseColor: palette.cardBackground,
        )
      : palette.cardBackground;
  final titleColor = kLibraryCardTitleColor;
  final subtitleColor = delegate.selected
      ? delegate.selectedTitleColor.withValues(alpha: 0.9)
      : delegate.mutedColor;
  final supportColor = delegate.selected
      ? delegate.selectedTitleColor.withValues(alpha: 0.82)
      : palette.textSecondary;
  final artist = musicCardArtist(item);
  final musicDto = dto is MusicWorkspaceProjection ? dto : null;
  final year = musicDto?.releaseDate?.year.toString() ?? '';
  final format = musicDto?.referenceFormatLabel?.trim();
  final label = musicDto?.publisher?.trim();
  final tracks = musicCardTrackCount(item);
  final duration = musicCardDuration(item);
  final metaLine = [
    if (format != null && format.isNotEmpty) format,
    if (label != null && label.isNotEmpty) label,
    if (year.isNotEmpty) year,
  ].join(' \u2013 ');

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
          mouseCursor: WidgetStateMouseCursor.clickable,
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final side = math.min(
                            delegate.coverWidth,
                            constraints.maxHeight,
                          );
                          return Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox.square(
                              dimension: side,
                              child: LibraryInteractiveCover(
                                title: dto.primaryLabel,
                                itemNumber: null,
                                imageUrl: dto.imageUrl,
                                targetCacheWidth: delegate.coverCacheWidth,
                                ownedRef: item.source.ownedRef,
                                accentColor: delegate.accentColor,
                                fit: BoxFit.cover,
                                borderRadius: 2,
                                enableFullscreen: false,
                                enableSecondaryControl: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dto.primaryLabel,
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
                                  LibraryCompactMetaPill(
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
                child: _musicScopeBadge(context, item, delegate.accentColor),
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
  final item = delegate.item;
  final dto = item.dto;
  final palette = appPalette(context);
  final background = delegate.selected
      ? libraryWorkspaceSelectionBackground(
          context,
          accentColor: delegate.accentColor,
          baseColor: palette.cardBackground,
        )
      : palette.cardBackground;
  final titleColor = kLibraryCardTitleColor;
  final subtitleColor = delegate.selected
      ? delegate.selectedTitleColor.withValues(alpha: 0.9)
      : delegate.mutedColor;
  final artist = musicCardArtist(item);
  final musicDto = dto is MusicWorkspaceProjection ? dto : null;
  final year = musicDto?.releaseDate?.year.toString() ?? '';
  final label = musicDto?.publisher?.trim();
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
          mouseCursor: WidgetStateMouseCursor.clickable,
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final side = math.min(
                            delegate.coverWidth,
                            math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                          );
                          return Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox.square(
                              dimension: side,
                              child: LibraryInteractiveCover(
                                title: dto.primaryLabel,
                                itemNumber: null,
                                imageUrl: dto.imageUrl,
                                ownedRef: item.source.ownedRef,
                                targetCacheWidth: delegate.coverCacheWidth,
                                accentColor: delegate.accentColor,
                                fit: BoxFit.cover,
                                borderRadius: 0,
                                enableFullscreen: false,
                                enableSecondaryControl: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        dto.primaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                            if (label != null && label.isNotEmpty) label,
                            if (year.isNotEmpty) year,
                          ].join(' \u2013 '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
                child: _musicScopeBadge(context, item, delegate.accentColor),
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
  LibraryProjectionView item,
  Color accentColor,
) {
  final palette = appPalette(context);
  final scope = resolveLibraryCollectionStatusScope(item);
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

// ---------------------------------------------------------------------------
// Shared helpers used by the generic card for the music layouts.
// Kept here so the generic card does not need to know about music domain.
// ---------------------------------------------------------------------------

/// Returns the primary artist name for a music item.
String? musicCardArtist(LibraryProjectionView item) {
  final group = _musicGroup(item);
  final groupArtist = group?.artist?.trim();
  if (groupArtist != null && groupArtist.isNotEmpty) return groupArtist;
  final creators = group?.primaryRelease?.contributions ??
      const <MusicReleaseContribution>[];
  for (final creator in creators) {
    final rawName = (creator.displayName ?? '').trim();
    if (rawName.isEmpty) continue;
    final role = creator.role.toLowerCase();
    if (role.contains('artist') ||
        role.contains('performer') ||
        role.contains('musician') ||
        role.contains('band')) {
      return rawName;
    }
  }
  return 'Unknown artist';
}

/// Returns a formatted duration string for the album.
String? musicCardDuration(LibraryProjectionView item) {
  final runtimeFact = _metadataFactValue(
    _metadataPresentationForEntry(item),
    'Runtime',
  );
  if (runtimeFact != null && runtimeFact.isNotEmpty) {
    return runtimeFact;
  }
  final totalDurationMs = _musicGroup(item)?.tracks.fold<int>(
        0,
        (total, track) => total + (track.track.durationMs ?? 0),
      );
  final totalSeconds = totalDurationMs == null || totalDurationMs == 0
      ? null
      : (totalDurationMs / 1000).round();
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
int? musicCardTrackCount(LibraryProjectionView item) {
  return _musicGroup(item)?.trackCount ??
      int.tryParse(
        _metadataFactValue(
              _metadataPresentationForEntry(item),
              'Tracks',
            ) ??
            '',
      );
}

MusicReleaseGroup? _musicGroup(LibraryProjectionView item) {
  final catalog = item.source.catalogData;
  return catalog is MusicWorkspaceCatalogData ? catalog.music : null;
}

LibraryMetadataPresentation? _metadataPresentationForEntry(
  LibraryProjectionView item,
) {
  final registration = defaultLibraryKindRegistry.tryGet(item.source.mediaKind);
  if (registration == null) return null;
  return libraryPresentationForKind(registration.kind)
      .builder
      .buildMetadataPresentation(
        singularLabel: registration.identity.singularLabel,
        item: item,
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
