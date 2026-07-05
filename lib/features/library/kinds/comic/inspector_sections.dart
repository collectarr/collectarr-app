import 'package:collectarr_app/core/models/owned_item.dart';

import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/value/library_value_snapshot.dart';
import 'package:collectarr_app/state/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ComicInspectorTabsSection extends ConsumerStatefulWidget {
  const ComicInspectorTabsSection({
    super.key,
    required this.request,
  });

  final LibraryInspectorRequest request;

  @override
  ConsumerState<ComicInspectorTabsSection> createState() =>
      _ComicInspectorTabsSectionState();
}

class _ComicInspectorTabsSectionState
    extends ConsumerState<ComicInspectorTabsSection> {
  var _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = _comicInspectorTabs(widget.request);
    final selectedTab = tabs[_selectedTabIndex.clamp(0, tabs.length - 1)];
    return LibraryInspectorSection(
      title: 'Comic detail',
      accentColor: widget.request.accent,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < tabs.length; i++)
              ChoiceChip(
                selected: i == _selectedTabIndex,
                label: Text(tabs[i].label),
                avatar: Icon(tabs[i].icon, size: 14),
                onSelected: (_) => setState(() => _selectedTabIndex = i),
              ),
          ],
        ),
        const SizedBox(height: 10),
        selectedTab.build(context, ref),
      ],
    );
  }
}

class _ComicInspectorTab {
  const _ComicInspectorTab({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final Widget Function(BuildContext context, WidgetRef ref) builder;

  Widget build(BuildContext context, WidgetRef ref) => builder(context, ref);
}

List<_ComicInspectorTab> _comicInspectorTabs(LibraryInspectorRequest request) {
  return [
    _ComicInspectorTab(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      builder: (context, ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryInspectorSection(
            title: 'Overview',
            accentColor: request.accent,
            children: [
              LibraryInspectorFactGrid(facts: _detailFacts(request.entry)),
              if (request.entry.synopsis?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  request.entry.synopsis!.trim(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (request.entry.genres?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                LibraryInspectorChipSection(
                  title: 'Genres',
                  values: request.entry.genres!,
                  onValueTap: request.onFilterByValue,
                ),
              ],
              if (request.entry.storyArcs?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                LibraryInspectorChipSection(
                  title: 'Story arcs',
                  values: request.entry.storyArcs!,
                  onValueTap: request.onFilterByValue,
                ),
              ],
            ],
          ),
        ],
      ),
    ),
    _ComicInspectorTab(
      label: 'Value Details',
      icon: Icons.workspace_premium_outlined,
      builder: (context, ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryInspectorSection(
            title: 'Value details',
            accentColor: request.accent,
            children: [LibraryInspectorFactGrid(facts: _valueFacts(request.entry, request.ownedItem, request.ownedCopies))],
          ),
          if (request.ownedItem != null) ...[
            const SizedBox(height: 8),
            LibraryInspectorSection(
              title: 'Collector',
              accentColor: request.accent,
              children: [LibraryInspectorFactGrid(facts: _collectorFacts(request.ownedItem))],
            ),
          ],
        ],
      ),
    ),
    _ComicInspectorTab(
      label: 'Characters',
      icon: Icons.groups_2_outlined,
      builder: (context, ref) => LibraryInspectorChipSection(
        title: 'Characters',
        values: request.entry.characters ?? const <String>[],
        onValueTap: request.onFilterByValue,
      ),
    ),
    _ComicInspectorTab(
      label: 'Creators',
      icon: Icons.group_outlined,
      builder: (context, ref) => _ComicCreatorsGroupedSection(
        creators: request.entry.creators ?? const <Map<String, dynamic>>[],
        accent: request.accent,
        onValueTap: request.onFilterByValue,
      ),
    ),
    _ComicInspectorTab(
      label: 'Series',
      icon: Icons.auto_stories_outlined,
      builder: (context, ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryInspectorSection(
            title: 'Series metadata',
            accentColor: request.accent,
            children: [LibraryInspectorFactGrid(facts: _seriesFacts(request.entry))],
          ),
          const SizedBox(height: 8),
          ComicSeriesCompletenessSection(
            request: request,
            accent: request.accent,
          ),
        ],
      ),
    ),
    _ComicInspectorTab(
      label: 'Links',
      icon: Icons.language,
      builder: (context, ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_noteFacts(request.entry, request.ownedItem).isNotEmpty)
            LibraryInspectorSection(
              title: 'Notes',
              accentColor: request.accent,
              children: [LibraryInspectorFactGrid(facts: _noteFacts(request.entry, request.ownedItem))],
            ),
          if (_linkFacts(request.entry).isNotEmpty) ...[
            const SizedBox(height: 8),
            LibraryInspectorSection(
              title: 'Links',
              accentColor: request.accent,
              children: [LibraryInspectorFactGrid(facts: _linkFacts(request.entry))],
            ),
          ],
          if (request.entry.trailerUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            InspectorLinksTrailersSection(request: request),
          ],
        ],
      ),
    ),
  ];
}

List<Widget> buildComicInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) {
  return [ComicInspectorTabsSection(request: request)];
}

class ComicSeriesCompletenessSection extends ConsumerWidget {
  const ComicSeriesCompletenessSection({
    super.key,
    required this.request,
    required this.accent,
  });

  final LibraryInspectorRequest request;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesId = request.entry.series?.seriesId;
    if (seriesId == null || seriesId.trim().isEmpty) {
      return LibraryInspectorSection(
        title: 'Series completeness',
        accentColor: accent,
        children: const [
          Text('No series id is available for this comic.'),
        ],
      );
    }
    final itemsAsync = ref.watch(_comicSeriesItemsProvider(seriesId));
    return itemsAsync.when(
      loading: () => LibraryInspectorSection(
        title: 'Series completeness',
        accentColor: accent,
        children: const [Text('Loading series issues...')],
      ),
      error: (error, _) => LibraryInspectorSection(
        title: 'Series completeness',
        accentColor: accent,
        children: [Text('Failed to load series issues: $error')],
      ),
      data: (items) {
        final ownedIds = {
          for (final owned in request.ownedCopies) owned.itemId,
        };
        final missingNumbers = _computeMissingIssues(items, ownedIds);
        final ownedCount = items
            .where((item) => ownedIds.contains(item['id']?.toString()))
            .length;
        return LibraryInspectorSection(
          title: 'Series completeness',
          accentColor: accent,
          children: [
            LibraryInspectorFactGrid(
              facts: [
                LibraryInspectorFactData('Series', request.entry.series?.seriesTitle ?? request.entry.title),
                LibraryInspectorFactData('Items', items.length.toString()),
                LibraryInspectorFactData('Owned', ownedCount.toString()),
                LibraryInspectorFactData('Missing', missingNumbers.length.toString()),
              ],
            ),
            if (missingNumbers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final number in missingNumbers.take(30))
                    Chip(
                      label: Text('#$number'),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (missingNumbers.length > 30)
                    Chip(label: Text('+${missingNumbers.length - 30} more')),
                ],
              ),
            ] else
              const Text('No missing issues detected for the owned copies in this series.'),
          ],
        );
      },
    );
  }
}

class _ComicCreatorsGroupedSection extends StatelessWidget {
  const _ComicCreatorsGroupedSection({
    required this.creators,
    required this.accent,
    required this.onValueTap,
  });

  final List<Map<String, dynamic>> creators;
  final Color accent;
  final ValueChanged<String>? onValueTap;

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) {
      return const SizedBox.shrink();
    }
    final grouped = <String, List<_ComicCreatorChipData>>{};
    for (final credit in creators) {
      final name = credit['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final role = _comicCreatorRoleLabel(credit);
      grouped.putIfAbsent(role, () => <_ComicCreatorChipData>[]).add(
            _ComicCreatorChipData(
              name: name,
              imageUrl: credit['image_url']?.toString().trim(),
            ),
          );
    }
    final entries = grouped.entries.toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          LibraryInspectorSection(
            title: entries[i].key,
            accentColor: accent,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final creator in entries[i].value)
                    ActionChip(
                      avatar: creator.imageUrl == null || creator.imageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 12)
                          : CircleAvatar(
                              backgroundImage: NetworkImage(creator.imageUrl!),
                              radius: 10,
                            ),
                      label: Text(creator.name),
                      onPressed: onValueTap == null ? null : () => onValueTap!(creator.name),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
          if (i != entries.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ComicCreatorChipData {
  const _ComicCreatorChipData({
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String? imageUrl;
}

String _comicCreatorRoleLabel(Map<String, dynamic> credit) {
  final roleId = credit['role_id']?.toString().trim() ?? credit['roleId']?.toString().trim();
  final role = credit['role']?.toString().trim();
  if (roleId != null && roleId.isNotEmpty) {
    return roleId;
  }
  if (role != null && role.isNotEmpty) {
    return role;
  }
  return 'Creators';
}

final _comicSeriesItemsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
  (ref, seriesId) async {
    final api = ref.watch(apiClientProvider);
    return api.getSeriesItems(seriesId);
  },
);

List<LibraryInspectorFactData> _detailFacts(LibraryWorkspaceEntry entry) {
  final rows = <LibraryInspectorFactData>[];
  if (entry.referenceFormatLabel?.trim().isNotEmpty == true) {
    rows.add(
        LibraryInspectorFactData('Format', entry.referenceFormatLabel!.trim()));
  }
  if (entry.country?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Country', entry.country!.trim()));
  }
  if (entry.language?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Language', entry.language!.trim()));
  }
  if (entry.ageRating?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Age', entry.ageRating!.trim()));
  }
  if (entry.publishing?.pageCount != null) {
    rows.add(LibraryInspectorFactData(
        'Pages', entry.publishing!.pageCount.toString()));
  }
  return rows;
}

List<LibraryInspectorFactData> _seriesFacts(LibraryWorkspaceEntry entry) {
  final series = entry.series;
  final rows = <LibraryInspectorFactData>[];
  if (series?.seriesTitle?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Series', series!.seriesTitle!.trim()));
  }
  if (series?.seriesId?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Series ID', series!.seriesId!.trim()));
  }
  if (series?.volumeName?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Volume', series!.volumeName!.trim()));
  }
  if (series?.volumeNumber != null) {
    rows.add(LibraryInspectorFactData('Volume no.', series!.volumeNumber!.toString()));
  }
  if (series?.volumeStartYear != null) {
    rows.add(LibraryInspectorFactData('Start year', series!.volumeStartYear!.toString()));
  }
  if (series?.tags.isNotEmpty == true) {
    rows.add(LibraryInspectorFactData('Series tags', series!.tags.join(', ')));
  }
  return rows;
}

List<LibraryInspectorFactData> _collectorFacts(OwnedItem? ownedItem) {
  if (ownedItem == null) {
    return const [];
  }
  final rows = <LibraryInspectorFactData>[];
  if (ownedItem.rawOrSlabbed?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData(
        'Raw / Slabbed', ownedItem.rawOrSlabbed!.trim()));
  }
  if (ownedItem.gradingCompany?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData(
        'Grading Co.', ownedItem.gradingCompany!.trim()));
  }
  if (ownedItem.certificationNumber?.trim().isNotEmpty == true) {
    rows.add(LibraryInspectorFactData(
        'Certification', ownedItem.certificationNumber!.trim()));
  }
  if (ownedItem.keyComic == true) {
    rows.add(LibraryInspectorFactData(
        'Key',
        ownedItem.keyReason?.trim().isNotEmpty == true
            ? ownedItem.keyReason!.trim()
            : 'Yes'));
  }
  return rows;
}

List<LibraryInspectorFactData> _valueFacts(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
  List<OwnedItem> ownedCopies,
) {
  if (ownedItem == null) {
    return const [];
  }
  final effectiveOwnedCopies =
      ownedCopies.isNotEmpty ? ownedCopies : <OwnedItem>[ownedItem];
  final snapshot = LibraryValueSnapshot.fromEntry(
    entry,
    ownedItem: ownedItem,
    providerName: entry.marketValueCents != null ? 'Provider snapshot' : null,
  );

  final rows = <LibraryInspectorFactData>[];
  if (ownedItem.coverPriceCents != null) {
    rows.add(LibraryInspectorFactData('Cover Price',
        formatMoney(ownedItem.coverPriceCents, ownedItem.currency)));
  }
  if (snapshot.providerValueCents != null) {
    rows.add(LibraryInspectorFactData(
      'Provider Value',
      formatMoney(snapshot.providerValueCents, snapshot.currency),
    ));
  }
  if (snapshot.manualEstimatedValueCents != null) {
    rows.add(LibraryInspectorFactData(
      'Manual Value',
      formatMoney(snapshot.manualEstimatedValueCents, snapshot.currency),
    ));
  }
  if (snapshot.currentValueCents != null) {
    rows.add(LibraryInspectorFactData(
      'Current Value',
      formatMoney(snapshot.currentValueCents, snapshot.currency),
    ));
  }
  if (snapshot.insuranceValueCents != null) {
    rows.add(LibraryInspectorFactData(
      'Insurance Value',
      formatMoney(snapshot.insuranceValueCents, snapshot.currency),
    ));
  }
  if (ownedItem.pricePaidCents != null) {
    rows.add(LibraryInspectorFactData(
        'Paid', formatMoney(ownedItem.pricePaidCents, ownedItem.currency)));
  }
  if (snapshot.profitLossCents != null) {
    rows.add(LibraryInspectorFactData(
      'Profit / Loss',
      formatMoney(snapshot.profitLossCents, snapshot.currency),
    ));
  }
  final history = snapshot.history;
  if (history.isNotEmpty) {
    rows.add(
      LibraryInspectorFactData(
        'Value history',
        history
            .map(
              (item) => [
                item.label,
                item.valueCents == null
                    ? '—'
                    : formatMoney(item.valueCents, item.currency),
              ].join(': '),
            )
            .join(' • '),
      ),
    );
  }

  if (effectiveOwnedCopies.length > 1) {
    final totalsCurrency =
        _inspectorValueCurrency(effectiveOwnedCopies, ownedItem);
    final totalMarketValue = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.marketValueCents,
    );
    final totalPaid = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.pricePaidCents,
    );
    if (totalMarketValue != null) {
      rows.add(LibraryInspectorFactData(
          'Total Value', formatMoney(totalMarketValue, totalsCurrency)));
    }
    if (totalPaid != null) {
      rows.add(LibraryInspectorFactData(
          'Total Paid', formatMoney(totalPaid, totalsCurrency)));
    }
  }
  return rows;
}

int? _sumOwnedValueCents(
  List<OwnedItem> items,
  int? Function(OwnedItem item) selector,
) {
  var hasValue = false;
  var total = 0;
  for (final item in items) {
    final value = selector(item);
    if (value == null) {
      continue;
    }
    hasValue = true;
    total += value;
  }
  return hasValue ? total : null;
}

String? _inspectorValueCurrency(
  List<OwnedItem> ownedCopies,
  OwnedItem? ownedItem,
) {
  for (final copy in ownedCopies) {
    final currency = copy.currency?.trim();
    if (currency != null && currency.isNotEmpty) {
      return currency;
    }
  }
  final ownedCurrency = ownedItem?.currency?.trim();
  if (ownedCurrency != null && ownedCurrency.isNotEmpty) {
    return ownedCurrency;
  }
  return null;
}

List<LibraryInspectorFactData> _noteFacts(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  final rows = <LibraryInspectorFactData>[];
  final personalNotes = ownedItem?.personalNotes?.trim();
  final catalogNotes = entry.notes?.trim();
  if (personalNotes != null && personalNotes.isNotEmpty) {
    rows.add(LibraryInspectorFactData('Personal', personalNotes));
  }
  if (catalogNotes != null && catalogNotes.isNotEmpty) {
    rows.add(LibraryInspectorFactData('Catalog', catalogNotes));
  }
  return rows;
}

List<LibraryInspectorFactData> _linkFacts(LibraryWorkspaceEntry entry) {
  if (entry.trailerUrls.isEmpty) {
    return const [];
  }

  return [
    for (final trailer in entry.trailerUrls)
      LibraryInspectorFactData(
        trailer.source?.trim().isNotEmpty == true
            ? trailer.source!.trim()
            : 'Link',
        trailer.title?.trim().isNotEmpty == true
            ? trailer.title!.trim()
            : trailer.url,
        onTap: () => _launchUrl(trailer.url),
      ),
  ];
}

List<int> _computeMissingIssues(
  List<dynamic> items,
  Set<String> ownedIds,
) {
  final ownedIssueNumbers = <int>{};
  final allIssueNumbers = <int>{};
  for (final item in items) {
    if (item is! Map<String, dynamic>) {
      continue;
    }
    final id = item['id']?.toString();
    final issueNumber = _comicIssueNumberToInt(
      item['issue_number']?.toString() ??
          item['number']?.toString() ??
          item['item_number']?.toString(),
    );
    if (issueNumber != null) {
      allIssueNumbers.add(issueNumber);
      if (id != null && ownedIds.contains(id)) {
        ownedIssueNumbers.add(issueNumber);
      }
    }
  }
  final missing = allIssueNumbers.difference(ownedIssueNumbers).toList(growable: false);
  missing.sort();
  return missing;
}

int? _comicIssueNumberToInt(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  final parsed = int.tryParse(text);
  if (parsed != null) {
    return parsed;
  }
  final normalized = text.replaceAll(RegExp(r'[^0-9]'), '');
  return normalized.isEmpty ? null : int.tryParse(normalized);
}

Future<void> _launchUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
