import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/features/library/config/entry_helpers.dart';
import 'package:collectarr_app/features/library/config/item_actions.dart';
import 'package:collectarr_app/features/library/details/field_table.dart';
import 'package:collectarr_app/features/library/details/models.dart';
import 'package:collectarr_app/features/library/details/section.dart';
import 'package:collectarr_app/features/library/generic/external_links.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/kinds/book/data/book_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';
import 'package:collectarr_app/features/library/kinds/book/tracking/book_tracking_profile.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/data.dart';
import 'package:collectarr_app/features/library/ui/primitives/collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/workspace/tiles/cover_image.dart';
import 'package:collectarr_app/features/settings/ui_preferences.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'author_spotlight.dart';

BookCatalogMetadata? _metadata(LibraryProjectionView item) =>
    switch (item.source.kindPresentationData) {
      BookWorkspaceData data => data.metadata,
      _ => null,
    };

BookLibraryEntry? _entry(LibraryInspectorRequest request) =>
    BookLibraryEntryProjection.fromDispatch(request.libraryEntryDispatch ??
        request.item.source.libraryEntryDispatch);

bool _has(String? value) => value?.trim().isNotEmpty == true;

String _date(DateTime value) => AppFormats.current.formatDate(value);

/// The reference order of the Credits table.
const _creditOrder = [
  'editor',
  'translator',
  'illustrator',
  'cover artist',
  'narrator',
  'photographer',
  'foreword author',
  'ghost writer',
];

/// Credits other than the authors, in the reference's order.
List<LibraryDetailField> bookInspectorCreditFields(
  BookCatalogMetadata metadata, {
  ValueChanged<String>? onFilterByValue,
}) {
  int rank(BookCatalogCredit credit) {
    final index = _creditOrder.indexOf(credit.role?.toLowerCase() ?? '');
    return index < 0 ? _creditOrder.length : index;
  }

  final credits = [
    for (final credit in [...metadata.creators, ...metadata.contributors])
      if (credit.role?.toLowerCase() != 'author' && credit.role != null) credit,
  ];
  return [
    for (final (index, credit) in credits.indexed)
      LibraryDetailField(
        label: credit.role!,
        value: credit.name,
        priority: rank(credit) * 1000 + index,
        onTap:
            onFilterByValue == null ? null : () => onFilterByValue(credit.name),
      ),
  ];
}

/// The edition facts of the reference's Details table.
List<LibraryDetailField> bookInspectorDetailFields(
    BookCatalogMetadata metadata) {
  final fields = <LibraryDetailField>[];
  void add(String label, Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      fields.add(LibraryDetailField(
          label: label, value: text, priority: fields.length));
    }
  }

  add('Original Title', metadata.originalTitle);
  add('Original Subtitle', metadata.originalSubtitle);
  add(
      'Original Publication Date',
      metadata.originalPublicationDateParts != null
          ? AppFormats.current
              .formatPartialDate(metadata.originalPublicationDateParts)
          : formatNullableDate(metadata.originalPublicationDate));
  add('Original Country', metadata.originalCountry);
  add('Original Publication Place', metadata.originalPublicationPlace);
  add('Original Language', metadata.originalLanguage);
  add('Original Publisher', metadata.originalPublisher);
  add('Extras', metadata.extras.join(', '));
  if (metadata.audioLengthMinutes case final minutes?) {
    add('Audiobook Length',
        '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}');
  }
  if (metadata.audioAbridged case final abridged?) {
    add('Audiobook Abridged', abridged ? 'Yes' : 'No');
  }
  add('Printed By', metadata.printedBy);
  add('Number Line', metadata.numberLine);
  add('Paper Type', metadata.paperType);
  add('Printing', metadata.printingNumber);
  if (metadata.firstEdition case final first?) {
    add('First Edition', first ? 'Yes' : 'No');
  }
  return fields;
}

/// One Read History row as the reference writes it: "Yes, started Oct 01,
/// 2024, finished Oct 09, 2024 by Reader".
String bookReadEventSummary(BookReadEvent event) {
  final status = event.isFinished
      ? 'Yes'
      : BookReadEvent.statuses
              .where((item) => item.$1 == event.status)
              .firstOrNull
              ?.$2 ??
          event.status;
  final parts = [
    if (event.status.isNotEmpty) status,
    if (event.startDate case final date?) 'started ${_date(date)}',
    if (event.endDate case final date?) 'finished ${_date(date)}',
  ].join(', ');
  final pages = event.pagesRead == null || event.isFinished
      ? ''
      : ' (${event.pagesRead} pages)';
  return '$parts${_has(event.reader) ? ' by ${event.reader}' : ''}$pages'
      .trim();
}

/// The copy facts of the reference's Personal table.
List<LibraryDetailField> bookInspectorPersonalFields(
  BookLibraryEntry entry, {
  String? locationPath,
  TrackingSummary? tracking,
}) {
  final personal = entry.personal;
  final events = personal.details.readEvents;
  final trackedStatus =
      bookTrackingProfile.normalizeStorageValue(tracking?.statusStorageValue);
  final rows = <(String, String)>[
    if (_has(personal.ownerLabel)) ('Owner', personal.ownerLabel!),
    if (_has(locationPath)) ('Location', locationPath!),
    if (events.isNotEmpty)
      (
        'Read',
        [for (final event in events) bookReadEventSummary(event)].join('\n')
      )
    else if (tracking != null && _has(trackedStatus))
      (
        'Read',
        bookReadEventSummary(BookReadEvent(
            status: trackedStatus!,
            startDate: tracking.startedAt,
            endDate: tracking.completedAt))
      ),
    if (personal.quantity != 1) ('Quantity', '${personal.quantity}'),
    ('Index', personal.indexNumber?.toString() ?? ''),
    if (entry.createdAt case final created?)
      ('Added Date', AppFormats.current.formatDateTime(created)),
    ('Modified Date', AppFormats.current.formatDateTime(entry.updatedAt)),
  ];
  return [
    for (final (index, row) in rows.indexed)
      LibraryDetailField(label: row.$1, value: row.$2, priority: index),
  ];
}

/// The prices and condition of the reference's Value table.
List<LibraryDetailField> bookInspectorValueFields(BookLibraryEntry entry) {
  final personal = entry.personal;
  final details = personal.details;
  String money(int? cents) => AppFormats.current
      .formatMoney(cents, personal.currency ?? AppFormats.current.currency);
  final purchased = [
    if (personal.purchaseDate case final date?) _date(date),
    if (_has(personal.purchaseStore)) 'at ${personal.purchaseStore}',
    if (personal.pricePaidCents case final paid?) 'for ${money(paid)}',
  ].join(' ');
  final sold = [
    if (personal.soldAt case final date?) _date(date),
    if (_has(personal.soldTo)) 'to ${personal.soldTo}',
    if (personal.sellPriceCents case final price?) 'for ${money(price)}',
  ].join(' ');
  final rows = <(String, String)>[
    if (details.retailPriceCents case final price?)
      ('Retail Price', money(price)),
    if (personal.marketValueCents case final value?) ('Value', money(value)),
    if (purchased.isNotEmpty) ('Purchased', purchased),
    if (sold.isNotEmpty) ('Sold', sold),
    if (_has(personal.condition)) ('Book Condition', personal.condition!),
    if (details.dustJacketPresent) ('Dust Jacket', 'Yes'),
    if (_has(details.dustJacketCondition))
      ('Dust Jacket Condition', details.dustJacketCondition!),
    if (details.signedBy.isNotEmpty) ('Signed by', details.signedBy.join(', ')),
  ];
  return [
    for (final (index, row) in rows.indexed)
      LibraryDetailField(label: row.$1, value: row.$2, priority: index),
  ];
}

Widget buildBookInspectorHero(
        BuildContext context, LibraryInspectorRequest request) =>
    _BookInspectorHeader(request: request);

/// Reference details below the header: Plot, then Credits beside Details,
/// Personal beside Value, Notes beside Tags, and Links.
List<Widget> buildBookInspectorSections(
    BuildContext context, LibraryInspectorRequest request) {
  final metadata = _metadata(request.item);
  if (metadata == null) return const [];
  final entry = _entry(request);
  final palette = appPalette(context);
  Widget section(String title, Widget child) =>
      LibraryDetailSection(title: title, collapsible: false, children: [child]);
  Widget? table(String title, List<LibraryDetailField> fields,
          {required double labelWidth}) =>
      fields.isEmpty
          ? null
          : section(
              title,
              LibraryDetailFieldTable(
                  minCellWidth: 4000,
                  labelWidth: labelWidth,
                  showHeader: false,
                  fields: fields));
  final plot = (metadata.description ??
          metadata.synopsis ??
          metadata.plotDescription ??
          metadata.plotSummary ??
          '')
      .trim();
  final links = [
    for (final link in metadata.externalLinks)
      if (link.url.trim().isNotEmpty) link,
  ];
  final personal = entry?.personal;
  return [
    if (plot.isNotEmpty)
      section(
          'Plot',
          AppFormattedText(plot,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 14, height: 18 / 14))),
    _SectionPair(
      table(
          'Credits',
          bookInspectorCreditFields(metadata,
              onFilterByValue: request.onFilterByValue),
          labelWidth: 118),
      table('Details', bookInspectorDetailFields(metadata), labelWidth: 178),
    ),
    if (entry != null)
      _SectionPair(
        table(
            'Personal',
            bookInspectorPersonalFields(entry,
                locationPath: request.item.source.locationPath,
                tracking: request.trackingSummary ??
                    request.item.source.trackingSummary),
            labelWidth: 102),
        table('Value', bookInspectorValueFields(entry), labelWidth: 155),
      ),
    if (personal != null)
      _SectionPair(
        _has(personal.personalNotes)
            ? section(
                'Notes',
                AppFormattedText(personal.personalNotes!,
                    style: const TextStyle(fontSize: 14, height: 18 / 14)))
            : null,
        personal.tags.isEmpty
            ? null
            : section(
                'Tags',
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final tag in personal.tags)
                    _FilterLink(
                      value: tag,
                      onFilter: request.onFilterByValue,
                      builder: (text) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.badgeBackground,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: text,
                      ),
                      style:
                          TextStyle(fontSize: 14, color: palette.textPrimary),
                    ),
                ])),
      ),
    if (links.isNotEmpty)
      section(
          'Links',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final link in links)
              InkWell(
                onTap: () => launchUrl(Uri.parse(link.url)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                      link.description ?? link.title ?? link.label ?? link.url,
                      style: TextStyle(fontSize: 14, color: palette.link)),
                ),
              ),
          ])),
  ];
}

/// Two sections side by side once both fit, as in the reference.
class _SectionPair extends StatelessWidget {
  const _SectionPair(this.left, this.right);

  final Widget? left;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    final left = this.left;
    final right = this.right;
    if (left == null && right == null) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 640) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [if (left != null) left, if (right != null) right]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: left ?? const SizedBox.shrink()),
        Expanded(child: right ?? const SizedBox.shrink()),
      ]);
    });
  }
}

class _BookInspectorHeader extends StatelessWidget {
  const _BookInspectorHeader({required this.request});

  final LibraryInspectorRequest request;

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final item = request.item;
    final metadata = _metadata(item);
    if (metadata == null) return const SizedBox.shrink();
    final entry = _entry(request);
    final personal = entry?.personal;
    final onFilter = request.onFilterByValue;
    final author =
        buildBookAuthorSpotlight(item: item, onFilterByValue: onFilter);
    final year = metadata.releaseDateParts?.year ?? metadata.releaseDate?.year;
    final position = [
      if (_has(metadata.volumeName)) 'vol. ${metadata.volumeName}',
      if (_has(metadata.itemNumber)) 'Issue #${metadata.itemNumber}',
    ].join(', ');
    final dimensions = [
      metadata.widthMm,
      metadata.heightMm,
      metadata.spineThicknessMm
    ];
    final facts = [
      if (metadata.pageCount != null) '${metadata.pageCount} pages',
      if (dimensions.every((value) => value != null))
        '${dimensions.join(' x ')} mm',
      if (metadata.weightGrams != null) '${metadata.weightGrams} g',
      if (_has(metadata.country)) metadata.country!,
      if (_has(metadata.language)) metadata.language!,
    ].join(' | ');
    final isbn = metadata.isbn ?? metadata.barcode;
    final rating = request.trackingSummary?.rating ?? 0;
    final collectionStatus = libraryCollectionStatusFromValue(
      personal?.collectionStatus ??
          (item.source.isWishlisted ? 'Wish List' : 'In Collection'),
    );
    final hasStatus = entry != null || item.source.isWishlisted;
    const bold = TextStyle(fontSize: 15, fontWeight: kAppBoldFontWeight);
    final body = TextStyle(fontSize: 14, color: palette.textPrimary);
    Widget link(String value, {String? filterValue, TextStyle? style}) =>
        _FilterLink(
            value: value,
            filterValue: filterValue,
            onFilter: onFilter,
            style: (style ?? bold).copyWith(color: palette.textPrimary));
    Widget classification(String label, String type) {
      final value = metadata.identifiers
          .where((identifier) => identifier.identifierType == type)
          .firstOrNull
          ?.value;
      if (!_has(value)) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // The reference's small capitals: capitals at 70 %.
              Text(label.toUpperCase(),
                  style: TextStyle(fontSize: 9.8, color: palette.textMuted)),
              const SizedBox(width: 8),
              Flexible(child: Text(value!, style: body)),
            ]),
      );
    }

    Widget values(String title, List<String> items) => Padding(
          padding: const EdgeInsets.only(top: 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: bold.copyWith(color: palette.detailHeading)),
            for (final value in items)
              if (value.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('•  ', style: body),
                    Flexible(child: link(value, style: body)),
                  ]),
                ),
          ]),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_has(metadata.boxSet))
          _BookBoxSet(
              name: metadata.boxSet!,
              currentId: entry?.id.value,
              onFilter: onFilter),
        if (author != null) ...[author, const SizedBox(height: 10)],
        if (_has(metadata.seriesTitle) || position.isNotEmpty)
          Wrap(children: [
            if (_has(metadata.seriesTitle)) link(metadata.seriesTitle!),
            if (_has(metadata.seriesTitle) && position.isNotEmpty)
              Text(': ', style: bold.copyWith(color: palette.textPrimary)),
            if (position.isNotEmpty)
              Text(position, style: bold.copyWith(color: palette.textPrimary)),
          ]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(metadata.title,
                style: TextStyle(
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: kAppBoldFontWeight,
                    color: palette.detailHeading)),
          ),
          if (personal != null && personal.quantity != 1)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Text('Qty: ${personal.quantity}',
                  style: bold.copyWith(color: palette.textPrimary)),
            ),
          if (hasStatus)
            Tooltip(
              message: collectionStatus.label,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 12, top: 2),
                decoration: BoxDecoration(
                  color: collectionStatus.color,
                  borderRadius: BorderRadius.circular(3),
                ),
                child:
                    Icon(collectionStatus.icon, size: 18, color: Colors.white),
              ),
            ),
        ]),
        if (_has(metadata.subtitle))
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(metadata.subtitle!,
                style: TextStyle(fontSize: 16, color: palette.textMuted)),
          ),
        const SizedBox(height: 10),
        // Details sit beside the covers once both fit, as in the reference.
        LayoutBuilder(builder: (context, constraints) {
          final covers = _BookCovers(
              key: ValueKey(item.target.stableKey),
              request: request,
              sideBySide: constraints.maxWidth >= 640);
          final details =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_has(metadata.publisher) ||
                _has(metadata.publicationPlace) ||
                year != null)
              Wrap(children: [
                if (_has(metadata.publisher)) link(metadata.publisher!),
                if (_has(metadata.publicationPlace) || year != null)
                  Text(' (', style: bold.copyWith(color: palette.textPrimary)),
                if (_has(metadata.publicationPlace))
                  link(metadata.publicationPlace!),
                if (_has(metadata.publicationPlace) && year != null)
                  Text(', ', style: bold.copyWith(color: palette.textPrimary)),
                if (year != null) link('$year'),
                if (_has(metadata.publicationPlace) || year != null)
                  Text(')', style: bold.copyWith(color: palette.textPrimary)),
              ]),
            if (rating > 0)
              Container(
                margin: const EdgeInsets.only(top: 15),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFF0082A6),
                    borderRadius: BorderRadius.circular(3)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star, size: 22, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('$rating',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: kAppBoldFontWeight,
                          color: Colors.white)),
                ]),
              ),
            if (_has(metadata.editionStatement))
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(metadata.editionStatement!,
                    style: bold.copyWith(color: palette.textPrimary)),
              ),
            const SizedBox(height: 4),
            if (_has(isbn) || _has(metadata.physicalFormat))
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (_has(isbn)) ...[
                  Icon(AppIcons.barcode, size: 14, color: palette.textPrimary),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                      [
                        if (_has(isbn)) isbn!,
                        if (_has(metadata.physicalFormat))
                          metadata.physicalFormat!,
                      ].join(' | '),
                      style: body),
                ),
              ]),
            if (facts.isNotEmpty) Text(facts, style: body),
            if (personal?.details.retailPriceCents != null ||
                personal?.marketValueCents != null)
              Text(
                  [
                    if (personal?.details.retailPriceCents case final price?)
                      AppFormats.current.formatMoney(price,
                          personal?.currency ?? AppFormats.current.currency),
                    if (personal?.marketValueCents case final value?)
                      'Value: ${AppFormats.current.formatMoney(value, personal?.currency ?? AppFormats.current.currency)}',
                  ].join(' | '),
                  style: body),
            _BookEbayLink(
                query: [
                  metadata.title,
                  if (_has(isbn)) isbn!,
                ].join(' '),
                isWishlisted: item.source.isWishlisted),
            const SizedBox(height: 18),
            classification('Dewey', 'dewey'),
            classification('LC Classification', 'lcc'),
            classification('LC Control No.', 'lccn'),
            if (metadata.genres.isNotEmpty) values('Genre', metadata.genres),
            if (metadata.subjects.isNotEmpty)
              values('Subject', metadata.subjects),
          ]);
          if (constraints.maxWidth < 440) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [covers, const SizedBox(height: 12), details]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            covers,
            const SizedBox(width: 20),
            Expanded(child: details),
          ]);
        }),
      ]),
    );
  }
}

/// The reference's box set block: its name over the set's books, each with
/// its place in the set and its year.
class _BookBoxSet extends ConsumerWidget {
  const _BookBoxSet(
      {required this.name, required this.currentId, required this.onFilter});

  final String name;
  final String? currentId;
  final ValueChanged<String>? onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final body = TextStyle(fontSize: 14, color: palette.textPrimary);
    return FutureBuilder<List<BookLibraryEntry>>(
      future:
          BookEntryRepository(ref.watch(localDatabaseProvider)).listActive(),
      builder: (context, snapshot) {
        int year(BookLibraryEntry book) =>
            book.metadata.releaseDateParts?.year ??
            book.metadata.releaseDate?.year ??
            0;
        final books = [
          for (final book in snapshot.data ?? const <BookLibraryEntry>[])
            if (book.metadata.boxSet == name) book,
        ]..sort((a, b) {
            final byYear = year(a).compareTo(year(b));
            return byYear != 0
                ? byYear
                : a.metadata.title.compareTo(b.metadata.title);
          });
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(name,
                style: TextStyle(
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: kAppBoldFontWeight,
                    color: palette.detailHeading)),
            const SizedBox(height: 9),
            for (final (index, book) in books.indexed)
              Container(
                height: 29,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: palette.detailRule),
                        bottom: index == books.length - 1
                            ? BorderSide(color: palette.detailRule)
                            : BorderSide.none)),
                child: Row(children: [
                  SizedBox(width: 18, child: Text('${index + 1}', style: body)),
                  Expanded(
                    child: _FilterLink(
                        value: book.metadata.title,
                        onFilter: onFilter,
                        style: body.copyWith(
                            color: palette.link,
                            fontWeight: book.id.value == currentId
                                ? kAppBoldFontWeight
                                : null)),
                  ),
                  if (year(book) > 0) Text('${year(book)}', style: body),
                ]),
              ),
            const SizedBox(height: 24),
            Divider(height: 1, color: palette.detailRule),
          ]),
        );
      },
    );
  }
}

/// Front and back cover side by side, or one above the other when narrow.
class _BookCovers extends ConsumerWidget {
  const _BookCovers(
      {super.key, required this.request, required this.sideBySide});

  final LibraryInspectorRequest request;
  final bool sideBySide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = request.item;
    final metadata = _metadata(item)!;
    final showBack = ref
        .watch(uiPreferencesProvider.select((p) => p.showInspectorBackCover));
    final hasBack = showBack &&
        (_has(metadata.backCoverImageUrl) ||
            item.source.personal.imageTypes.contains('back_cover'));
    Widget cover({required bool back}) => SizedBox(
          width: 210,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: LibraryCoverImage(
              title: metadata.title,
              mediaKind: CatalogMediaKind.book,
              imageUrl: back
                  ? metadata.backCoverImageUrl
                  : metadata.coverImageUrl ?? metadata.thumbnailImageUrl,
              libraryEntryRef:
                  resolveLibraryEntrySummaryRef(item, request.libraryEntry),
              localImageType: back ? 'back_cover' : 'front_cover',
              borderRadius: 0,
            ),
          ),
        );
    final covers = [cover(back: false), if (hasBack) cover(back: true)];
    return sideBySide
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            for (final (index, cover) in covers.indexed) ...[
              if (index > 0) const SizedBox(width: 10),
              cover,
            ],
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: [
            for (final (index, cover) in covers.indexed) ...[
              if (index > 0) const SizedBox(height: 10),
              cover,
            ],
          ]);
  }
}

/// The reference's eBay link beside the cover.
class _BookEbayLink extends ConsumerWidget {
  const _BookEbayLink({required this.query, required this.isWishlisted});

  final String query;
  final bool isWishlisted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(uiPreferencesProvider);
    if (!preferences.ebayNextToCover ||
        !preferences.allowsEbayLinks(isWishlisted) ||
        query.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: () => launchEbaySearch(query, isWishlisted: isWishlisted),
        child: Text('Find sold listings on eBay',
            style: TextStyle(
                fontSize: 15,
                color: appPalette(context).link,
                decoration: TextDecoration.underline,
                decorationColor: appPalette(context).link)),
      ),
    );
  }
}

class _FilterLink extends StatelessWidget {
  const _FilterLink(
      {required this.value,
      this.filterValue,
      required this.onFilter,
      required this.style,
      this.builder});

  final String value;
  final String? filterValue;
  final ValueChanged<String>? onFilter;
  final TextStyle style;
  final Widget Function(Widget text)? builder;

  @override
  Widget build(BuildContext context) {
    final text = Text(value, style: style);
    return MouseRegion(
      cursor: onFilter == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onFilter == null ? null : () => onFilter!(filterValue ?? value),
        child: builder?.call(text) ?? text,
      ),
    );
  }
}
