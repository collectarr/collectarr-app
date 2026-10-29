import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/details/library_detail_field_table.dart';
import 'package:collectarr_app/features/library/details/library_detail_models.dart';
import 'package:collectarr_app/features/library/details/library_detail_section.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_character.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_creator.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/creator_roles.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector/hero.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<Widget> buildComicCatalogItemInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) =>
    [ComicInspectorSections(request: request)];

List<Widget> buildComicLibraryEntryInspectorSections(
  BuildContext _,
  LibraryInspectorRequest request,
) =>
    [ComicInspectorSections(request: request)];

/// The reference details below the header: Creators, Characters and Details
/// side by side, then Personal and Value, then Links. Columns wrap onto
/// further rows when the panel is narrow.
class ComicInspectorSections extends StatelessWidget {
  const ComicInspectorSections({super.key, required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final comic = comicInspectorItem(request);
    final entry = comicInspectorEntry(request);
    final onFilter = request.onFilterByValue;
    Widget section(String title, List<LibraryDetailField> fields) =>
        LibraryDetailSection(
          title: title,
          collapsible: false,
          children: [
            LibraryDetailFieldTable(
                fields: fields,
                minCellWidth: 260,
                labelWidth: 104,
                showHeader: false),
          ],
        );
    final creators = _creatorFields(comic, onFilter);
    final characters = _characterFields(comic, onFilter);
    final details = _detailFields(comic, onFilter);
    final personal = entry == null
        ? const <LibraryDetailField>[]
        : _personal(entry, request.item.source.addedAt);
    final value = entry == null ? const <LibraryDetailField>[] : _value(entry);
    final links =
        comic?.links.where((link) => link.isExternalLink).toList() ?? const [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _Columns(children: [
          if (creators.isNotEmpty) section('Creators', creators),
          if (characters.isNotEmpty) section('Characters', characters),
          if (details.isNotEmpty) section('Details', details),
        ]),
        _Columns(children: [
          if (personal.isNotEmpty) section('Personal', personal),
          if (value.isNotEmpty) section('Value', value),
        ]),
        if (links.isNotEmpty)
          LibraryDetailSection(title: 'Links', collapsible: false, children: [
            for (final link in links)
              InkWell(
                onTap: () => launchUrl(Uri.parse(link.url)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(link.title ?? link.url,
                      style: TextStyle(
                          fontSize: 14, color: appPalette(context).link)),
                ),
              ),
          ]),
      ]),
    );
  }
}

/// Lays sections out in as many equal columns as fit, at least 300 px each.
class _Columns extends StatelessWidget {
  const _Columns({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final perRow =
          (constraints.maxWidth / 300).floor().clamp(1, children.length);
      final width = constraints.maxWidth / perRow;
      return Wrap(children: [
        for (final child in children) SizedBox(width: width, child: child),
      ]);
    });
  }
}

LibraryDetailField _field(String label, String value,
        {ValueChanged<String>? onFilter}) =>
    LibraryDetailField(
      label: label,
      value: value,
      onTap: onFilter == null ? null : () => onFilter(value),
    );

/// Creators by role, in the reference role order, other roles after.
List<LibraryDetailField> _creatorFields(
    ComicCatalogItem? comic, ValueChanged<String>? onFilter) {
  final byRole = <String, List<String>>{};
  for (final creator in comic?.creators ?? const <ComicCreator>[]) {
    final name = creator.name?.trim() ?? '';
    if (name.isEmpty) continue;
    final role = (creator.role ?? creator.roleId ?? '').trim();
    byRole.putIfAbsent(role.isEmpty ? 'Creator' : role, () => []).add(name);
  }
  final roles = byRole.keys.toList()
    ..sort((a, b) {
      int rank(String role) {
        final index = kComicCreatorRoles
            .indexWhere((known) => known.toLowerCase() == role.toLowerCase());
        return index < 0 ? kComicCreatorRoles.length : index;
      }

      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.compareTo(b);
    });
  return [
    for (final role in roles)
      _field(role, byRole[role]!.join(' | '),
          onFilter: byRole[role]!.length == 1 ? onFilter : null),
  ];
}

List<LibraryDetailField> _characterFields(
        ComicCatalogItem? comic, ValueChanged<String>? onFilter) =>
    [
      for (final character in comic?.characters ?? const <ComicCharacter>[])
        if (character.name?.trim().isNotEmpty == true)
          _field(character.name!.trim(), character.realName?.trim() ?? ''),
    ];

List<LibraryDetailField> _detailFields(
    ComicCatalogItem? comic, ValueChanged<String>? onFilter) {
  if (comic == null) return const [];
  final rows = <(String, String?, bool)>[
    ('Age', comic.publicationAge, true),
    ('Format', comic.physicalFormat, true),
    ('Genre', comic.genres.join(' | '), comic.genres.length == 1),
    ('No. of Pages', comic.pageCount?.toString(), false),
    ('Country', comic.country, true),
    ('Language', comic.language, true),
    ('Series Group', comic.seriesGroup, true),
    ('Crossover', comic.crossover, true),
    ('Age Rating', comic.ageRating, true),
  ];
  return [
    for (final (label, value, filterable) in rows)
      if (value?.trim().isNotEmpty == true)
        _field(label, value!.trim(), onFilter: filterable ? onFilter : null),
  ];
}

List<LibraryDetailField> _personal(ComicLibraryEntry entry, DateTime? addedAt) {
  final personal = entry.personal;
  final formats = AppFormats.current;
  final status = personal.collectionStatus;
  return [
    if (status != null)
      _field('Status', libraryCollectionStatusFromValue(status).label),
    if (personal.reading.rating case final rating?)
      _field('My Rating', '$rating/10'),
    _field('Read', personal.reading.status == 'Read' ? '✓' : '✕'),
    if (personal.reading.finishedAt case final date?)
      _field('Read Date', formats.formatDate(date)),
    if (personal.indexNumber case final index?) _field('Index', '$index'),
    if (personal.quantity != 1) _field('Quantity', '${personal.quantity}'),
    if (personal.ownerLabel?.trim().isNotEmpty == true)
      _field('Owner', personal.ownerLabel!.trim()),
    if (personal.tags.isNotEmpty) _field('Tags', personal.tags.join(' | ')),
    if (personal.details.lastBagBoardDate case final date?)
      _field('Bag/Board Date', formats.formatDate(date)),
    if (personal.personalNotes?.trim().isNotEmpty == true)
      _field('Notes', personal.personalNotes!.trim()),
    if (entry.createdAt ?? addedAt case final created?)
      _field('Added Date', formats.formatDateTime(created)),
    _field('Modified Date', formats.formatDateTime(entry.updatedAt)),
  ];
}

List<LibraryDetailField> _value(ComicLibraryEntry entry) {
  final personal = entry.personal;
  final details = personal.details;
  final formats = AppFormats.current;
  String money(int cents) => formats.formatMoney(
      cents, personal.currency ?? AppFormats.current.currency);
  String? date(DateTime? value) =>
      value == null ? null : formats.formatDate(value);
  final key = [
    details.keySeverity?.trim() ?? '',
    details.keyReason?.trim() ?? '',
  ].where((value) => value.isNotEmpty).join(': ');
  final rows = <(String, String?)>[
    (
      'Cover Price',
      details.coverPriceCents == null ? null : money(details.coverPriceCents!)
    ),
    (
      'My Value',
      personal.marketValueCents == null
          ? null
          : money(personal.marketValueCents!)
    ),
    ('Key', key),
    (
      'Key Categories',
      details.keyCategory
          ?.split(';')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .join(' | ')
    ),
    ('Grade', personal.grade),
    ('Raw / Slabbed', details.rawOrSlabbed),
    ('Grading Company', details.gradingCompany),
    ('Slab Cert. No.', details.certificationNumber),
    ('Label Type', details.labelType),
    ('Custom Label', details.customLabel),
    ('Page Quality', details.pageQuality),
    ('Grader Notes', details.graderNotes),
    ('Signed by', details.signedBy),
    ('Purchase Date', date(personal.purchaseDate)),
    (
      'Purchase Price',
      personal.pricePaidCents == null ? null : money(personal.pricePaidCents!)
    ),
    ('Purchase Store', personal.purchaseStore),
    ('Sold Date', date(personal.soldAt)),
    (
      'Price Sold',
      personal.sellPriceCents == null ? null : money(personal.sellPriceCents!)
    ),
  ];
  return [
    for (final (label, value) in rows)
      if (value?.trim().isNotEmpty == true) _field(label, value!.trim()),
  ];
}
