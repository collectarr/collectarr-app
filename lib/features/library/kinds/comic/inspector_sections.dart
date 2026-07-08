import 'package:collectarr_app/core/models/owned_item.dart';

import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/sections/links_trailers_section.dart';
import 'package:collectarr_app/features/library/details/library_detail_chip.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
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
    return LibraryDetailSection(
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
          LibraryDetailSection(
            title: 'Overview',
            accentColor: request.accent,
            children: [
              LibraryDetailFieldTable(fields: _detailFacts(request.entry)),
              if (request.entry.synopsis?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  request.entry.synopsis!.trim(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (request.entry.genres?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                LibraryDetailSection(
                  title: 'Genres',
                  children: [
                    LibraryDetailChipGroupWidget(
                      label: 'Genres',
                      values: request.entry.genres!,
                      onValueTap: request.onFilterByValue,
                    ),
                  ],
                ),
              ],
              if (request.entry.storyArcs?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                LibraryDetailSection(
                  title: 'Story arcs',
                  children: [
                    LibraryDetailChipGroupWidget(
                      label: 'Story arcs',
                      values: request.entry.storyArcs!,
                      onValueTap: request.onFilterByValue,
                    ),
                  ],
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
          LibraryDetailSection(
            title: 'Value details',
            accentColor: request.accent,
            children: [LibraryDetailFieldTable(fields: _valueFacts(request.entry, request.ownedItem, request.ownedCopies))],
          ),
          if (request.ownedItem != null) ...[
            const SizedBox(height: 8),
            LibraryDetailSection(
              title: 'Collector',
              accentColor: request.accent,
              children: [LibraryDetailFieldTable(fields: _collectorFacts(request.ownedItem))],
            ),
          ],
        ],
      ),
    ),
    _ComicInspectorTab(
      label: 'Characters',
      icon: Icons.groups_2_outlined,
      builder: (context, ref) => LibraryDetailSection(
        title: 'Characters',
        headerActions: [
          if (request.onEdit != null)
            _editSectionAction(request.onEdit!, tooltip: 'Edit characters'),
        ],
        children: [
          LibraryDetailChipGroupWidget(
            label: 'Characters',
            values: request.entry.characters ?? const <String>[],
            onValueTap: request.onFilterByValue,
          ),
        ],
      ),
    ),
    _ComicInspectorTab(
      label: 'Creators',
      icon: Icons.group_outlined,
      builder: (context, ref) => _ComicCreatorsGroupedSection(
        creators: request.entry.creators ?? const <Map<String, dynamic>>[],
        accent: request.accent,
        onValueTap: request.onFilterByValue,
        headerActions: [
          if (request.onEdit != null)
            _editSectionAction(request.onEdit!, tooltip: 'Edit creators'),
        ],
      ),
    ),
    _ComicInspectorTab(
      label: 'Series',
      icon: Icons.auto_stories_outlined,
      builder: (context, ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LibraryDetailSection(
            title: 'Series metadata',
            accentColor: request.accent,
            children: [LibraryDetailFieldTable(fields: _seriesFacts(request.entry))],
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
            LibraryDetailSection(
              title: 'Notes',
              accentColor: request.accent,
              children: [LibraryDetailFieldTable(fields: _noteFacts(request.entry, request.ownedItem))],
            ),
          if (_linkFacts(request.entry).isNotEmpty) ...[
            const SizedBox(height: 8),
            LibraryDetailSection(
              title: 'Links',
              accentColor: request.accent,
              children: [LibraryDetailFieldTable(fields: _linkFacts(request.entry))],
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
      return LibraryDetailSection(
        title: 'Series completeness',
        accentColor: accent,
        children: const [
          Text('No series id is available for this comic.'),
        ],
      );
    }
    final itemsAsync = ref.watch(_comicSeriesItemsProvider(seriesId));
    return itemsAsync.when(
      loading: () => LibraryDetailSection(
        title: 'Series completeness',
        accentColor: accent,
        children: const [Text('Loading series issues...')],
      ),
      error: (error, _) => LibraryDetailSection(
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
        return LibraryDetailSection(
          title: 'Series completeness',
          accentColor: accent,
          children: [
            LibraryDetailFieldTable(
              fields: [
                LibraryDetailField(label: 'Series', value: request.entry.series?.seriesTitle ?? request.entry.title),
                LibraryDetailField(label: 'Items', value: items.length.toString()),
                LibraryDetailField(label: 'Owned', value: ownedCount.toString()),
                LibraryDetailField(label: 'Missing', value: missingNumbers.length.toString()),
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
    this.headerActions = const [],
  });

  final List<Map<String, dynamic>> creators;
  final Color accent;
  final ValueChanged<String>? onValueTap;
  final List<Widget> headerActions;

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
          LibraryDetailSection(
            title: entries[i].key,
            accentColor: accent,
            headerActions: headerActions,
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

List<LibraryDetailField> _detailFacts(LibraryWorkspaceEntry entry) {
  final rows = <LibraryDetailField>[];
  if (entry.referenceFormatLabel?.trim().isNotEmpty == true) {
    rows.add(
        LibraryDetailField(label: 'Format', value: entry.referenceFormatLabel!.trim()));
  }
  if (entry.country?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Country', value: entry.country!.trim()));
  }
  if (entry.language?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Language', value: entry.language!.trim()));
  }
  if (entry.ageRating?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Age', value: entry.ageRating!.trim()));
  }
  if (entry.publishing?.pageCount != null) {
    rows.add(LibraryDetailField(label: 'Pages', value: entry.publishing!.pageCount.toString()));
  }
  return rows;
}

List<LibraryDetailField> _seriesFacts(LibraryWorkspaceEntry entry) {
  final series = entry.series;
  final rows = <LibraryDetailField>[];
  if (series?.seriesTitle?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Series', value: series!.seriesTitle!.trim()));
  }
  if (series?.seriesId?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Series ID', value: series!.seriesId!.trim()));
  }
  if (series?.volumeName?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Volume', value: series!.volumeName!.trim()));
  }
  if (series?.volumeNumber != null) {
    rows.add(LibraryDetailField(label: 'Volume no.', value: series!.volumeNumber!.toString()));
  }
  if (series?.volumeStartYear != null) {
    rows.add(LibraryDetailField(label: 'Start year', value: series!.volumeStartYear!.toString()));
  }
  if (series?.tags.isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Series tags', value: series!.tags.join(', ')));
  }
  return rows;
}

List<LibraryDetailField> _collectorFacts(OwnedItem? ownedItem) {
  if (ownedItem == null) {
    return const [];
  }
  final rows = <LibraryDetailField>[];
  if (ownedItem.rawOrSlabbed?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Raw / Slabbed', value: ownedItem.rawOrSlabbed!.trim()));
  }
  if (ownedItem.gradingCompany?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Grading Co.', value: ownedItem.gradingCompany!.trim()));
  }
  if (ownedItem.certificationNumber?.trim().isNotEmpty == true) {
    rows.add(LibraryDetailField(label: 'Certification', value: ownedItem.certificationNumber!.trim()));
  }
  if (ownedItem.keyComic == true) {
    rows.add(LibraryDetailField(label: 'Key', value: ownedItem.keyReason?.trim().isNotEmpty == true
            ? ownedItem.keyReason!.trim()
            : 'Yes'));
  }
  return rows;
}

List<LibraryDetailField> _valueFacts(
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

  final rows = <LibraryDetailField>[];
  if (ownedItem.coverPriceCents != null) {
    rows.add(LibraryDetailField(label: 'Cover Price', value: formatMoney(ownedItem.coverPriceCents, ownedItem.currency)));
  }
  if (snapshot.providerValueCents != null) {
    rows.add(LibraryDetailField(label: 'Provider Value', value: formatMoney(snapshot.providerValueCents, snapshot.currency)));
  }
  if (snapshot.manualEstimatedValueCents != null) {
    rows.add(LibraryDetailField(label: 'Manual Value', value: formatMoney(snapshot.manualEstimatedValueCents, snapshot.currency)));
  }
  if (snapshot.currentValueCents != null) {
    rows.add(LibraryDetailField(label: 'Current Value', value: formatMoney(snapshot.currentValueCents, snapshot.currency)));
  }
  if (snapshot.insuranceValueCents != null) {
    rows.add(LibraryDetailField(label: 'Insurance Value', value: formatMoney(snapshot.insuranceValueCents, snapshot.currency)));
  }
  if (ownedItem.pricePaidCents != null) {
    rows.add(LibraryDetailField(label: 'Paid', value: formatMoney(ownedItem.pricePaidCents, ownedItem.currency)));
  }
  if (snapshot.profitLossCents != null) {
    rows.add(LibraryDetailField(label: 'Profit / Loss', value: formatMoney(snapshot.profitLossCents, snapshot.currency)));
  }
  final history = snapshot.history;
  if (history.isNotEmpty) {
    rows.add(
      LibraryDetailField(label: 'Value history', value: history
            .map(
              (item) => [
                item.label,
                item.valueCents == null
                    ? '—'
                    : formatMoney(item.valueCents, item.currency),
              ].join(': '),
            )
            .join(' • ')),
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
      rows.add(LibraryDetailField(label: 'Total Value', value: formatMoney(totalMarketValue, totalsCurrency)));
    }
    if (totalPaid != null) {
      rows.add(LibraryDetailField(label: 'Total Paid', value: formatMoney(totalPaid, totalsCurrency)));
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

List<LibraryDetailField> _noteFacts(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  final rows = <LibraryDetailField>[];
  final personalNotes = ownedItem?.personalNotes?.trim();
  final catalogNotes = entry.notes?.trim();
  if (personalNotes != null && personalNotes.isNotEmpty) {
    rows.add(LibraryDetailField(label: 'Personal', value: personalNotes));
  }
  if (catalogNotes != null && catalogNotes.isNotEmpty) {
    rows.add(LibraryDetailField(label: 'Catalog', value: catalogNotes));
  }
  return rows;
}

List<LibraryDetailField> _linkFacts(LibraryWorkspaceEntry entry) {
  if (entry.trailerUrls.isEmpty) {
    return const [];
  }

  return [
    for (final trailer in entry.trailerUrls)
      LibraryDetailField(label: trailer.source?.trim().isNotEmpty == true
            ? trailer.source!.trim()
            : 'Link', value: trailer.title?.trim().isNotEmpty == true
            ? trailer.title!.trim()
            : trailer.url, onTap: () => _launchUrl(trailer.url)),
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

