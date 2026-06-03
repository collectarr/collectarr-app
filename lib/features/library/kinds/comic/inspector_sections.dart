import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/chrome/library_inspector.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<Widget> buildComicInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) {
  final entry = request.entry;
  final ownedItem = request.ownedItem;
  final trackingEntry = request.trackingEntry;

  return [
    _buildFactSection(
      title: 'Creators',
      rows: _creatorRows(entry.creators),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Characters',
      rows: _characterRows(entry.characters),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Details',
      rows: _detailRows(entry),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Personal',
      rows: _personalRows(entry, ownedItem, trackingEntry),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Collector',
      rows: _collectorRows(ownedItem),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Value',
      rows: _valueRows(ownedItem, request.ownedCopies),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Notes',
      rows: _noteRows(entry, ownedItem),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Tags',
      rows: _tagRows(entry, ownedItem),
      accent: request.accent,
    ),
    _buildFactSection(
      title: 'Links',
      rows: _linkRows(entry),
      accent: request.accent,
    ),
  ].whereType<Widget>().toList(growable: false);
}

Widget? _buildFactSection({
  required String title,
  required List<_ComicRowData> rows,
  required Color accent,
}) {
  if (rows.isEmpty) {
    return null;
  }
  return LibraryInspectorSection(
    title: title,
    accentColor: accent,
    children: [
      LibraryInspectorFactGrid(
        facts: [
          for (final row in rows)
            LibraryInspectorFactData(
              row.label,
              row.value,
              onTap: row.onTap,
            ),
        ],
      ),
    ],
  );
}

class _ComicRowData {
  const _ComicRowData({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;
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
      _ComicRowData(label: entry.key, value: entry.value.join(' | ')),
  ];
}

List<_ComicRowData> _characterRows(List<String>? characters) {
  if (characters == null || characters.isEmpty) {
    return const <_ComicRowData>[];
  }
  final filtered = [
    for (final character in characters)
      if (character.trim().isNotEmpty) character.trim(),
  ];
  if (filtered.isEmpty) {
    return const <_ComicRowData>[];
  }
  return [
    _ComicRowData(label: 'Featured', value: filtered.join(', ')),
  ];
}

List<_ComicRowData> _detailRows(LibraryWorkspaceEntry entry) {
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
        label: 'Pages',
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

  final rows = <_ComicRowData>[];
  final rating = trackingEntry?.rating ?? ownedItem?.rating;
  final trackingStatusLabel = trackingEntry?.status?.label;
  final readStatus =
      trackingStatusLabel == null || trackingStatusLabel == 'Not tracked'
      ? ownedItem?.readStatus
      : trackingStatusLabel;

  if (rating != null && rating > 0) {
    rows.add(_ComicRowData(label: 'My Rating', value: '$rating / 10'));
  }
  rows.add(_ComicRowData(label: 'Read', value: _readLabel(readStatus)));
  if (ownedItem?.indexNumber != null) {
    rows.add(_ComicRowData(label: 'Index', value: ownedItem!.indexNumber.toString()));
  }
  rows.add(
    _ComicRowData(
      label: 'Added',
      value: _formatTimestamp(ownedItem?.createdAt ?? ownedItem?.updatedAt),
    ),
  );
  rows.add(
    _ComicRowData(
      label: 'Modified',
      value: _formatTimestamp(ownedItem?.updatedAt ?? entry.updatedAt),
    ),
  );
  return rows;
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
    rows.add(_ComicRowData(label: 'Certification', value: ownedItem.certificationNumber!.trim()));
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
        value: trailer.title?.trim().isNotEmpty == true
            ? trailer.title!.trim()
            : trailer.url,
        onTap: () => _launchUrl(trailer.url),
      ),
  ];
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

Future<void> _launchUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
