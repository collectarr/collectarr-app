import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/widgets/format_badge.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryCoverTile extends ConsumerStatefulWidget {
  const LibraryCoverTile({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onDoubleTap,
    this.onEditTap,
    this.onSecondaryTapUp,
    this.selectedColor = kAppSelection,
    this.accentColor = kAppAccent,
    this.selectionColor = kAppHighlight,
    this.mutedTextColor = kAppTextMuted,
    super.key,
  });

  final LibraryWorkspaceEntry entry;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onEditTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final Color selectedColor;
  final Color accentColor;
  final Color selectionColor;
  final Color mutedTextColor;

  @override
  ConsumerState<LibraryCoverTile> createState() => _LibraryCoverTileState();
}

class _LibraryCoverTileState extends ConsumerState<LibraryCoverTile> {
  bool _hovered = false;

  LibraryMetadataPresentation? _metadataPresentationForEntry(
    LibraryWorkspaceEntry entry,
  ) {
    final type = collectarrLibraryTypes.byKind(entry.mediaType);
    if (type == null) {
      return null;
    }
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
    if (presentation == null) {
      return null;
    }
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

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final metadataPresentation = _metadataPresentationForEntry(entry);
    final selected = widget.selected;
    final uiPrefs = ref.watch(uiPreferencesProvider);
    final palette = appPalette(context);
    final flat = uiPrefs.flatCovers;
    final showTitles = uiPrefs.showCoverTitles;
    final resolvedSelectedColor = widget.selectedColor == kAppSelection
      ? palette.selection
      : widget.selectedColor;
    final resolvedSelectionColor =
      widget.selectionColor == kAppHighlight
          ? widget.accentColor
          : widget.selectionColor;
    final resolvedMutedTextColor =
        widget.mutedTextColor == kAppTextMuted
            ? palette.textMuted
            : widget.mutedTextColor;
    final selectedTextColor = ThemeData.estimateBrightnessForColor(
          resolvedSelectedColor,
        ) ==
        Brightness.dark
      ? Colors.white
      : Theme.of(context).colorScheme.onSurface;
    final selectedSecondaryTextColor = selectedTextColor.withValues(alpha: 0.72);
    final showSelectionToggle = selected || _hovered;
    final showEditButton = _hovered && widget.onEditTap != null;
    final scopeBadge = _scopeBadge(context, entry);
    final scoreLabel = _audienceScoreLabel(metadataPresentation);
    final comic = entry.comic;
    final auxiliaryBadges = _auxiliaryBadges(entry);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: kAppAnimFast,
        clipBehavior: Clip.antiAlias,
        padding: flat ? EdgeInsets.zero : const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected
              ? resolvedSelectedColor
              : (flat ? Colors.transparent : palette.field),
          borderRadius: flat ? BorderRadius.zero : kAppRadiusSmall,
          border: flat
              ? (selected
                  ? Border.all(color: widget.accentColor, width: 2)
                  : null)
              : Border.all(
                  color: selected ? widget.accentColor : palette.cardBorder,
                  width: selected ? 2 : 1,
                ),
          boxShadow: flat
              ? null
              : [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(
                      alpha: palette.isDark ? 0.6 : 0.18,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onSecondaryTapUp: widget.onSecondaryTapUp,
            onHover: (value) {
              if (_hovered == value) {
                return;
              }
              setState(() => _hovered = value);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SlabFrameOverlay.maybeWrap(
                        rawOrSlabbed: comic?.rawOrSlabbed,
                        gradingCompany: comic?.gradingCompany,
                        grade: entry.grade,
                        labelType: comic?.labelType,
                        child: LibraryInteractiveCover(
                          title: entry.resolvedTitle,
                          itemNumber: entry.itemNumber,
                          imageUrl: entry.displayCoverUrl,
                          ownedItemId: entry.ownedItemId,
                          accentColor: widget.accentColor,
                          enableFullscreen: false,
                          enableSecondaryControl: false,
                        ),
                      ),
                      if (auxiliaryBadges.isNotEmpty)
                        Positioned(
                          top: showEditButton ? 34 : 6,
                          right: 6,
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: auxiliaryBadges,
                          ),
                        ),
                      if (showEditButton)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _LibraryTileHoverActionButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Edit item',
                            onTap: widget.onEditTap!,
                          ),
                        ),
                      if (showSelectionToggle)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: _LibraryTileSelectionToggle(
                            selected: selected,
                            accentColor: resolvedSelectionColor,
                          ),
                        ),
                      if (scopeBadge != null)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: scopeBadge,
                        ),
                      if (scoreLabel != null)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: _LibraryTileScorePill(label: scoreLabel),
                        ),
                    ],
                  ),
                ),
                if (showTitles) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.itemNumber == null
                        ? entry.resolvedTitle
                        : '${entry.resolvedTitle} #${entry.itemNumber}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color:
                              selected ? selectedTextColor : resolvedMutedTextColor,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 11,
                          height: 1.2,
                        ),
                  ),
                  if (entry.originalTitle != null &&
                      entry.originalTitle != entry.resolvedTitle)
                    Text(
                      entry.originalTitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selected
                                ? selectedSecondaryTextColor
                                : resolvedMutedTextColor.withValues(alpha: 0.7),
                            fontSize: 9,
                            height: 1.2,
                          ),
                    ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (_primaryFormatId(entry) case final fmtId?) ...[
                        FormatBadge.fromId(fmtId, compact: true),
                        const SizedBox(width: 4),
                      ],
                      const Spacer(),
                      if (entry.releaseYear != null)
                        Text(
                          entry.releaseYear.toString(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: selected
                                    ? selectedSecondaryTextColor
                                    : resolvedMutedTextColor.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _primaryFormatId(LibraryWorkspaceEntry entry) {
    for (final edition in entry.editions) {
      if (edition.physicalFormat != null) return edition.physicalFormat;
    }
    return null;
  }

  List<Widget> _auxiliaryBadges(LibraryWorkspaceEntry entry) {
    final comic = entry.comic;
    return [
      if (entry.hasMissingCover)
        const LibraryCoverBadge(
          icon: Icons.image_not_supported_outlined,
          label: 'Missing cover',
        ),
      if (entry.hasMissingMetadata)
        const LibraryCoverBadge(
          icon: Icons.manage_search,
          label: 'Missing metadata',
        ),
      if (libraryKeyMarkerLabel(comic?.keyComic ?? false, comic?.keyReason)
          case final label?)
        LibraryCoverBadge(
          icon: Icons.label_important,
          label: label,
        ),
      if (librarySlabMarkerLabel(comic?.rawOrSlabbed, comic?.gradingCompany)
          case final label?)
        LibraryCoverBadge(
          icon: Icons.workspace_premium,
          label: label,
        ),
      if (libraryNotesMarkerLabel(entry.notes) case final label?)
        LibraryCoverBadge(
          icon: Icons.sticky_note_2_outlined,
          label: label,
        ),
    ];
  }

  Widget? _scopeBadge(BuildContext context, LibraryWorkspaceEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = entry.collectionStatus?.trim().toLowerCase();
    if (status == 'sold') {
      return _LibraryTileScopePill(
        icon: Icons.sell,
        label: 'Sold',
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
      );
    }
    if (status == 'for_sale') {
      return _LibraryTileScopePill(
        icon: Icons.sell_outlined,
        label: 'For sale',
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      );
    }
    if (status == 'on_order') {
      return _LibraryTileScopePill(
        icon: Icons.local_shipping_outlined,
        label: 'On order',
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      );
    }
    if (entry.isOwned) {
      return _LibraryTileScopePill(
        icon: Icons.inventory_2_outlined,
        label: 'In collection',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      );
    }
    if (entry.isWishlisted) {
      return _LibraryTileScopePill(
        icon: Icons.star,
        label: 'Wishlist',
        backgroundColor: colorScheme.tertiaryContainer,
        foregroundColor: colorScheme.onTertiaryContainer,
      );
    }
    if (entry.isTracked) {
      return _LibraryTileScopePill(
        icon: Icons.equalizer,
        label: 'Tracked',
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
      );
    }
    return _LibraryTileScopePill(
      icon: Icons.add_box_outlined,
      label: 'Catalog only',
      backgroundColor: colorScheme.surfaceContainerHighest,
      foregroundColor: colorScheme.onSurfaceVariant,
    );
  }

  String? _audienceScoreLabel(LibraryMetadataPresentation? presentation) {
    final raw = _metadataFactValue(presentation, 'Audience Rating');
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(raw);
    return match?.group(1) ?? raw;
  }
}

class _LibraryTileSelectionToggle extends StatelessWidget {
  const _LibraryTileSelectionToggle({
    required this.selected,
    required this.accentColor,
  });

  final bool selected;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? accentColor : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected ? accentColor : Colors.black.withValues(alpha: 0.18),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          selected ? Icons.check : Icons.check_box_outline_blank,
          size: 14,
          color: selected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}

class _LibraryTileHoverActionButton extends StatelessWidget {
  const _LibraryTileHoverActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.94),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 14, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class _LibraryTileScopePill extends StatelessWidget {
  const _LibraryTileScopePill({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Icon(icon, size: 14, color: foregroundColor),
        ),
      ),
    );
  }
}

class _LibraryTileScorePill extends StatelessWidget {
  const _LibraryTileScorePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF2C335),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }
}
