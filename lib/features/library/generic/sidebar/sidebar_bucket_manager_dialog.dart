import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/features/library/ui/library_action_footer.dart';
import 'package:collectarr_app/features/library/ui/library_dialog_scaffold.dart';
import 'package:collectarr_app/ui/dialog_action_buttons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
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
  String mode,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)
          ?.supportsBucketManagement ??
      false;
}

String libraryBucketManagerListLabel(
  String mode,
  LibraryTypeConfig type,
) {
  return libraryGroupModeDefinitionOrNull(mode, type)
          ?.resolvedBucketManagerListLabel ??
      genericGroupModeSidebarTitle(mode, type);
}

CatalogItem? renameLibraryGroupBucketValue(
  LibraryMetadataItem item,
  String mode,
  String currentLabel,
  String nextLabel,
) {
  final normalizedNext = nextLabel.trim();
  if (normalizedNext.isEmpty || normalizedNext == currentLabel) {
    return null;
  }
  return _updatedCatalogItemForBucket(
    item.toCatalogItem(),
    mode,
    currentLabel,
    replacement: normalizedNext,
  );
}

CatalogItem? deleteLibraryGroupBucketValue(
  LibraryMetadataItem item,
  String mode,
  String currentLabel,
) {
  return _updatedCatalogItemForBucket(item.toCatalogItem(), mode, currentLabel);
}

Future<void> showLibraryBucketManagerDialog({
  required BuildContext context,
  required LibraryTypeConfig type,
  required String groupMode,
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
  final String groupMode;
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
    return LibraryDialogScaffold(
      title: Text(title),
      onClose: _submitting ? null : () => Navigator.of(context).pop(),
      maxWidth: 760,
      maxHeight: 760,
      padding: EdgeInsets.zero,
      footer: LibraryActionFooter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
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
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: palette.divider),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.divider),
                    borderRadius: BorderRadius.zero,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const SizedBox(width: 40),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                icon: const Icon(Icons.edit_outlined, size: 18),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    entry.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
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
        ],
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
  String mode,
  String currentLabel, {
  String? replacement,
}) {
  switch (mode) {
    case 'genre':
      final genres = _updatedStringList(item.genres, currentLabel, replacement);
      return identical(genres, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, genres: genres);
    case 'character':
      final characters =
          _updatedStringList(item.characters, currentLabel, replacement);
      return identical(characters, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, characters: characters);
    case 'story_arc':
      final storyArcs =
          _updatedStringList(item.storyArcs, currentLabel, replacement);
      return identical(storyArcs, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, storyArcs: storyArcs);
    case 'creator':
    case 'actor':
    case 'director':
    case 'musician':
    case 'photography':
    case 'producer':
    case 'writer':
    case 'artist':
    case 'penciller':
    case 'inker':
    case 'colorist':
    case 'painter':
    case 'letterer':
    case 'separator':
    case 'layouts':
    case 'translator':
    case 'plotter':
    case 'scripter':
    case 'cover_artist':
    case 'cover_penciller':
    case 'cover_painter':
    case 'cover_inker':
    case 'cover_colorist':
    case 'cover_separator':
    case 'editor':
    case 'editor_in_chief':
      final creators =
          _updatedCreators(item.creators, mode, currentLabel, replacement);
      return identical(creators, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, creators: creators);
    case 'publisher':
      final publisher =
          _updatedStringValue(item.publisher, currentLabel, replacement);
      return identical(publisher, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, publisher: publisher);
    case 'country':
      final country =
          _updatedStringValue(item.country, currentLabel, replacement);
      return identical(country, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, country: country);
    case 'language':
      final language =
          _updatedStringValue(item.language, currentLabel, replacement);
      return identical(language, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, language: language);
    case 'age_rating':
      final ageRating =
          _updatedStringValue(item.ageRating, currentLabel, replacement);
      return identical(ageRating, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, ageRating: ageRating);
    case 'crossover':
      final crossover =
          _updatedStringValue(item.crossover, currentLabel, replacement);
      return identical(crossover, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, crossover: crossover);
    case 'imprint':
      final imprint = _updatedStringValue(
        item.publishing?.imprint,
        currentLabel,
        replacement,
      );
      return identical(imprint, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, imprint: imprint);
    case 'series_group':
      final seriesGroup = _updatedStringValue(
        item.publishing?.seriesGroup,
        currentLabel,
        replacement,
      );
      return identical(seriesGroup, _bucketManagerNoChange)
          ? null
          : _rebuildCatalogItem(item, seriesGroup: seriesGroup);
    case 'audience_rating':
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
  String mode,
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

bool _creatorMatchesMode(Map<String, dynamic> creator, String mode) {
  if (mode == 'creator') {
    return true;
  }
  final role = creator['role']?.toString().trim().toLowerCase() ?? '';
  return switch (mode) {
    'actor' => role.contains('actor') || role.contains('cast'),
    'director' => role.contains('director'),
    'musician' => role.contains('musician') ||
        role.contains('music') ||
        role.contains('composer'),
    'photography' => role.contains('photography') ||
        role.contains('director of photography') ||
        role.contains('cinemat'),
    'producer' => role.contains('producer'),
    'writer' => role.contains('writer'),
    'artist' =>
      role.contains('artist') && !role.contains('cover'),
    'penciller' => role.contains('pencil'),
    'inker' => role.contains('ink') && !role.contains('cover'),
    'colorist' => role.contains('color'),
    'painter' =>
      role.contains('paint') && !role.contains('cover'),
    'letterer' => role.contains('letter'),
    'separator' => role.contains('separator'),
    'layouts' => role.contains('layout'),
    'translator' => role.contains('translat'),
    'plotter' => role.contains('plotter'),
    'scripter' => role.contains('script'),
    'cover_artist' => role.contains('cover'),
    'cover_penciller' => role.contains('cover') &&
        (role.contains('pencil') || role.contains('penciller')),
    'cover_painter' =>
      role.contains('cover') && role.contains('paint'),
    'cover_inker' =>
      role.contains('cover') && role.contains('ink'),
    'cover_colorist' =>
      role.contains('cover') && role.contains('color'),
    'cover_separator' =>
      role.contains('cover') && role.contains('separator'),
    'editor' => role.contains('editor'),
    'editor_in_chief' =>
      role.contains('editor in chief') || role.contains('editor-in-chief'),
    _ => false,
  };
}
