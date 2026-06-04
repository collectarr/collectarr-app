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

  final sections = <Widget>[];

  final creatorNames = _creatorNames(entry.creators);
  if (creatorNames.isNotEmpty) {
    sections.add(
      LibraryInspectorChipSection(
        title: 'Creators',
        values: creatorNames,
        onValueTap: request.onFilterByValue,
      ),
    );
  }

  if (entry.characters?.isNotEmpty == true) {
    sections.add(
      LibraryInspectorChipSection(
        title: 'Characters',
        values: entry.characters!,
        onValueTap: request.onFilterByValue,
      ),
    );
  }

  if (entry.storyArcs?.isNotEmpty == true) {
    sections.add(
      LibraryInspectorChipSection(
        title: 'Story Arcs',
        values: entry.storyArcs!,
        onValueTap: request.onFilterByValue,
      ),
    );
  }

  if (entry.genres?.isNotEmpty == true) {
    sections.add(
      LibraryInspectorChipSection(
        title: 'Genres',
        values: entry.genres!,
        onValueTap: request.onFilterByValue,
      ),
    );
  }

  final details = _detailFacts(entry);
  if (details.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Info',
        accentColor: request.accent,
        children: [LibraryInspectorFactGrid(facts: details)],
      ),
    );
  }

  final collector = _collectorFacts(ownedItem);
  if (collector.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Collector',
        accentColor: request.accent,
        children: [LibraryInspectorFactGrid(facts: collector)],
      ),
    );
  }

  final personal = _personalFacts(entry, ownedItem, trackingEntry);
  if (personal.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Personal',
        accentColor: request.accent,
        children: [LibraryInspectorFactGrid(facts: personal)],
      ),
    );
  }

  final value = _valueFacts(ownedItem, request.ownedCopies);
  if (value.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Value',
        accentColor: request.accent,
        children: [LibraryInspectorFactGrid(facts: value)],
      ),
    );
  }

  final notes = _noteFacts(entry, ownedItem);
  if (notes.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Notes',
        accentColor: request.accent,
        children: [LibraryInspectorFactGrid(facts: notes)],
      ),
    );
  }

  final links = _linkFacts(entry);
  if (links.isNotEmpty) {
    sections.add(
      LibraryInspectorSection(
        title: 'Links',
        accentColor: request.accent,
        children: [LibraryInspectorFactGrid(facts: links)],
      ),
    );
  }

  return sections;
}

List<String> _creatorNames(List<Map<String, dynamic>>? creators) {
  if (creators == null || creators.isEmpty) {
    return const [];
  }
  final seen = <String>{};
  final values = <String>[];
  for (final creator in creators) {
    final name = creator['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      continue;
    }
    final key = name.toLowerCase();
    if (seen.add(key)) {
      values.add(name);
    }
  }
  return values;
}

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

List<LibraryInspectorFactData> _personalFacts(
  LibraryWorkspaceEntry entry,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
) {
  if (ownedItem == null && trackingEntry == null) {
    return const [];
  }
  final rows = <LibraryInspectorFactData>[];
  final rating = trackingEntry?.rating ?? ownedItem?.rating;
  if (rating != null && rating > 0) {
    rows.add(LibraryInspectorFactData('My Rating', '$rating / 10'));
  }
  final trackingStatusLabel = trackingEntry?.status?.label;
  final readStatus =
      trackingStatusLabel == null || trackingStatusLabel == 'Not tracked'
          ? ownedItem?.readStatus
          : trackingStatusLabel;
  rows.add(LibraryInspectorFactData('Read', _readLabel(readStatus)));
  if (ownedItem?.indexNumber != null) {
    rows.add(
        LibraryInspectorFactData('Index', ownedItem!.indexNumber.toString()));
  }
  rows.add(
    LibraryInspectorFactData(
      'Added',
      _formatTimestamp(ownedItem?.createdAt ?? ownedItem?.updatedAt),
    ),
  );
  rows.add(
    LibraryInspectorFactData(
      'Modified',
      _formatTimestamp(ownedItem?.updatedAt ?? entry.updatedAt),
    ),
  );
  return rows;
}

List<LibraryInspectorFactData> _valueFacts(
  OwnedItem? ownedItem,
  List<OwnedItem> ownedCopies,
) {
  if (ownedItem == null) {
    return const [];
  }
  final effectiveOwnedCopies =
      ownedCopies.isNotEmpty ? ownedCopies : <OwnedItem>[ownedItem];

  final rows = <LibraryInspectorFactData>[];
  if (ownedItem.coverPriceCents != null) {
    rows.add(LibraryInspectorFactData('Cover Price',
        formatMoney(ownedItem.coverPriceCents, ownedItem.currency)));
  }
  if (ownedItem.marketValueCents != null) {
    rows.add(LibraryInspectorFactData('Current Value',
        formatMoney(ownedItem.marketValueCents, ownedItem.currency)));
  }
  if (ownedItem.pricePaidCents != null) {
    rows.add(LibraryInspectorFactData(
        'Paid', formatMoney(ownedItem.pricePaidCents, ownedItem.currency)));
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
