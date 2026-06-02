import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<Widget> buildComicInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) {
  return [
    _ComicInspectorDashboard(request: request),
  ];
}

class _ComicInspectorDashboard extends StatelessWidget {
  const _ComicInspectorDashboard({required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final entry = request.entry;
    final ownedItem = request.ownedItem;
    final trackingEntry = request.trackingEntry;
    final detailRows = _detailRows(entry, ownedItem);
    final collectorRows = _collectorRows(ownedItem);
    final valueRows = _valueRows(ownedItem, request.ownedCopies);
    final noteRows = _noteRows(entry, ownedItem);
    final tagRows = _tagRows(entry, ownedItem);
    final linkRows = _linkRows(entry);

    final panels = <_ComicPanelData>[
      if (_creatorRows(entry.creators).isNotEmpty)
        _ComicPanelData(title: 'Creators', rows: _creatorRows(entry.creators)),
      if (_characterRows(entry.characters).isNotEmpty)
        _ComicPanelData(title: 'Characters', rows: _characterRows(entry.characters)),
      if (detailRows.isNotEmpty)
        _ComicPanelData(title: 'Details', rows: detailRows),
      if (_personalRows(entry, ownedItem, trackingEntry).isNotEmpty)
        _ComicPanelData(
          title: 'Personal',
          rows: _personalRows(entry, ownedItem, trackingEntry),
        ),
      if (collectorRows.isNotEmpty)
        _ComicPanelData(title: 'Collector', rows: collectorRows),
      if (valueRows.isNotEmpty)
        _ComicPanelData(
          title: 'Value',
          rows: valueRows,
          variant: _ComicPanelVariant.value,
        ),
      if (noteRows.isNotEmpty)
        _ComicPanelData(title: 'Notes', rows: noteRows),
      if (tagRows.isNotEmpty)
        _ComicPanelData(title: 'Tags', rows: tagRows),
      if (linkRows.isNotEmpty)
        _ComicPanelData(title: 'Links', rows: linkRows),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 2 : 1;
        const spacing = 2.0;

        Widget buildPanel(_ComicPanelData panel) => _ComicPanel(
          title: panel.title,
          rows: panel.rows,
          accent: request.accent,
          variant: panel.variant,
          initialVisibleRows: panel.title == 'Creators' ? 5 : null,
        );

        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < panels.length; index++) ...[
                buildPanel(panels[index]),
                if (index != panels.length - 1) const SizedBox(height: spacing),
              ],
            ],
          );
        }

        final leftPanels = panels
            .where(
              (panel) =>
                  panel.title == 'Creators' ||
              panel.title == 'Characters' ||
                  panel.title == 'Personal' ||
              panel.title == 'Value' ||
              panel.title == 'Tags',
            )
            .toList();
        final rightPanels = panels
            .where(
              (panel) =>
              panel.title == 'Details' ||
              panel.title == 'Collector' ||
              panel.title == 'Notes' ||
              panel.title == 'Links',
            )
            .toList();

        Widget buildColumn(List<_ComicPanelData> columnPanels) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < columnPanels.length; index++) ...[
                buildPanel(columnPanels[index]),
                if (index != columnPanels.length - 1)
                  const SizedBox(height: spacing),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildColumn(leftPanels)),
            const SizedBox(width: spacing),
            Expanded(child: buildColumn(rightPanels)),
          ],
        );
      },
    );
  }
}

class _ComicPanelData {
  const _ComicPanelData({
    required this.title,
    required this.rows,
    this.variant = _ComicPanelVariant.standard,
  });

  final String title;
  final List<_ComicRowData> rows;
  final _ComicPanelVariant variant;
}

enum _ComicPanelVariant { standard, value }

class _ComicRowData {
  const _ComicRowData({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;
}

class _ComicPanel extends StatefulWidget {
  const _ComicPanel({
    required this.title,
    required this.rows,
    required this.accent,
    required this.variant,
    this.initialVisibleRows,
  });

  final String title;
  final List<_ComicRowData> rows;
  final Color accent;
  final _ComicPanelVariant variant;
  final int? initialVisibleRows;

  @override
  State<_ComicPanel> createState() => _ComicPanelState();
}

class _ComicPanelState extends State<_ComicPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final surface = palette.surface;
    final headerSurface = Color.alphaBlend(
      widget.accent.withValues(alpha: palette.isDark ? 0.022 : 0.01),
      palette.surface,
    );
    final altSurface = palette.isDark
        ? Color.alphaBlend(
            Colors.white.withValues(alpha: 0.012),
            palette.surface,
          )
        : const Color(0xFFF7F8FA);
    final border =
        palette.divider.withValues(alpha: palette.isDark ? 0.82 : 0.52);

    final canCollapse = widget.initialVisibleRows != null &&
        widget.rows.length > widget.initialVisibleRows!;
    final visibleRows = canCollapse && !_expanded
        ? widget.rows.take(widget.initialVisibleRows!).toList()
        : widget.rows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 17,
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          decoration: BoxDecoration(
            color: headerSurface,
            border: Border(
              top: BorderSide(color: border),
              bottom: BorderSide(color: border),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: widget.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      fontSize: 9.5,
                      height: 1,
                    ),
              ),
              if (canCollapse) ...[
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    child: Row(
                      children: [
                        Text(
                          _expanded ? 'Collapse' : 'View all',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: palette.textMuted,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                fontSize: 8.25,
                              ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 8,
                          color: palette.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        for (var index = 0; index < visibleRows.length; index++)
          _ComicTableRow(
            row: visibleRows[index],
            shaded: index.isEven,
            surface: surface,
            altSurface: altSurface,
            border: border,
            variant: widget.variant,
            accent: widget.accent,
          ),
      ],
    );
  }
}

class _ComicTableRow extends StatelessWidget {
  const _ComicTableRow({
    required this.row,
    required this.shaded,
    required this.surface,
    required this.altSurface,
    required this.border,
    required this.variant,
    required this.accent,
  });

  final _ComicRowData row;
  final bool shaded;
  final Color surface;
  final Color altSurface;
  final Color border;
  final _ComicPanelVariant variant;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    if (variant == _ComicPanelVariant.value) {
      return Container(
        decoration: BoxDecoration(
          color: shaded ? altSurface : surface,
          border: Border(top: BorderSide(color: border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.75),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 58,
              child: Text(
                row.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: palette.textMuted,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      fontSize: 8.75,
                    ),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  row.value ?? '-',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: row.label == 'Current Value'
                            ? accent
                            : palette.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        fontSize: row.label == 'Current Value' ? 13.5 : 12,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final valueWidget = row.valueWidget ??
        Text(
          row.value ?? '-',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.08,
                fontSize: 9.25,
              ),
        );

    return Container(
      decoration: BoxDecoration(
        color: shaded ? altSurface : surface,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.75),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    fontSize: 8.75,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }
}

List<_ComicRowData> _creatorRows(List<Map<String, dynamic>>? creators) {
  if (creators == null || creators.isEmpty) {
    return const <_ComicRowData>[];
  }

  final grouped = <String, List<String>>{};
  for (final credit in creators) {
    final name = credit['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      continue;
    }
    final role = credit['role']?.toString().trim();
    final key = role == null || role.isEmpty ? 'Creator' : role;
    grouped.putIfAbsent(key, () => <String>[]).add(name);
  }

  return [
    for (final entry in grouped.entries)
      _ComicRowData(
        label: entry.key,
        valueWidget: entry.value.length <= 2
            ? null
            : _ExpandableCreatorNames(names: entry.value),
        value: entry.value.join(' | '),
      ),
  ];
}

List<_ComicRowData> _characterRows(List<String>? characters) {
  if (characters == null || characters.isEmpty) {
    return const <_ComicRowData>[];
  }

  return [
    for (final character in characters)
      if (character.trim().isNotEmpty)
        _ComicRowData(label: 'Character', value: character.trim()),
  ];
}

List<_ComicRowData> _detailRows(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  final rows = <_ComicRowData>[];
  if (entry.ageRating?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Age', value: entry.ageRating!.trim()));
  }
  if (entry.referenceFormatLabel?.trim().isNotEmpty == true) {
    rows.add(
      _ComicRowData(label: 'Format', value: entry.referenceFormatLabel!.trim()),
    );
  }
  if (entry.genres?.isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Genre', value: entry.genres!.join(', ')));
  }
  if (entry.publishing?.pageCount != null) {
    rows.add(
      _ComicRowData(
        label: 'No. of Pages',
        value: entry.publishing!.pageCount.toString(),
      ),
    );
  }
  if (entry.country?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Country', value: entry.country!.trim()));
  }
  if (entry.language?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Language', value: entry.language!.trim()));
  }
  if (entry.characters?.isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Characters', value: entry.characters!.join(', ')));
  }
  if (entry.storyArcs?.isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Story Arc', value: entry.storyArcs!.join(', ')));
  }
  return rows;
}

List<_ComicRowData> _personalRows(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
) {
  if (ownedItem == null && trackingEntry == null) {
    return const <_ComicRowData>[];
  }

  final rating = trackingEntry?.rating ?? ownedItem?.rating;
    final trackingStatusLabel = trackingEntry?.status?.label;
    final readStatus = trackingStatusLabel == null || trackingStatusLabel == 'Not tracked'
      ? ownedItem?.readStatus
      : trackingStatusLabel;

  return [
    if (rating != null && rating > 0)
      _ComicRowData(label: 'My Rating', valueWidget: _ComicStars(rating: rating)),
    _ComicRowData(label: 'Read', value: _readLabel(readStatus)),
    if (ownedItem?.indexNumber != null)
      _ComicRowData(label: 'Index', value: ownedItem!.indexNumber.toString()),
    _ComicRowData(
      label: 'Added Date',
      value: _formatTimestamp(ownedItem?.createdAt ?? ownedItem?.updatedAt),
    ),
    _ComicRowData(
      label: 'Modified Date',
      value: _formatTimestamp(ownedItem?.updatedAt ?? entry.updatedAt),
    ),
  ];
}

List<_ComicRowData> _valueRows(
  OwnedItem? ownedItem,
  List<OwnedItem> ownedCopies,
) {
  if (ownedItem == null) {
    return const <_ComicRowData>[];
  }

  final effectiveOwnedCopies = ownedCopies.isNotEmpty
      ? ownedCopies
      : <OwnedItem>[ownedItem];
  final rows = <_ComicRowData>[];
  if (ownedItem.coverPriceCents != null) {
    rows.add(
      _ComicRowData(
        label: 'Cover Price',
        value: formatMoney(ownedItem.coverPriceCents, ownedItem.currency),
      ),
    );
  }
  if (ownedItem.marketValueCents != null) {
    rows.add(
      _ComicRowData(
        label: 'Current Value',
        value: formatMoney(ownedItem.marketValueCents, ownedItem.currency),
      ),
    );
  }
  if (ownedItem.pricePaidCents != null) {
    rows.add(
      _ComicRowData(
        label: 'Paid',
        value: formatMoney(ownedItem.pricePaidCents, ownedItem.currency),
      ),
    );
  }
  if (effectiveOwnedCopies.length > 1) {
    final totalsCurrency = _inspectorValueCurrency(effectiveOwnedCopies, ownedItem);
    final totalMarketValue = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.marketValueCents,
    );
    final totalPaid = _sumOwnedValueCents(
      effectiveOwnedCopies,
      (item) => item.pricePaidCents,
    );
    if (totalMarketValue != null) {
      rows.add(
        _ComicRowData(
          label: 'Total Value',
          value: formatMoney(totalMarketValue, totalsCurrency),
        ),
      );
    }
    if (totalPaid != null) {
      rows.add(
        _ComicRowData(
          label: 'Total Paid',
          value: formatMoney(totalPaid, totalsCurrency),
        ),
      );
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

List<_ComicRowData> _collectorRows(OwnedItem? ownedItem) {
  if (ownedItem == null) {
    return const <_ComicRowData>[];
  }

  final rows = <_ComicRowData>[];
  if (ownedItem.rawOrSlabbed?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Raw / Slabbed', value: ownedItem.rawOrSlabbed!.trim()));
  }
  if (ownedItem.gradingCompany?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Grading Co.', value: ownedItem.gradingCompany!.trim()));
  }
  if (ownedItem.certificationNumber?.trim().isNotEmpty == true) {
    rows.add(
      _ComicRowData(
        label: 'Certification',
        value: ownedItem.certificationNumber!.trim(),
      ),
    );
  }
  if (ownedItem.labelType?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Label Type', value: ownedItem.labelType!.trim()));
  }
  if (ownedItem.customLabel?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Custom Label', value: ownedItem.customLabel!.trim()));
  }
  if (ownedItem.pageQuality?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Page Quality', value: ownedItem.pageQuality!.trim()));
  }
  if (ownedItem.signedBy?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Signed By', value: ownedItem.signedBy!.trim()));
  }
  if (ownedItem.keyComic == true) {
    rows.add(_ComicRowData(label: 'Key', value: ownedItem.keyReason ?? 'Yes'));
  }
  if (ownedItem.keyCategory?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Key Category', value: ownedItem.keyCategory!.trim()));
  }
  if (ownedItem.keySeverity?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Key Severity', value: ownedItem.keySeverity!.trim()));
  }
  if (ownedItem.graderNotes?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Grader Notes', value: ownedItem.graderNotes!.trim()));
  }
  return rows;
}

List<_ComicRowData> _noteRows(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  final rows = <_ComicRowData>[];
  final personalNotes = ownedItem?.personalNotes?.trim();
  final catalogNotes = entry.notes?.trim();
  if (personalNotes != null && personalNotes.isNotEmpty) {
    rows.add(_ComicRowData(label: 'Personal', value: personalNotes));
  }
  if (catalogNotes != null && catalogNotes.isNotEmpty) {
    rows.add(_ComicRowData(label: 'Catalog', value: catalogNotes));
  }
  return rows;
}

List<_ComicRowData> _tagRows(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
) {
  final seen = <String>{};
  final values = <String>[];

  void addTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return;
    }
    for (final part in raw.split(',')) {
      final normalized = part.trim();
      if (normalized.isEmpty) {
        continue;
      }
      if (seen.add(normalized.toLowerCase())) {
        values.add(normalized);
      }
    }
  }

  addTags(ownedItem?.tags);
  addTags(entry.tags);

  return [
    for (final tag in values) _ComicRowData(label: 'Tag', value: tag),
  ];
}

List<_ComicRowData> _linkRows(LibraryWorkspaceEntry entry) {
  if (entry.trailerUrls.isEmpty) {
    return const <_ComicRowData>[];
  }

  return [
    for (final trailer in entry.trailerUrls)
      _ComicRowData(
        label: trailer.source?.trim().isNotEmpty == true
            ? trailer.source!.trim()
            : 'Link',
        valueWidget: _ComicExternalLinkRow(trailer: trailer),
      ),
  ];
}

class _ComicStars extends StatelessWidget {
  const _ComicStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 1,
      children: [
        for (var index = 0; index < 10; index++)
          Icon(
            index < rating ? Icons.star : Icons.star_border,
            size: 11,
            color: const Color(0xFF86909A),
          ),
      ],
    );
  }
}

String _readLabel(String? status) {
  final normalized = status?.trim().toLowerCase();
  return switch (normalized) {
    null || '' || 'not tracked' || 'not_started' || 'planned' => 'X',
    'completed' => 'Read',
    'reading' => 'Reading',
    String value => value.replaceAll('_', ' '),
  };
}

String _formatTimestamp(DateTime? value) {
  if (value == null) {
    return '-';
  }

  final local = value.toLocal();
  final month = switch (local.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    _ => 'Dec',
  };

  String twoDigits(int number) => number.toString().padLeft(2, '0');

  return '$month ${local.day}, ${local.year} ${twoDigits(local.hour)}:${twoDigits(local.minute)}:${twoDigits(local.second)}';
}

class _ExpandableCreatorNames extends StatefulWidget {
  const _ExpandableCreatorNames({required this.names});

  final List<String> names;

  @override
  State<_ExpandableCreatorNames> createState() =>
      _ExpandableCreatorNamesState();
}

class _ExpandableCreatorNamesState extends State<_ExpandableCreatorNames> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final visible = _expanded ? widget.names : widget.names.take(2).toList();
    final remaining = widget.names.length - 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          visible.join(' | '),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.08,
                fontSize: 9.25,
              ),
        ),
        if (!_expanded && remaining > 0) ...[
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Text(
              'View all ($remaining more)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 8.5,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ComicExternalLinkRow extends StatelessWidget {
  const _ComicExternalLinkRow({required this.trailer});

  final TrailerLink trailer;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final label = trailer.title?.trim().isNotEmpty == true
        ? trailer.title!.trim()
        : trailer.url;
    return InkWell(
      onTap: () => _launchUrl(trailer.url),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.link_outlined, size: 11, color: palette.textMuted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.08,
                    fontSize: 9.25,
                    decoration: TextDecoration.underline,
                    decorationColor: palette.textMuted.withValues(alpha: 0.45),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}