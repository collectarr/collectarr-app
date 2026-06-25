import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:flutter/foundation.dart';

const _bucketManagerUnset = Object();
const _bucketManagerNoChange = Object();

class LibraryBucketManagerEntry {
  const LibraryBucketManagerEntry({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}

bool libraryGroupModeSupportsBucketManagement(
  LibraryTypeConfig type,
  LibraryGroupMode mode,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)
          ?.supportsBucketManagement ??
      false;
}

String libraryBucketManagerListLabel(
  LibraryGroupMode mode,
  LibraryTypeConfig type,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)
          ?.resolvedBucketManagerListLabel ??
      genericGroupModeSidebarTitle(mode, type);
}

CatalogItem? renameLibraryGroupBucketValue(
  CatalogItem item,
  LibraryGroupMode mode,
  String currentLabel,
  String nextLabel,
) {
  final normalizedNext = nextLabel.trim();
  if (normalizedNext.isEmpty || normalizedNext == currentLabel) {
    return null;
  }
  return _updatedCatalogItemForBucket(
    item,
    mode,
    currentLabel,
    replacement: normalizedNext,
  );
}

CatalogItem? deleteLibraryGroupBucketValue(
  CatalogItem item,
  LibraryGroupMode mode,
  String currentLabel,
) {
  return _updatedCatalogItemForBucket(item, mode, currentLabel);
}

Future<void> showLibraryBucketManagerDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryGroupMode groupMode,
  required Color accent,
  required List<LibraryBucketManagerEntry> entries,
  required Future<int> Function(String currentLabel, String nextLabel)
      onRenameBucket,
  required Future<int> Function(String currentLabel, String targetLabel)
      onMergeBucket,
  required Future<int> Function(String currentLabel) onDeleteBucket,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _LibraryBucketManagerDialog(
      type: type,
      groupMode: groupMode,
      accent: accent,
      entries: entries,
      onRenameBucket: onRenameBucket,
      onMergeBucket: onMergeBucket,
      onDeleteBucket: onDeleteBucket,
    ),
  );
}

class _LibraryBucketManagerDialog extends StatefulWidget {
  const _LibraryBucketManagerDialog({
    required this.type,
    required this.groupMode,
    required this.accent,
    required this.entries,
    required this.onRenameBucket,
    required this.onMergeBucket,
    required this.onDeleteBucket,
  });

  final LibraryTypeConfig type;
  final LibraryGroupMode groupMode;
  final Color accent;
  final List<LibraryBucketManagerEntry> entries;
  final Future<int> Function(String currentLabel, String nextLabel)
      onRenameBucket;
  final Future<int> Function(String currentLabel, String targetLabel)
      onMergeBucket;
  final Future<int> Function(String currentLabel) onDeleteBucket;

  @override
  State<_LibraryBucketManagerDialog> createState() =>
      _LibraryBucketManagerDialogState();
}

class _LibraryBucketManagerDialogState
    extends State<_LibraryBucketManagerDialog> {
  final _searchController = TextEditingController();
  bool _submitting = false;
  List<LibraryBucketManagerEntry> _sortedEntries = [];

  @override
  void initState() {
    super.initState();
    _sortedEntries = List.from(widget.entries)
      ..sort((left, right) => left.label.toLowerCase().compareTo(
            right.label.toLowerCase(),
          ));
  }

  @override
  void didUpdateWidget(covariant _LibraryBucketManagerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.entries, oldWidget.entries)) {
      _sortedEntries = List.from(widget.entries)
        ..sort((left, right) => left.label.toLowerCase().compareTo(
              right.label.toLowerCase(),
            ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final filteredEntries = _filteredEntries();
    final title =
        'Manage ${genericGroupModeSidebarTitle(widget.groupMode, widget.type)}';
    final listLabel = libraryBucketManagerListLabel(
      widget.groupMode,
      widget.type,
    );
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccentDialogHeader(
              title: title,
              accent: widget.accent,
              onClose: _submitting ? null : () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: palette.highlight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.entries.length} ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toUpperCase()}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.divider),
                      borderRadius: BorderRadius.circular(10),
                      color: palette.panelRaised,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          listLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_drop_down,
                          color: palette.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                color: palette.panel,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        'Name',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        'Count',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(width: 72),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: filteredEntries.isEmpty
                    ? Center(
                        child: Text(
                          'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} found.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: palette.textMuted,
                                  ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          final rowColor = index.isEven
                              ? Colors.transparent
                              : palette.panel.withValues(alpha: 0.35);
                          return ColoredBox(
                            color: rowColor,
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Rename ${entry.label}',
                                  onPressed: _submitting
                                      ? null
                                      : () => _renameEntry(entry),
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 18),
                                ),
                                IconButton(
                                  tooltip: 'Merge ${entry.label}',
                                  onPressed:
                                      _submitting || widget.entries.length < 2
                                          ? null
                                          : () => _mergeEntry(entry),
                                  icon: const Icon(Icons.merge_type_outlined,
                                      size: 18),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      entry.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    '${entry.count}',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Delete ${entry.label}',
                                  onPressed: _submitting
                                      ? null
                                      : () => _deleteEntry(entry),
                                  icon: const Icon(Icons.close, size: 18),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitting ? null : () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LibraryBucketManagerEntry> _filteredEntries() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = [
      for (final entry in _sortedEntries)
        if (query.isEmpty || entry.label.toLowerCase().contains(query)) entry,
    ];
    return filtered;
  }

  Future<void> _renameEntry(LibraryBucketManagerEntry entry) async {
    final controller = TextEditingController(text: entry.label);
    final nextLabel = await showDialog<String>(
      context: context,
      builder: (context) => AccentAlertDialog(
        title: Text(
            'Rename ${genericGroupModeLabel(widget.groupMode, widget.type)}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New label',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          DialogActionButtons.cancel(
            onPressed: () => Navigator.of(context).pop(),
          ),
          DialogActionButtons.save(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || nextLabel == null || nextLabel.trim().isEmpty) {
      return;
    }
    setState(() => _submitting = true);
    final affected = await widget.onRenameBucket(entry.label, nextLabel.trim());
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          affected == 0
              ? 'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} were changed.'
              : 'Renamed ${entry.label} across $affected item${affected == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  Future<void> _deleteEntry(LibraryBucketManagerEntry entry) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
            title: Text('Delete ${entry.label}?'),
            content: Text(
              'Remove this ${genericGroupModeLabel(widget.groupMode, widget.type).toLowerCase()} value from all items currently bucketed under it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    setState(() => _submitting = true);
    final affected = await widget.onDeleteBucket(entry.label);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          affected == 0
              ? 'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} were changed.'
              : 'Deleted ${entry.label} from $affected item${affected == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  Future<void> _mergeEntry(LibraryBucketManagerEntry entry) async {
    final candidates = [
      for (final candidate in widget.entries)
        if (candidate.label != entry.label) candidate,
    ]..sort(
        (left, right) => left.label.toLowerCase().compareTo(
              right.label.toLowerCase(),
            ),
      );
    if (candidates.isEmpty) {
      return;
    }
    var targetLabel = candidates.first.label;
    final confirmedTarget = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AccentAlertDialog(
          title: Text('Merge ${entry.label} into...'),
          content: DropdownButtonFormField<String>(
            initialValue: targetLabel,
            decoration: const InputDecoration(
              labelText: 'Target bucket',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final candidate in candidates)
                DropdownMenuItem<String>(
                  value: candidate.label,
                  child: Text(candidate.label),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => targetLabel = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(targetLabel),
              child: const Text('Merge'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || confirmedTarget == null || confirmedTarget == entry.label) {
      return;
    }
    setState(() => _submitting = true);
    final affected = await widget.onMergeBucket(entry.label, confirmedTarget);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          affected == 0
              ? 'No ${genericGroupModeSidebarTitle(widget.groupMode, widget.type).toLowerCase()} were changed.'
              : 'Merged ${entry.label} into $confirmedTarget across $affected item${affected == 1 ? '' : 's'}.',
        ),
      ),
    );
  }
}

CatalogItem? _updatedCatalogItemForBucket(
  CatalogItem item,
  LibraryGroupMode mode,
  String currentLabel, {
  String? replacement,
}) {
  switch (mode) {
    case LibraryGroupMode.genre:
      final genres = _updatedStringList(item.genres, currentLabel, replacement);
      return identical(genres, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, genres: genres);
    case LibraryGroupMode.character:
      final characters =
          _updatedStringList(item.characters, currentLabel, replacement);
      return identical(characters, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, characters: characters);
    case LibraryGroupMode.storyArc:
      final storyArcs =
          _updatedStringList(item.storyArcs, currentLabel, replacement);
      return identical(storyArcs, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, storyArcs: storyArcs);
    case LibraryGroupMode.creator:
    case LibraryGroupMode.actor:
    case LibraryGroupMode.director:
    case LibraryGroupMode.musician:
    case LibraryGroupMode.photography:
    case LibraryGroupMode.producer:
    case LibraryGroupMode.writer:
    case LibraryGroupMode.artist:
    case LibraryGroupMode.penciller:
    case LibraryGroupMode.inker:
    case LibraryGroupMode.colorist:
    case LibraryGroupMode.painter:
    case LibraryGroupMode.letterer:
    case LibraryGroupMode.separator:
    case LibraryGroupMode.layouts:
    case LibraryGroupMode.translator:
    case LibraryGroupMode.plotter:
    case LibraryGroupMode.scripter:
    case LibraryGroupMode.coverArtist:
    case LibraryGroupMode.coverPenciller:
    case LibraryGroupMode.coverPainter:
    case LibraryGroupMode.coverInker:
    case LibraryGroupMode.coverColorist:
    case LibraryGroupMode.coverSeparator:
    case LibraryGroupMode.editor:
    case LibraryGroupMode.editorInChief:
      final creators =
          _updatedCreators(item.creators, mode, currentLabel, replacement);
      return identical(creators, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, creators: creators);
    case LibraryGroupMode.publisher:
      final publisher =
          _updatedStringValue(item.publisher, currentLabel, replacement);
      return identical(publisher, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, publisher: publisher);
    case LibraryGroupMode.country:
      final country =
          _updatedStringValue(item.country, currentLabel, replacement);
      return identical(country, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, country: country);
    case LibraryGroupMode.language:
      final language =
          _updatedStringValue(item.language, currentLabel, replacement);
      return identical(language, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, language: language);
    case LibraryGroupMode.ageRating:
      final ageRating =
          _updatedStringValue(item.ageRating, currentLabel, replacement);
      return identical(ageRating, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, ageRating: ageRating);
    case LibraryGroupMode.crossover:
      final crossover =
          _updatedStringValue(item.crossover, currentLabel, replacement);
      return identical(crossover, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, crossover: crossover);
    case LibraryGroupMode.imprint:
      final imprint = _updatedStringValue(
        item.publishing?.imprint,
        currentLabel,
        replacement,
      );
      return identical(imprint, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, imprint: imprint);
    case LibraryGroupMode.seriesGroup:
      final seriesGroup = _updatedStringValue(
        item.publishing?.seriesGroup,
        currentLabel,
        replacement,
      );
      return identical(seriesGroup, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, seriesGroup: seriesGroup);
    case LibraryGroupMode.audienceRating:
      final audienceRating = _updatedStringValue(
        item.audienceRating,
        currentLabel,
        replacement,
      );
      return identical(audienceRating, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, audienceRating: audienceRating);
    default:
      return null;
  }
}

CatalogItem? _rebuildCatalogItem(
  CatalogItem item, {
  Object? creators = _bucketManagerUnset,
  Object? characters = _bucketManagerUnset,
  Object? storyArcs = _bucketManagerUnset,
  Object? genres = _bucketManagerUnset,
  Object? publisher = _bucketManagerUnset,
  Object? country = _bucketManagerUnset,
  Object? language = _bucketManagerUnset,
  Object? ageRating = _bucketManagerUnset,
  Object? crossover = _bucketManagerUnset,
  Object? imprint = _bucketManagerUnset,
  Object? seriesGroup = _bucketManagerUnset,
  Object? audienceRating = _bucketManagerUnset,
}) {
  if (identical(creators, _bucketManagerUnset) &&
      identical(characters, _bucketManagerUnset) &&
      identical(storyArcs, _bucketManagerUnset) &&
      identical(genres, _bucketManagerUnset) &&
      identical(publisher, _bucketManagerUnset) &&
      identical(country, _bucketManagerUnset) &&
      identical(language, _bucketManagerUnset) &&
      identical(ageRating, _bucketManagerUnset) &&
      identical(crossover, _bucketManagerUnset) &&
      identical(imprint, _bucketManagerUnset) &&
      identical(seriesGroup, _bucketManagerUnset) &&
      identical(audienceRating, _bucketManagerUnset)) {
    return null;
  }
  final updatedPublishing = _rebuildPublishingDetails(
    item.publishing,
    imprint: imprint,
    seriesGroup: seriesGroup,
  );
  return CatalogItem(
    id: item.id,
    mediaKind: item.mediaKind,
    title: item.title,
    displayTitle: item.displayTitle,
    localizedTitle: item.localizedTitle,
    originalTitle: item.originalTitle,
    titleExtension: item.titleExtension,
    searchAliases: item.searchAliases,
    sortKey: item.sortKey,
    itemNumber: item.itemNumber,
    synopsis: item.synopsis,
    coverImageUrl: item.coverImageUrl,
    thumbnailImageUrl: item.thumbnailImageUrl,
    coverImageData: item.coverImageData,
    editionTitle: item.editionTitle,
    physicalFormat: item.physicalFormat,
    physicalFormatLabel: item.physicalFormatLabel,
    publisher: identical(publisher, _bucketManagerUnset)
        ? item.publisher
        : publisher as String?,
    coverDate: item.coverDate,
    releaseDate: item.releaseDate,
    releaseYear: item.releaseYear,
    barcode: item.barcode,
    variant: item.variant,
    crossover: identical(crossover, _bucketManagerUnset)
        ? item.crossover
        : crossover as String?,
    series: item.series,
    video: item.video,
    music: item.music,
    game: item.game,
    publishing: updatedPublishing,
    creators: identical(creators, _bucketManagerUnset)
        ? item.creators
        : creators as List<Map<String, dynamic>>?,
    characters: identical(characters, _bucketManagerUnset)
        ? item.characters
        : characters as List<String>?,
    storyArcs: identical(storyArcs, _bucketManagerUnset)
        ? item.storyArcs
        : storyArcs as List<String>?,
    rawPlatforms: item.rawPlatforms,
    trailerUrls: item.trailerUrls,
    genres: identical(genres, _bucketManagerUnset)
        ? item.genres
        : genres as List<String>?,
    editions: item.editions,
    country: identical(country, _bucketManagerUnset)
        ? item.country
        : country as String?,
    language: identical(language, _bucketManagerUnset)
        ? item.language
        : language as String?,
    ageRating: identical(ageRating, _bucketManagerUnset)
        ? item.ageRating
        : ageRating as String?,
    audienceRating: identical(audienceRating, _bucketManagerUnset)
        ? item.audienceRating
        : audienceRating as String?,
  );
}

CatalogPublishingDetails? _rebuildPublishingDetails(
  CatalogPublishingDetails? details, {
  Object? imprint = _bucketManagerUnset,
  Object? seriesGroup = _bucketManagerUnset,
}) {
  if (identical(imprint, _bucketManagerUnset) &&
      identical(seriesGroup, _bucketManagerUnset)) {
    return details;
  }
  final nextImprint = identical(imprint, _bucketManagerUnset)
      ? details?.imprint
      : imprint as String?;
  final nextSeriesGroup = identical(seriesGroup, _bucketManagerUnset)
      ? details?.seriesGroup
      : seriesGroup as String?;
  final nextDetails = CatalogPublishingDetails(
    pageCount: details?.pageCount,
    coverPriceCents: details?.coverPriceCents,
    currency: details?.currency,
    imprint: nextImprint,
    subtitle: details?.subtitle,
    seriesGroup: nextSeriesGroup,
  );
  return nextDetails.hasData ? nextDetails : null;
}

Object? _updatedStringList(
  List<String>? values,
  String currentLabel,
  String? replacement,
) {
  if (values == null || values.isEmpty) {
    return _bucketManagerNoChange;
  }
  var changed = false;
  final result = <String>[];
  final seen = <String>{};
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed != currentLabel) {
      final normalized = trimmed.toLowerCase();
      if (trimmed.isNotEmpty && seen.add(normalized)) {
        result.add(trimmed);
      }
      continue;
    }
    changed = true;
    final next = replacement?.trim();
    if (next == null || next.isEmpty) {
      continue;
    }
    final normalized = next.toLowerCase();
    if (seen.add(normalized)) {
      result.add(next);
    }
  }
  if (!changed) {
    return _bucketManagerNoChange;
  }
  return result.isEmpty ? null : List<String>.unmodifiable(result);
}

Object? _updatedStringValue(
  String? value,
  String currentLabel,
  String? replacement,
) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed != currentLabel) {
    return _bucketManagerNoChange;
  }
  final next = replacement?.trim();
  return next == null || next.isEmpty ? null : next;
}

Object? _updatedCreators(
  List<Map<String, dynamic>>? creators,
  LibraryGroupMode mode,
  String currentLabel,
  String? replacement,
) {
  if (creators == null || creators.isEmpty) {
    return _bucketManagerNoChange;
  }
  var changed = false;
  final result = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final creator in creators) {
    final name = creator['name']?.toString().trim();
    final shouldUpdate =
        name == currentLabel && _creatorMatchesMode(creator, mode);
    if (!shouldUpdate) {
      final copy = Map<String, dynamic>.from(creator);
      final dedupeKey = _creatorDedupKey(copy);
      if (dedupeKey == null || seen.add(dedupeKey)) {
        result.add(copy);
      }
      continue;
    }
    changed = true;
    final next = replacement?.trim();
    if (next == null || next.isEmpty) {
      continue;
    }
    final copy = Map<String, dynamic>.from(creator)..['name'] = next;
    final dedupeKey = _creatorDedupKey(copy);
    if (dedupeKey == null || seen.add(dedupeKey)) {
      result.add(copy);
    }
  }
  if (!changed) {
    return _bucketManagerNoChange;
  }
  return result.isEmpty
      ? null
      : List<Map<String, dynamic>>.unmodifiable(result);
}

String? _creatorDedupKey(Map<String, dynamic> creator) {
  final name = creator['name']?.toString().trim();
  if (name == null || name.isEmpty) {
    return null;
  }
  final role = creator['role']?.toString().trim().toLowerCase() ?? '';
  return '${name.toLowerCase()}|$role';
}

bool _creatorMatchesMode(Map<String, dynamic> creator, LibraryGroupMode mode) {
  if (mode == LibraryGroupMode.creator) {
    return true;
  }
  final role = creator['role']?.toString().trim().toLowerCase() ?? '';
  return switch (mode) {
    LibraryGroupMode.actor => role.contains('actor') || role.contains('cast'),
    LibraryGroupMode.director => role.contains('director'),
    LibraryGroupMode.musician => role.contains('musician') ||
        role.contains('music') ||
        role.contains('composer'),
    LibraryGroupMode.photography => role.contains('photography') ||
        role.contains('director of photography') ||
        role.contains('cinemat'),
    LibraryGroupMode.producer => role.contains('producer'),
    LibraryGroupMode.writer => role.contains('writer'),
    LibraryGroupMode.artist =>
      role.contains('artist') && !role.contains('cover'),
    LibraryGroupMode.penciller => role.contains('pencil'),
    LibraryGroupMode.inker => role.contains('ink') && !role.contains('cover'),
    LibraryGroupMode.colorist => role.contains('color'),
    LibraryGroupMode.painter =>
      role.contains('paint') && !role.contains('cover'),
    LibraryGroupMode.letterer => role.contains('letter'),
    LibraryGroupMode.separator => role.contains('separator'),
    LibraryGroupMode.layouts => role.contains('layout'),
    LibraryGroupMode.translator => role.contains('translat'),
    LibraryGroupMode.plotter => role.contains('plotter'),
    LibraryGroupMode.scripter => role.contains('script'),
    LibraryGroupMode.coverArtist => role.contains('cover'),
    LibraryGroupMode.coverPenciller => role.contains('cover') &&
        (role.contains('pencil') || role.contains('penciller')),
    LibraryGroupMode.coverPainter =>
      role.contains('cover') && role.contains('paint'),
    LibraryGroupMode.coverInker =>
      role.contains('cover') && role.contains('ink'),
    LibraryGroupMode.coverColorist =>
      role.contains('cover') && role.contains('color'),
    LibraryGroupMode.coverSeparator =>
      role.contains('cover') && role.contains('separator'),
    LibraryGroupMode.editor => role.contains('editor'),
    LibraryGroupMode.editorInChief =>
      role.contains('editor in chief') || role.contains('editor-in-chief'),
    _ => false,
  };
}
