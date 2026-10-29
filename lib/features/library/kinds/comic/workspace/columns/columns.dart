import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/core/utils/natural_text_compare.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/catalog_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/collection_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/entry_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/facets.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

typedef _Catalog = ComicCatalogItemWorkspaceFields;
typedef _Entry = ComicLibraryEntryWorkspaceFields;
typedef _Collection = ComicCollectionWorkspaceFields;
typedef _Column
    = LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, Object?>;
typedef _Field = LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, Object?>;

/// Columns of a collection's comics, grouped and labelled as in the reference
/// Comics column chooser: Images, Main, Value, Edition, Creators & Characters,
/// Personal and Loan. Dates, numbers and money align right.
final List<LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, Object?>>
    comicCollectionWorkspaceColumns = [
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: _Catalog.cover.id,
    metadata: _Catalog.cover.metadata,
    getValue: _Catalog.cover.getValue,
    cellValue: (context) => context.dto.coverImageUrl == null
        ? const SizedBox.shrink()
        : Image.network(context.dto.coverImageUrl!,
            width: 32, height: 32, fit: BoxFit.cover),
    group: 'Images',
    displayName: 'Front Cover',
    allowSortInteraction: false,
    allowGroupInteraction: false,
    defaultWidth: 42,
    minWidth: 44,
  ),
  // Main
  _text(_Collection.age, 'Main', 110),
  _text(_Collection.country, 'Main', 90),
  _text(_Collection.crossover, 'Main', 140),
  _text(_Collection.fullTitle, 'Main', 280),
  _list(comicSmartListFacetFields[1], 'Genre', 'Main'),
  _text(_Catalog.imprint, 'Main', 120),
  _text(_Collection.issue, 'Main', 70, numeric: true),
  _text(_Catalog.issueNumber, 'Main', 70, numeric: true),
  _text(_Collection.language, 'Main', 90),
  _text(_Catalog.publisher, 'Main', 140),
  _partialDate(_Collection.releaseDate, 'Main'),
  _number(_Collection.releaseYear, 'Main'),
  _text(_Catalog.series, 'Main', 220, maxWidth: 520),
  _text(_Collection.seriesGroup, 'Main', 130),
  _list(comicSmartListFacetFields[2], 'Story Arc', 'Main'),
  _text(_Collection.subtitle, 'Main', 160),
  _text(_Catalog.title, 'Main', 220, maxWidth: 520),
  _text(_Catalog.variant, 'Main', 70),
  // Value
  _money(_Entry.coverPrice, 'Cover Price'),
  _text(_Entry.customLabel, 'Value', 120, label: 'Custom Label'),
  _text(_Entry.grade, 'Value', 70, label: 'Grade'),
  _text(_Entry.graderNotes, 'Value', 160, label: 'Grader Notes'),
  _text(_Entry.gradingCompany, 'Value', 120, label: 'Grading Company'),
  _text(_Entry.keySeverity, 'Value', 80, label: 'Key'),
  _text(_Entry.keyCategory, 'Value', 160, label: 'Key Category'),
  _text(_Entry.keyReason, 'Value', 200, label: 'Key Reason'),
  _text(_Entry.labelType, 'Value', 110, label: 'Label Type'),
  _money(_Collection.myValue, 'My Value'),
  _text(_Entry.pageQuality, 'Value', 120, label: 'Page Quality'),
  _money(_Collection.priceSold, 'Price Sold'),
  _partialDate(_Collection.purchaseDate, 'Value'),
  _money(_Entry.pricePaid, 'Purchase Price'),
  _text(_Collection.purchaseStore, 'Value', 130),
  _text(_Entry.rawOrSlabbed, 'Value', 100, label: 'Raw / Slabbed'),
  _text(_Entry.signedBy, 'Value', 130, label: 'Signed by'),
  _text(_Entry.certificationNumber, 'Value', 140,
      label: 'Slab Certification Number'),
  _partialDate(_Collection.soldDate, 'Value'),
  // Edition
  _text(_Catalog.barcode, 'Edition', 150, maxWidth: 260),
  _partialDate(_Collection.coverDate, 'Edition'),
  _number(_Collection.coverYear, 'Edition'),
  _text(_Collection.format, 'Edition', 120),
  _number(_Catalog.pageCount, 'Edition', label: 'No. of Pages'),
  _text(_Collection.variantDescription, 'Edition', 160),
  // Creators & Characters
  _list(comicSmartListFacetFields[0], 'Characters', _people),
  _text(_Collection.creators, _people, 200),
  for (final field in _Collection.creatorRoles) _text(field, _people, 130),
  // Personal
  _date(_Entry.addedAt, 'Added Date'),
  _date(_Entry.lastBagBoardDate, 'Bag/Board Date'),
  _text(_Collection.collectionStatus, 'Personal', 120),
  _number(_Collection.index, 'Personal'),
  _date(_Entry.updatedAt, 'Modified Date'),
  _number(_Entry.rating, 'Personal', label: 'My Rating'),
  _text(_Collection.notes, 'Personal', 200),
  _text(_Collection.owner, 'Personal', 120),
  _text(_Collection.plot, 'Personal', 240),
  _number(_Collection.quantity, 'Personal'),
  _text(_Collection.read, 'Personal', 60),
  _partialDate(_Collection.readDate, 'Personal'),
  _text(_Entry.location, 'Personal', 120, label: 'Storage Box'),
  _text(_Collection.tags, 'Personal', 150),
  // Loan
  _text(_Collection.loanedTo, 'Loan', 130),
  _partialDate(_Collection.loanDate, 'Loan'),
  _partialDate(_Collection.dueDate, 'Loan'),
];

/// One sort per sortable column, labelled and grouped like it. Text sorts
/// compare digit runs by value, so issue 2 comes before 15.
final List<LibrarySortDefinition<ComicKind, ComicWorkspaceDto>>
    comicCollectionWorkspaceSorts = [
  for (final column in comicCollectionWorkspaceColumns)
    if (column.sortable)
      LibrarySortDefinition<ComicKind, ComicWorkspaceDto>(
        id: LibrarySortId(column.id.value),
        label: column.resolvedDisplayName,
        group: column.group,
        compare: (left, right) =>
            _compare(column.getValue(left), column.getValue(right)),
      ),
];

/// Fields behind the collection columns, for filters and smart lists.
final List<LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, Object?>>
    comicCollectionWorkspaceFieldDefinitions = [
  ..._Collection.all,
  _Catalog.cover,
  _Catalog.imprint,
  _Catalog.issueNumber,
  _Catalog.publisher,
  _Catalog.series,
  _Catalog.title,
  _Catalog.variant,
  _Catalog.barcode,
  _Catalog.pageCount,
  _Catalog.writer,
  _Catalog.artist,
  _Catalog.coverArtist,
  ...comicLibraryEntryWorkspaceFieldDefinitions,
  _Entry.keySeverity,
  _Entry.graderNotes,
  _Entry.labelType,
  _Entry.customLabel,
  _Entry.pageQuality,
  _Entry.certificationNumber,
  _Entry.coverPrice,
  _Entry.lastBagBoardDate,
];

const _people = 'Creators & Characters';

int _compare(Object? a, Object? b) {
  if (a is Iterable) a = a.join(' | ');
  if (b is Iterable) b = b.join(' | ');
  if (a == null || a == '') return b == null || b == '' ? 0 : 1;
  if (b == null || b == '') return -1;
  if (a is String && b is String) return compareNaturalText(a, b);
  if (a is bool && b is bool) return a == b ? 0 : (a ? -1 : 1);
  if (a is Comparable && b is Comparable) return a.compareTo(b);
  return 0;
}

typedef _Context = LibraryProjectionContext<ComicWorkspaceDto>;

/// The text a column shows, shared by its list cell and the exports.
final _columnText = Expando<String Function(_Context)>('comic column text');

/// The text [column] shows for [context], as the list cell and exports
/// render it.
String comicCollectionColumnText(
  LibraryColumnDefinition<ComicKind, ComicWorkspaceDto, Object?> column,
  LibraryProjectionContext<ComicWorkspaceDto> context,
) =>
    (_columnText[column] ??
        (context) => '${column.getValue(context) ?? ''}')(context);

_Column _column(
  _Field field,
  String Function(_Context context) text, {
  required String group,
  String? label,
  bool numeric = false,
  required double width,
  double? maxWidth,
}) {
  final column = columnFromField<ComicKind, ComicWorkspaceDto, Object?>(
    field,
    cellValue: (context) => Text(text(context)),
    group: group,
    displayName: label,
    isNumeric: numeric,
    defaultWidth: width,
    maxWidth: maxWidth,
  );
  _columnText[column] = text;
  return column;
}

_Column _text<V>(
  LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, V> field,
  String group,
  double width, {
  String? label,
  bool numeric = false,
  double? maxWidth,
}) =>
    _column(_erase(field), (context) => '${field.getValue(context) ?? ''}',
        group: group,
        label: label,
        numeric: numeric,
        width: width,
        maxWidth: maxWidth);

_Column _list(_Field field, String label, String group) => _column(
    field,
    (context) =>
        (field.getValue(context) as Iterable<String>? ?? const []).join(' | '),
    group: group,
    label: label,
    width: 160);

_Column _partialDate(
  LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?> field,
  String group,
) =>
    _column(
        _erase(field),
        (context) => AppFormats.current
            .formatPartialDate(PartialDate.tryParse(field.getValue(context))),
        group: group,
        numeric: true,
        width: 110);

_Column _date(
  LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, DateTime?> field,
  String label,
) =>
    _column(
        _erase(field),
        (context) => switch (field.getValue(context)) {
              final value? => AppFormats.current.formatDate(value),
              null => '',
            },
        group: 'Personal',
        label: label,
        numeric: true,
        width: 112);

_Column _number<V extends num?>(
  LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, V> field,
  String group, {
  String? label,
}) =>
    _column(_erase(field), (context) => '${field.getValue(context) ?? ''}',
        group: group, label: label, numeric: true, width: 80);

_Column _money(
  LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?> field,
  String label,
) =>
    _column(
        _erase(field),
        (context) => switch (field.getValue(context)) {
              final cents? => AppFormats.current.formatMoney(
                  cents,
                  context.dto.libraryEntry?.personal.currency ??
                      context.dto.currency),
              null => '',
            },
        group: 'Value',
        label: label,
        numeric: true,
        width: 96);

_Field _erase<V>(
        LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, V> field) =>
    LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, Object?>(
      id: LibraryFieldId(field.id.value),
      metadata: field.metadata,
      getValue: field.getValue,
      cellValue: switch (field.cellValue) {
        final cell? => (value) => cell(value as V),
        null => null,
      },
    );
