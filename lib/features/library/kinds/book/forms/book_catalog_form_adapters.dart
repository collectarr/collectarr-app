import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/book_catalog_form_values.dart';
import 'package:collectarr_app/core/models/partial_date.dart';

BookCatalogMetadata bookMetadataFromManualFormValues({
  required BookCatalogFormValues values,
  required String id,
  required String title,
}) {
  final releaseDate = values.releaseDate ??
      (values.publicationYear == null
          ? null
          : DateTime.utc(values.publicationYear!));
  return BookCatalogMetadata(
    transportId: id,
    title: title.trim(),
    sortTitle: _optional(values.sortTitle),
    subtitle: _optional(values.subtitle),
    editionTitle: _optional(values.editionTitle),
    editionStatement: _optional(values.editionStatement),
    seriesTitle: _optional(values.seriesTitle),
    seriesGroup: _optional(values.seriesGroup),
    itemNumber: _optional(values.number),
    publisher: _optional(values.publisher),
    distributor: _optional(values.distributor),
    imprint: _optional(values.imprint),
    pageCount: values.pageCount,
    creators: values.authors,
    contributors: values.translators,
    characters: [
      for (final name in _split(values.characters))
        BookCatalogCharacter(name: name),
    ],
    synopsis: _optional(values.description),
    genres: values.genres,
    subjects: values.subjects,
    ageRating: _optional(values.ageRating),
    language: _optional(values.language),
    originalLanguage: _optional(values.originalLanguage),
    country: _optional(values.country),
    region: _optional(values.region),
    firstPublicationDate: values.firstPublicationDate,
    firstPublicationDateParts: values.firstPublicationDate == null
        ? null
        : PartialDate.fromDateTime(values.firstPublicationDate!),
    originalPublicationDate: values.originalPublicationDate,
    originalPublicationDateParts: values.originalPublicationDate == null
        ? null
        : PartialDate.fromDateTime(values.originalPublicationDate!),
    releaseDate: releaseDate,
    releaseDateParts: releaseDate == null
        ? null
        : values.releaseDate == null && values.publicationYear != null
            ? PartialDate(year: values.publicationYear)
            : PartialDate.fromDateTime(releaseDate),
    isbn: _optional(values.isbn),
    barcode: _optional(values.upc),
    variant: _optional(values.variant),
    binding: _optional(values.binding),
    physicalFormat: _optional(values.format),
    coverImageUrl: _optional(values.coverImageUrl),
    backCoverImageUrl: _optional(values.backCoverImageUrl),
    thumbnailImageUrl: _optional(values.thumbnailImageUrl),
    searchAliases: values.searchAliases,
    originalTitle: _optional(values.originalTitle),
    localizedTitle: _optional(values.localizedTitle),
    releaseStatus: _optional(values.releaseStatus),
    dimensions: _optional(values.dimensions),
    firstEdition: values.firstEdition,
    audioLengthMinutes: values.audioLengthMinutes,
  );
}

BookCatalogFormValues bookCatalogFormValuesFromMetadata(
  BookCatalogMetadata metadata,
) {
  final authors = [...metadata.creators, ...metadata.contributors]
      .where((credit) => _isBookCreditRole(credit.role, 'author'))
      .toList(growable: false);
  final translators = [...metadata.creators, ...metadata.contributors]
      .where((credit) => _isBookCreditRole(credit.role, 'translator'))
      .toList(growable: false);
  return BookCatalogFormValues(
    title: metadata.title,
    sortTitle: metadata.sortTitle ?? '',
    subtitle: metadata.subtitle ?? '',
    originalTitle: metadata.originalTitle ?? '',
    localizedTitle: metadata.localizedTitle ?? '',
    description: metadata.synopsis ?? metadata.description ?? '',
    originalLanguage: metadata.originalLanguage ?? '',
    firstPublicationDate: metadata.firstPublicationDate ??
        metadata.firstPublicationDateParts?.asDateTime,
    originalPublicationDate: metadata.originalPublicationDate ??
        metadata.originalPublicationDateParts?.asDateTime,
    genres: List.of(metadata.genres),
    subjects: List.of(metadata.subjects),
    searchAliases: List.of(metadata.searchAliases),
    number: metadata.itemNumber ?? '',
    variant: metadata.variant ?? '',
    seriesTitle: metadata.seriesTitle ?? '',
    seriesGroup: metadata.seriesGroup ?? '',
    authors: authors.isEmpty ? List.of(metadata.creators) : authors,
    translators: translators,
    characters: metadata.characters.map((value) => value.name).join(', '),
    ageRating: metadata.ageRating ?? '',
    country: metadata.country ?? '',
    publicationYear:
        metadata.releaseDate?.year ?? metadata.releaseDateParts?.year,
    editionTitle: metadata.editionTitle ?? '',
    binding: metadata.binding ?? '',
    format: metadata.physicalFormat ?? '',
    isbn: metadata.isbn ?? metadata.isbn13 ?? metadata.isbn10 ?? '',
    upc: metadata.barcode ?? '',
    publisher: metadata.publisher ?? '',
    distributor: metadata.distributor ?? '',
    imprint: metadata.imprint ?? '',
    releaseDate: metadata.releaseDate ?? metadata.releaseDateParts?.asDateTime,
    pageCount: metadata.pageCount,
    language: metadata.language ?? '',
    region: metadata.region ?? '',
    releaseStatus: metadata.releaseStatus ?? '',
    editionStatement: metadata.editionStatement ?? '',
    dimensions: metadata.dimensions ?? '',
    firstEdition: metadata.firstEdition ?? false,
    audioLengthMinutes: metadata.audioLengthMinutes,
    coverImageUrl: metadata.coverImageUrl ?? '',
    thumbnailImageUrl: metadata.thumbnailImageUrl ?? '',
    backCoverImageUrl: metadata.backCoverImageUrl ?? '',
  );
}

BookCatalogMetadata applyBookCatalogFormValues({
  required BookCatalogMetadata current,
  required BookCatalogFormValues values,
  required String title,
}) {
  final displayedIsbn = current.isbn ?? current.isbn13 ?? current.isbn10 ?? '';
  final isbnChanged = values.isbn.trim() != displayedIsbn.trim();
  final originalPlotText = current.synopsis ?? current.description ?? '';
  final plotTextChanged = values.description != originalPlotText;
  final releaseDate = _editedDate(
    values.releaseDate,
    current.releaseDate,
    current.releaseDateParts,
    yearOverride: values.publicationYear,
  );
  final firstPublicationDate = _editedDate(
    values.firstPublicationDate,
    current.firstPublicationDate,
    current.firstPublicationDateParts,
  );
  final originalPublicationDate = _editedDate(
    values.originalPublicationDate,
    current.originalPublicationDate,
    current.originalPublicationDateParts,
  );
  final hasExplicitAuthors = current.creators.any(
    (credit) => _isBookCreditRole(credit.role, 'author'),
  );
  final currentCharacters = {
    for (final character in current.characters)
      character.name.trim().toLowerCase(): character,
  };
  return current.copyWith(
    title: title.trim(),
    sortTitle: _optional(values.sortTitle),
    subtitle: _optional(values.subtitle),
    originalTitle: _optional(values.originalTitle),
    localizedTitle: _optional(values.localizedTitle),
    searchAliases: List.of(values.searchAliases),
    subjects: List.of(values.subjects),
    synopsis:
        plotTextChanged ? _optional(values.description) : current.synopsis,
    coverImageUrl: _optional(values.coverImageUrl),
    backCoverImageUrl: _optional(values.backCoverImageUrl),
    thumbnailImageUrl: _optional(values.thumbnailImageUrl),
    description:
        plotTextChanged ? _optional(values.description) : current.description,
    itemNumber: _optional(values.number),
    variant: _optional(values.variant),
    seriesTitle: _optional(values.seriesTitle),
    seriesGroup: _optional(values.seriesGroup),
    pageCount: values.pageCount,
    imprint: _optional(values.imprint),
    publisher: _optional(values.publisher),
    distributor: _optional(values.distributor),
    isbn: isbnChanged ? _optional(values.isbn) : current.isbn,
    isbn10: isbnChanged ? null : current.isbn10,
    isbn13: isbnChanged ? null : current.isbn13,
    barcode: _optional(values.upc),
    editionTitle: _optional(values.editionTitle),
    editionStatement: _optional(values.editionStatement),
    dimensions: _optional(values.dimensions),
    physicalFormat: _optional(values.format),
    binding: _optional(values.binding),
    language: _optional(values.language),
    originalLanguage: _optional(values.originalLanguage),
    country: _optional(values.country),
    region: _optional(values.region),
    releaseStatus: _optional(values.releaseStatus),
    firstEdition: values.firstEdition,
    audioLengthMinutes: values.audioLengthMinutes,
    genres: List.of(values.genres),
    firstPublicationDate: firstPublicationDate.date,
    firstPublicationDateParts: firstPublicationDate.parts,
    originalPublicationDate: originalPublicationDate.date,
    originalPublicationDateParts: originalPublicationDate.parts,
    releaseDate: releaseDate.date,
    releaseDateParts: releaseDate.parts,
    characters: [
      for (final name in _split(values.characters))
        currentCharacters[name.trim().toLowerCase()] ??
            BookCatalogCharacter(name: name),
    ],
    creators: [
      for (final credit in current.creators)
        if (!_isBookCreditRole(credit.role, 'author') &&
            !_isBookCreditRole(credit.role, 'translator') &&
            hasExplicitAuthors)
          credit,
      ..._withBookRole(values.authors, 'Author'),
    ],
    contributors: [
      for (final credit in current.contributors)
        if (!_isBookCreditRole(credit.role, 'author') &&
            !_isBookCreditRole(credit.role, 'translator'))
          credit,
      ..._withBookRole(values.translators, 'Translator'),
    ],
  );
}

({DateTime? date, PartialDate? parts}) _editedDate(
  DateTime? selected,
  DateTime? original,
  PartialDate? originalParts, {
  int? yearOverride,
}) {
  if (selected == null && yearOverride == null) {
    return (date: null, parts: null);
  }
  final DateTime next;
  if (yearOverride != null && selected == null) {
    next = DateTime.utc(yearOverride);
  } else if (yearOverride != null && selected!.year != yearOverride) {
    next = DateTime.utc(yearOverride);
  } else {
    next = selected!;
  }
  if (original != null && _sameCalendarDate(next, original)) {
    return (date: original, parts: originalParts);
  }
  if (original == null &&
      originalParts != null &&
      originalParts.asDateTime != null &&
      _sameCalendarDate(next, originalParts.asDateTime!)) {
    return (date: null, parts: originalParts);
  }
  return (date: next, parts: PartialDate.fromDateTime(next));
}

bool _sameCalendarDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

List<BookCatalogCredit> _withBookRole(
  List<BookCatalogCredit> credits,
  String role,
) =>
    [
      for (var index = 0; index < credits.length; index++)
        BookCatalogCredit(
          name: credits[index].name,
          id: credits[index].id,
          artistId: credits[index].artistId,
          personId: credits[index].personId,
          creditedName: credits[index].creditedName,
          imageUrl: credits[index].imageUrl,
          instrument: credits[index].instrument,
          joinPhrase: credits[index].joinPhrase,
          role: role,
          roleId: credits[index].roleId,
          sequence: index,
          sortName: credits[index].sortName,
        ),
    ];

bool _isBookCreditRole(String? role, String expected) =>
    role?.trim().toLowerCase() == expected.toLowerCase();

String? _optional(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}

List<String> _split(String value) => value
    .split(RegExp(r'[,\r\n]+'))
    .map((entry) => entry.trim())
    .where((entry) => entry.isNotEmpty)
    .toList(growable: false);
