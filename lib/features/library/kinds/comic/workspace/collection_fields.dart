import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/creator_roles.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/dto.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_field.dart'
    show libraryCollectionStatusFromValue;
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart'
    show LibraryCollectionStatusScopeUi;
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/schema/field_factories.dart';

/// Collection fields the reference Comics column chooser lists beside the
/// catalog and personal fields that already have their own definitions.
/// Dates are ISO text, so they sort in date order and keep partial dates.
abstract final class ComicCollectionWorkspaceFields {
  // Main
  static final age = _text('age', 'Age', (dto) => dto.comic.publicationAge);
  static final country =
      _text('country', 'Country', (dto) => dto.comic.country);
  static final crossover =
      _text('crossover', 'Crossover', (dto) => dto.comic.crossover);
  static final fullTitle = _text('full_title', 'Full Title', comicFullTitle);
  static final issue = _text('issue', 'Issue', comicIssueLabel);
  static final language =
      _text('language', 'Language', (dto) => dto.comic.language);
  static final releaseDate = _text('release_date', 'Release Date',
      (dto) => _partial(dto.comic.releaseDateParts, dto.releaseDate));
  static final releaseYear = _year('release_year', 'Release Year',
      (dto) => _partialOf(dto.comic.releaseDateParts, dto.releaseDate)?.year);
  static final seriesGroup =
      _text('series_group', 'Series Group', (dto) => dto.comic.seriesGroup);
  static final subtitle =
      _text('subtitle', 'Subtitle', (dto) => dto.comic.subtitle);

  // Edition
  static final coverDate = _text('cover_date', 'Cover Date',
      (dto) => _partial(dto.comic.coverDateParts, dto.comic.coverDate));
  static final coverYear = _year('cover_year', 'Cover Year',
      (dto) => _partialOf(dto.comic.coverDateParts, dto.comic.coverDate)?.year);
  static final format = _text('format', 'Format', (dto) => dto.format);
  static final variantDescription = _text('variant_description',
      'Variant Description', (dto) => dto.comic.variantDescription);

  // Creators & Characters
  static final creators = _text(
      'creators',
      'Creators',
      (dto) => _join(dto.comic.creators
          .map((creator) => creator.name)
          .whereType<String>()
          .toSet()));
  static final creatorRoles = [
    for (final role in kComicCreatorRoles)
      _text('creator_${_slug(role)}', role,
          (dto) => _join(comicCreatorNames(dto, role))),
  ];

  // Value
  static final myValue =
      _money('my_value', 'My Value', (personal) => personal.marketValueCents);
  static final priceSold =
      _money('price_sold', 'Price Sold', (personal) => personal.sellPriceCents);
  static final purchaseDate = _text('purchase_date', 'Purchase Date',
      (dto) => _date(dto.libraryEntry?.personal.purchaseDate));
  static final purchaseStore = _text('purchase_store', 'Purchase Store',
      (dto) => dto.libraryEntry?.personal.purchaseStore,
      source: LibraryFieldSource.libraryEntry);
  static final soldDate = _text('sold_date', 'Sold Date',
      (dto) => _date(dto.libraryEntry?.personal.soldAt));

  // Personal
  static final collectionStatus =
      _text('collection_status', 'Collection Status', (dto) {
    final value = dto.libraryEntry?.personal.collectionStatus;
    return value == null ? null : libraryCollectionStatusFromValue(value).label;
  }, source: LibraryFieldSource.libraryEntry);
  static final index =
      _number('index', 'Index', (personal) => personal.indexNumber);
  static final quantity =
      _number('quantity', 'Quantity', (personal) => personal.quantity);
  static final notes = _text(
      'notes', 'Notes', (dto) => dto.libraryEntry?.personal.personalNotes,
      source: LibraryFieldSource.libraryEntry);
  static final owner = _text(
      'owner', 'Owner', (dto) => dto.libraryEntry?.personal.ownerLabel,
      source: LibraryFieldSource.libraryEntry);
  static final plot = _text(
      'plot', 'Plot', (dto) => dto.comic.description ?? dto.comic.synopsis,
      groupable: false);
  static final read = _text('read', 'Read', (dto) {
    final personal = dto.libraryEntry?.personal;
    if (personal == null) return null;
    return personal.reading.status == 'Read' ? 'Yes' : 'No';
  }, source: LibraryFieldSource.libraryEntry);
  static final readDate = _text('read_date', 'Read Date',
      (dto) => _date(dto.libraryEntry?.personal.reading.finishedAt));
  static final tags = _text('tags', 'Tags',
      (dto) => _join(dto.libraryEntry?.personal.tags ?? const <String>[]),
      source: LibraryFieldSource.libraryEntry);

  // Loan
  static final loanedTo =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: const LibraryFieldId('comic.loaned_to'),
    metadata: _metadata('loaned_to', 'Loaned To', LibraryFieldValueType.text),
    getValue: (context) => _activeLoan(context)?.borrowerName,
  );
  static final loanDate =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: const LibraryFieldId('comic.loan_date'),
    metadata: _metadata('loan_date', 'Loan Date', LibraryFieldValueType.text),
    getValue: (context) => _date(_activeLoan(context)?.lentDate),
  );
  static final dueDate =
      LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?>(
    id: const LibraryFieldId('comic.due_date'),
    metadata: _metadata('due_date', 'Due Date', LibraryFieldValueType.text),
    getValue: (context) => _date(_activeLoan(context)?.dueDate),
  );

  static final main = [
    age,
    country,
    crossover,
    fullTitle,
    issue,
    language,
    releaseDate,
    seriesGroup,
    subtitle,
  ];
  static final edition = [coverDate, format, variantDescription];
  static final value = [purchaseDate, purchaseStore, soldDate];
  static final personal = [
    collectionStatus,
    notes,
    owner,
    plot,
    read,
    readDate,
    tags,
  ];
  static final loan = [loanedTo, loanDate, dueDate];
  static final years = [releaseYear, coverYear];
  static final numbers = [index, quantity];
  static final money = [myValue, priceSold];

  static final all =
      <LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, Object?>>[
    ...main,
    ...edition,
    creators,
    ...creatorRoles,
    ...value,
    ...personal,
    ...loan,
    ...years,
    ...numbers,
    ...money,
  ];
}

/// The reference Issue value: issue number followed by the variant ("2A").
String? comicIssueLabel(ComicWorkspaceDto dto) {
  final value =
      '${dto.comic.issueNumber?.trim() ?? ''}${dto.comic.variant?.trim() ?? ''}';
  return value.isEmpty ? null : value;
}

/// Series, issue and title, as the reference Full Title column shows them.
String? comicFullTitle(ComicWorkspaceDto dto) {
  final series = dto.comic.seriesTitle?.trim() ?? '';
  final issue = comicIssueLabel(dto);
  final title = dto.comic.title.trim();
  final head = [
    if (series.isNotEmpty) series,
    if (issue != null) '#$issue',
  ].join(' ');
  if (title.isEmpty || title == series) return head.isEmpty ? null : head;
  return head.isEmpty ? title : '$head - $title';
}

Iterable<String> comicCreatorNames(ComicWorkspaceDto dto, String role) {
  final wanted = _slug(role);
  return dto.comic.creators
      .where((creator) => _slug(creator.role ?? creator.roleId ?? '') == wanted)
      .map((creator) => creator.name)
      .whereType<String>();
}

String _slug(String value) =>
    value.toLowerCase().replaceAll(RegExp('[^a-z]'), '_');

String? _join(Iterable<String> values) {
  final text = values.where((value) => value.trim().isNotEmpty).join(' | ');
  return text.isEmpty ? null : text;
}

PartialDate? _partialOf(PartialDate? parts, DateTime? date) =>
    parts ?? (date == null ? null : PartialDate.fromDateTime(date));

String? _partial(PartialDate? parts, DateTime? date) =>
    _partialOf(parts, date)?.isoString;

String? _date(DateTime? value) =>
    value == null ? null : PartialDate.fromDateTime(value).isoString;

Loan? _activeLoan(LibraryProjectionContext<ComicWorkspaceDto> context) =>
    context.personal.loans
        .where((loan) => loan.returnedDate == null)
        .firstOrNull;

LibraryKindFieldMetadata _metadata(
  String key,
  String label,
  LibraryFieldValueType type, {
  LibraryFieldSource source = LibraryFieldSource.libraryEntry,
  bool groupable = false,
}) =>
    LibraryKindFieldMetadata(
      id: 'comic.$key',
      label: label,
      valueType: type,
      cardinality: LibraryFieldCardinality.one,
      source: source,
      sourcePath: key,
      sortable: true,
      groupable: groupable,
    );

LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, String?> _text(
  String key,
  String label,
  String? Function(ComicWorkspaceDto dto) getValue, {
  LibraryFieldSource source = LibraryFieldSource.catalog,
  bool groupable = true,
}) =>
    keyedTextField('comic', key, label, getValue,
        source: source, groupable: groupable);

LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?> _year(
  String key,
  String label,
  int? Function(ComicWorkspaceDto dto) getValue,
) =>
    LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
      id: LibraryFieldId('comic.$key'),
      metadata: _metadata(key, label, LibraryFieldValueType.number,
          source: LibraryFieldSource.derived, groupable: true),
      getValue: (context) => getValue(context.dto),
    );

LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?> _number(
  String key,
  String label,
  int? Function(ComicPersonalData personal) getValue,
) =>
    LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
      id: LibraryFieldId('comic.$key'),
      metadata: _metadata(key, label, LibraryFieldValueType.number),
      getValue: (context) => switch (context.dto.libraryEntry) {
        final entry? => getValue(entry.personal),
        null => null,
      },
    );

LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?> _money(
  String key,
  String label,
  int? Function(ComicPersonalData personal) getValue,
) =>
    LibraryFieldDefinition<ComicKind, ComicWorkspaceDto, int?>(
      id: LibraryFieldId('comic.$key'),
      metadata: _metadata(key, label, LibraryFieldValueType.number),
      getValue: (context) => switch (context.dto.libraryEntry) {
        final entry? => getValue(entry.personal),
        null => null,
      },
    );
