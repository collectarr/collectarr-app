import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

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
    final valueRows = _valueRows(ownedItem);

    final panels = <_ComicPanelData>[
      if (_creatorRows(entry.creators).isNotEmpty)
        _ComicPanelData(title: 'Creators', rows: _creatorRows(entry.creators)),
      if (detailRows.isNotEmpty)
        _ComicPanelData(title: 'Details', rows: detailRows),
      if (_personalRows(entry, ownedItem, trackingEntry).isNotEmpty)
        _ComicPanelData(
          title: 'Personal',
          rows: _personalRows(entry, ownedItem, trackingEntry),
        ),
      if (valueRows.isNotEmpty)
        _ComicPanelData(title: 'Value', rows: valueRows),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        const spacing = 14.0;
        final panelWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: [
            for (final panel in panels)
              SizedBox(
                width: panelWidth,
                child: _ComicPanel(
                  title: panel.title,
                  rows: panel.rows,
                  accent: request.accent,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ComicPanelData {
  const _ComicPanelData({required this.title, required this.rows});

  final String title;
  final List<_ComicRowData> rows;
}

class _ComicRowData {
  const _ComicRowData({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;
}

class _ComicPanel extends StatelessWidget {
  const _ComicPanel({
    required this.title,
    required this.rows,
    required this.accent,
  });

  final String title;
  final List<_ComicRowData> rows;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final surface = Color.alphaBlend(
      accent.withValues(alpha: palette.isDark ? 0.04 : 0.02),
      palette.isDark ? palette.panelRaised : Colors.white,
    );
    final altSurface = palette.isDark
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.03), palette.surface)
        : const Color(0xFFF2F4F6);
    final border = palette.divider.withValues(alpha: palette.isDark ? 1 : 0.55);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          for (var index = 0; index < rows.length; index++)
            _ComicTableRow(
              row: rows[index],
              shaded: index.isEven,
              surface: surface,
              altSurface: altSurface,
              border: border,
            ),
        ],
      ),
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
  });

  final _ComicRowData row;
  final bool shaded;
  final Color surface;
  final Color altSurface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final valueWidget = row.valueWidget ??
        Text(
          row.value ?? '-',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
        );

    return Container(
      decoration: BoxDecoration(
        color: shaded ? altSurface : surface,
        border: Border(top: BorderSide(color: border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 98,
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: 10),
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
  if (ownedItem?.graderNotes?.trim().isNotEmpty == true) {
    rows.add(_ComicRowData(label: 'Grader Notes', value: ownedItem!.graderNotes!.trim()));
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

List<_ComicRowData> _valueRows(OwnedItem? ownedItem) {
  if (ownedItem == null) {
    return const <_ComicRowData>[];
  }

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
  return rows;
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
            size: 14,
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
        ),
        if (!_expanded && remaining > 0) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Text(
              'View all ($remaining more)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}