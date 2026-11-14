import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/features/library/config/kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';
import 'package:collectarr_app/features/library/workspace/config/typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';
import 'package:flutter/material.dart';

import 'dto.dart';

typedef _Context = LibraryProjectionContext<BookWorkspaceDto>;
typedef _Field<V> = LibraryFieldDefinition<BookKind, BookWorkspaceDto, V>;

BookLibraryEntry? _entry(_Context context) {
  final entry = BookLibraryEntryProjection.fromDispatch(
      context.item.libraryEntryDispatch);
  return entry is BookLibraryEntry ? entry : null;
}

BookCatalogMetadata _book(_Context context) => context.dto.metadata;

String? _text(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();

String? _joined(Iterable<String> values) => _text(values.join(', '));

String? _role(_Context context, String role) => _joined([
      for (final credit in [
        ..._book(context).creators,
        ..._book(context).contributors
      ])
        if (credit.role?.toLowerCase() == role) credit.name,
    ]);

String? _identifier(_Context context, String type) => _text(_book(context)
    .identifiers
    .where((identifier) => identifier.identifierType == type)
    .firstOrNull
    ?.value);

String? _yesNo(bool? value) => value == null ? null : (value ? 'Yes' : 'No');

String _hoursAndMinutes(num minutes) {
  final total = minutes.toInt();
  final hours = (total ~/ 60).toString().padLeft(2, '0');
  final rest = (total % 60).toString().padLeft(2, '0');
  return '$hours:$rest';
}

/// One reference field chooser entry beyond the default columns: its field,
/// its List column and its sort.
final class BookAdditionalWorkspaceField {
  const BookAdditionalWorkspaceField(this.field, this.column, this.sort);
  final LibraryFieldDefinition<BookKind, BookWorkspaceDto, dynamic> field;
  final LibraryColumnDefinition<BookKind, BookWorkspaceDto, dynamic> column;
  final LibrarySortDefinition<BookKind, BookWorkspaceDto> sort;
}

LibraryKindFieldMetadata _metadata(String id, String label, String path,
        LibraryFieldValueType type, bool personal) =>
    LibraryKindFieldMetadata(
        id: id,
        label: label,
        valueType: type,
        cardinality: LibraryFieldCardinality.one,
        source: personal
            ? LibraryFieldSource.libraryEntry
            : LibraryFieldSource.catalog,
        sourcePath: path,
        sortable: true,
        groupable: type == LibraryFieldValueType.text);

BookAdditionalWorkspaceField _textField(
    String key, String label, String group, String? Function(_Context) read,
    {bool personal = false, double width = 150}) {
  final id = 'book.$key';
  final field = _Field<String?>(
      id: LibraryFieldId<BookKind, String?>(id),
      metadata: _metadata(id, label, key, LibraryFieldValueType.text, personal),
      getValue: read);
  return BookAdditionalWorkspaceField(
      field,
      columnFromField<BookKind, BookWorkspaceDto, String?>(field,
          group: group, defaultWidth: width),
      sortFromField<BookKind, BookWorkspaceDto, String>(field, group: group));
}

BookAdditionalWorkspaceField _numberField(
    String key, String label, String group, num? Function(_Context) read,
    {bool personal = false, String Function(num value)? format}) {
  final id = 'book.$key';
  final field = _Field<num?>(
      id: LibraryFieldId<BookKind, num?>(id),
      metadata:
          _metadata(id, label, key, LibraryFieldValueType.number, personal),
      getValue: read);
  return BookAdditionalWorkspaceField(
      field,
      columnFromField<BookKind, BookWorkspaceDto, num?>(field,
          group: group,
          isNumeric: true,
          defaultWidth: 90, cellValue: (context) {
        final value = read(context);
        return Text(
            value == null ? '' : format?.call(value) ?? value.toString());
      }),
      sortFromField<BookKind, BookWorkspaceDto, num>(field, group: group));
}

BookAdditionalWorkspaceField _moneyField(
        String key, String label, int? Function(_Context) read) =>
    _numberField(key, label, 'Value', read,
        personal: true,
        format: (value) => AppFormats.current
            .formatMoney(value.toInt(), AppFormats.current.currency));

BookAdditionalWorkspaceField _dateField(
    String key, String label, String group, DateTime? Function(_Context) read,
    {bool personal = false, bool withTime = false}) {
  final id = 'book.$key';
  final field = _Field<DateTime?>(
      id: LibraryFieldId<BookKind, DateTime?>(id),
      metadata: _metadata(id, label, key, LibraryFieldValueType.date, personal),
      getValue: read);
  return BookAdditionalWorkspaceField(
      field,
      columnFromField<BookKind, BookWorkspaceDto, DateTime?>(field,
          group: group,
          defaultWidth: withTime ? 160 : 110, cellValue: (context) {
        final value = read(context);
        return Text(value == null
            ? ''
            : withTime
                ? AppFormats.current.formatDateTime(value)
                : AppFormats.current.formatDate(value));
      }),
      sortFromField<BookKind, BookWorkspaceDto, DateTime>(field, group: group));
}

DateTime? _lastRead(_Context context) {
  final dates = <DateTime>[
    for (final event in _entry(context)?.personal.details.readEvents ??
        const <BookReadEvent>[])
      if (event.endDate case final date?) date,
  ]..sort();
  return dates.lastOrNull;
}

/// The reference's field chooser entries that are not default columns, in
/// its Images, Main, Value, Edition, Credits, Categorization and Personal
/// groups.
final bookAdditionalWorkspaceFields = <BookAdditionalWorkspaceField>[
  _textField(
      'has_front_cover',
      'Has Front',
      'Images',
      (c) => _yesNo(_text(_book(c).coverImageUrl) != null ||
          c.personal.imageTypes.contains('front_cover')),
      width: 90),
  _textField(
      'has_back_cover',
      'Has Back',
      'Images',
      (c) => _yesNo(_text(_book(c).backCoverImageUrl) != null ||
          c.personal.imageTypes.contains('back_cover')),
      width: 90),
  _textField('core_book_id', 'Core BookID', 'Main',
      (c) => _text(_entry(c)?.sourceCatalogRef?.id)),
  _textField('country', 'Country', 'Main', (c) => _text(_book(c).country)),
  _textField('language', 'Language', 'Main', (c) => _text(_book(c).language)),
  _textField(
      'number_line', 'Number Line', 'Main', (c) => _text(_book(c).numberLine)),
  _textField('publication_place', 'Publication Place', 'Main',
      (c) => _text(_book(c).publicationPlace)),
  _numberField('publication_year', 'Publication Year', 'Main',
      (c) => _book(c).releaseDateParts?.year ?? _book(c).releaseDate?.year),
  _textField(
      'sort_title', 'Sort Title', 'Main', (c) => _text(_book(c).sortTitle),
      width: 250),
  _textField('dust_jacket_condition', 'Dust Jacket Condition', 'Value',
      (c) => _text(_entry(c)?.personal.details.dustJacketCondition),
      personal: true),
  _moneyField(
      'my_value', 'My Value', (c) => _entry(c)?.personal.marketValueCents),
  _dateField('purchase_date', 'Purchase Date', 'Value',
      (c) => _entry(c)?.personal.purchaseDate,
      personal: true),
  _textField('purchase_store', 'Purchase Store', 'Value',
      (c) => _text(_entry(c)?.personal.purchaseStore),
      personal: true),
  _numberField('purchase_year', 'Purchase Year', 'Value',
      (c) => _entry(c)?.personal.purchaseDate?.year,
      personal: true),
  _moneyField('retail_price', 'Retail Price',
      (c) => _entry(c)?.personal.details.retailPriceCents),
  _dateField(
      'sold_date', 'Sold Date', 'Value', (c) => _entry(c)?.personal.soldAt,
      personal: true),
  _moneyField(
      'sold_price', 'Sold Price', (c) => _entry(c)?.personal.sellPriceCents),
  _numberField('sold_year', 'Sold Year', 'Value',
      (c) => _entry(c)?.personal.soldAt?.year,
      personal: true),
  _textField('audiobook_abridged', 'Audiobook Abridged', 'Edition',
      (c) => _yesNo(_book(c).audioAbridged),
      width: 90),
  _numberField('audiobook_length', 'Audiobook Length', 'Edition',
      (c) => _book(c).audioLengthMinutes,
      format: _hoursAndMinutes),
  _textField('box_set', 'Box Set', 'Edition', (c) => _text(_book(c).boxSet)),
  _textField(
      'edition', 'Edition', 'Edition', (c) => _text(_book(c).editionStatement)),
  _textField('extras', 'Extras', 'Edition', (c) => _joined(_book(c).extras)),
  _textField('first_edition', 'First Edition', 'Edition',
      (c) => _yesNo(_book(c).firstEdition),
      width: 90),
  _numberField('height', 'Height', 'Edition', (c) => _book(c).heightMm),
  _textField('issue', 'Issue', 'Edition', (c) => _text(_book(c).itemNumber),
      width: 90),
  _textField('narrator', 'Narrator', 'Edition', (c) => _role(c, 'narrator')),
  _textField('original_country', 'Original Country', 'Edition',
      (c) => _text(_book(c).originalCountry)),
  _textField('original_language', 'Original Language', 'Edition',
      (c) => _text(_book(c).originalLanguage)),
  _dateField(
      'original_publication_date',
      'Original Publication Date',
      'Edition',
      (c) =>
          _book(c).originalPublicationDateParts?.asDateTime ??
          _book(c).originalPublicationDate),
  _textField('original_publication_place', 'Original Publication Place',
      'Edition', (c) => _text(_book(c).originalPublicationPlace)),
  _numberField(
      'original_publication_year',
      'Original Publication Year',
      'Edition',
      (c) =>
          _book(c).originalPublicationDateParts?.year ??
          _book(c).originalPublicationDate?.year),
  _textField('original_publisher', 'Original Publisher', 'Edition',
      (c) => _text(_book(c).originalPublisher)),
  _textField('original_subtitle', 'Original Subtitle', 'Edition',
      (c) => _text(_book(c).originalSubtitle)),
  _textField('original_title', 'Original Title', 'Edition',
      (c) => _text(_book(c).originalTitle),
      width: 250),
  _textField(
      'paper_type', 'Paper Type', 'Edition', (c) => _text(_book(c).paperType)),
  _textField(
      'printed_by', 'Printed By', 'Edition', (c) => _text(_book(c).printedBy)),
  _numberField(
      'printing', 'Printing', 'Edition', (c) => _book(c).printingNumber),
  _numberField('spine_thickness', 'Spine Thickness', 'Edition',
      (c) => _book(c).spineThicknessMm),
  _textField('volume', 'Volume', 'Edition',
      (c) => _text(_book(c).volumeName ?? _book(c).volumeNumber)),
  _numberField('weight', 'Weight', 'Edition', (c) => _book(c).weightGrams),
  _numberField('width', 'Width', 'Edition', (c) => _book(c).widthMm),
  _textField('foreword_author', 'Foreword Author', 'Credits',
      (c) => _role(c, 'foreword author')),
  _textField('ghost_writer', 'Ghost Writer', 'Credits',
      (c) => _role(c, 'ghost writer')),
  _textField('photographer', 'Photographer', 'Credits',
      (c) => _role(c, 'photographer')),
  _textField(
      'dewey', 'Dewey', 'Categorization', (c) => _identifier(c, 'dewey')),
  _textField('lc_classification', 'LC Classification', 'Categorization',
      (c) => _identifier(c, 'lcc')),
  _textField('lc_control_number', 'LC Control No.', 'Categorization',
      (c) => _identifier(c, 'lccn')),
  _dateField('added_date_time', 'Added Date/Time', 'Personal', (c) => c.addedAt,
      personal: true, withTime: true),
  _numberField('added_year', 'Added Year', 'Personal', (c) => c.addedAt?.year,
      personal: true),
  _textField('collection_status', 'Collection Status', 'Personal',
      (c) => _text(_entry(c)?.personal.collectionStatus),
      personal: true),
  _textField(
      'dust_jacket',
      'Dust Jacket',
      'Personal',
      (c) => switch (_entry(c)) {
            final entry? => _yesNo(entry.personal.details.dustJacketPresent),
            null => null,
          },
      personal: true,
      width: 90),
  _numberField(
      'index', 'Index', 'Personal', (c) => _entry(c)?.personal.indexNumber,
      personal: true),
  _dateField('last_read', 'Last Read', 'Personal', _lastRead, personal: true),
  _dateField('modified_date_time', 'Modified Date/Time', 'Personal',
      (c) => c.updatedAt,
      personal: true, withTime: true),
  _textField('notes', 'Notes', 'Personal',
      (c) => _text(_entry(c)?.personal.personalNotes),
      personal: true, width: 225),
  _textField('owner', 'Owner', 'Personal',
      (c) => _text(_entry(c)?.personal.ownerLabel),
      personal: true),
  _numberField('pages_read', 'Pages Read', 'Personal',
      (c) => _entry(c)?.personal.details.readEvents.lastOrNull?.pagesRead,
      personal: true),
  _numberField(
      'quantity', 'Quantity', 'Personal', (c) => _entry(c)?.personal.quantity,
      personal: true),
  _numberField(
      'read_count',
      'Read Count',
      'Personal',
      (c) => _entry(c)
          ?.personal
          .details
          .readEvents
          .where((event) => event.isFinished)
          .length,
      personal: true),
  _textField('reader', 'Reader', 'Personal', (c) {
    final events =
        _entry(c)?.personal.details.readEvents ?? const <BookReadEvent>[];
    return _joined({
      for (final event in events)
        if (_text(event.reader) case final reader?) reader
    });
  }, personal: true),
  _textField('tags', 'Tags', 'Personal',
      (c) => _text((_entry(c)?.personal.tags ?? const []).join(' | ')),
      personal: true, width: 225),
];
