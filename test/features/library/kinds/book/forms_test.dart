import 'package:collectarr_app/features/library/kinds/book/add/draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/contribution.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/draft.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/create_payload.dart';
import 'package:collectarr_app/features/library/add/models/common_draft.dart';
import 'package:collectarr_app/features/library/add/models/tracking_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/manual_candidate.dart';
import 'package:collectarr_app/features/library/kinds/book/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/catalog_form_adapters.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/catalog_form_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Books full CLZ edition fields survive Add and Edit transport', () {
    final values = BookCatalogFormValues(
      boxSet: 'Collection',
      publicationPlace: 'Bucharest',
      printedBy: 'Printer',
      paperType: 'Acid-free',
      printingNumber: 2,
      extras: ['Map', 'Ribbon'],
      numberLine: '10 9 8 7 6 5 4 3 2',
      widthMm: 133,
      heightMm: 197,
      spineThicknessMm: 19,
      weightGrams: 213,
      originalSubtitle: 'Subtitle',
      originalCountry: 'Romania',
      originalPublisher: 'Publisher',
      originalPublicationPlace: 'Bucharest',
      audioAbridged: true,
      audioLengthMinutes: 95,
      lcControlNumber: 'LC-123',
      lcClassification: 'PZ-1',
      dewey: '823',
    );
    final manual = BookAddManualDraft(values: values);
    addTearDown(manual.dispose);
    final candidate = buildBookManualCandidate(manual, title: 'Book')!;
    final added = candidate.kindCapability
        .mapTransport((item) => BookCatalogMetadata.fromJson(item.kindData));
    final edit = BookItemEditDraft.fromMetadata(added);
    addTearDown(edit.dispose);
    final saved = BookCatalogMetadata.fromJson(edit.toMetadata().toJson());
    for (final key in [
      'box_set',
      'publication_place',
      'printed_by',
      'paper_type',
      'printing_number',
      'extras',
      'number_line',
      'width_mm',
      'height_mm',
      'spine_thickness_mm',
      'weight_grams',
      'original_subtitle',
      'original_country',
      'original_publisher',
      'original_publication_place',
      'audio_abridged',
      'audio_length_minutes',
      'identifiers'
    ]) {
      expect(saved.toJson()[key], added.toJson()[key], reason: key);
      expect(added.toJson()[key], isNotNull, reason: key);
    }
    edit.values.widthMm = null;
    edit.values.extras = [];
    edit.values.lcControlNumber = '';
    final cleared = edit.toMetadata();
    expect(cleared.widthMm, isNull);
    expect(cleared.extras, isEmpty);
    expect(cleared.identifiers.map((value) => value.identifierType),
        ['lcc', 'dewey']);
    expect(cleared.heightMm, 197);
  });

  test('Books Add and Edit preserve formatted Plot without flattening it', () {
    const html =
        '<p>A <b>reference</b> story.</p><ul><li>One</li><li>Two</li></ul>';
    final manual =
        BookAddManualDraft(values: BookCatalogFormValues(description: html));
    addTearDown(manual.dispose);
    final candidate = buildBookManualCandidate(manual, title: 'Reference')!;
    final metadata = candidate.kindCapability
        .mapTransport((item) => BookCatalogMetadata.fromJson(item.kindData));
    expect(metadata.synopsis, html);
    final edit = BookItemEditDraft.fromMetadata(metadata);
    addTearDown(edit.dispose);
    expect(edit.toMetadata().synopsis, html);
    expect(edit.toMetadata().description, metadata.description);
  });

  test('Books Add command persists copy value and separate reading state', () {
    final manual = BookAddManualDraft();
    addTearDown(manual.dispose);
    final candidate = buildBookManualCandidate(manual, title: 'Book')!;
    final sold = DateTime.utc(2026, 10, 1);
    final command = bookKindAdd.buildCommand(
        candidate,
        const LibraryAddCommonDraft(condition: 'Good', currency: 'EUR'),
        BookAddDraft(
            retailPriceCents: 2100,
            marketValueCents: 1800,
            sellPriceCents: 1700,
            soldAt: sold,
            dustJacketPresent: true),
        tracking: const LibraryAddTrackingDraft(readStatus: 'Read', rating: 8));
    final payload = command.typedPayload as BookLibraryEntryCreatePayload;
    final item = payload.toLibraryEntry(
        id: 'copy',
        sourceCatalogItem: candidate,
        createdAt: DateTime.utc(2026),
        existingIsDigital: false,
        ownerUserId: null,
        ownerLabel: null);
    expect(item.personal.details.retailPriceCents, 2100);
    expect(item.personal.details.dustJacketPresent, isTrue);
    expect(item.personal.marketValueCents, 1800);
    expect(item.personal.sellPriceCents, 1700);
    expect(item.personal.soldAt, sold);
    expect(command.tracking!.rating, 8);
    expect(command.tracking!.status, isNotNull);
  });

  test('Books manual Add persists editor, illustrator and narrator credits',
      () {
    final draft = BookAddManualDraft(
        values: BookCatalogFormValues(
      authors: const [BookCatalogCredit(name: 'Author', role: 'Author')],
      otherContributors: const [
        BookCatalogCredit(
            name: 'Editor', role: 'Editor', sortName: 'Editor, The'),
        BookCatalogCredit(name: 'Artist', role: 'Illustrator'),
        BookCatalogCredit(name: 'Voice', role: 'Narrator'),
      ],
    ));
    addTearDown(draft.dispose);
    final candidate = buildBookManualCandidate(draft, title: 'Book')!;
    final saved = candidate.kindCapability.mapTransport(
      (transport) => BookCatalogMetadata.fromJson(transport.kindData),
    );
    expect(saved.creators.single.name, 'Author');
    expect(saved.contributors.map((credit) => credit.role),
        ['Editor', 'Illustrator', 'Narrator']);
    expect(saved.contributors.first.sortName, 'Editor, The');
  });

  test('Books Edit replaces one contributor role and retains untouched data',
      () {
    const current = BookCatalogMetadata(
      title: 'Book',
      isbn: '9780316085274',
      contributors: [
        BookCatalogCredit(id: 'editor-id', name: 'Editor', role: 'Editor'),
        BookCatalogCredit(id: 'artist-id', name: 'Artist', role: 'Illustrator'),
        BookCatalogCredit(
            id: 'other-id', name: 'Researcher', role: 'Researcher'),
      ],
    );
    final values = bookCatalogFormValuesFromMetadata(current);
    values.otherContributors.removeWhere((credit) => credit.role == 'Editor');
    values.otherContributors
        .add(const BookCatalogCredit(name: 'New Editor', role: 'Editor'));
    final saved = applyBookCatalogFormValues(
        current: current, values: values, title: 'Book');
    expect(saved.isbn, current.isbn);
    expect(saved.contributors.map((credit) => credit.name),
        ['Artist', 'Researcher', 'New Editor']);
    expect(saved.contributors.first.id, 'artist-id');
    expect(saved.contributors[1].id, 'other-id');
  });
}
