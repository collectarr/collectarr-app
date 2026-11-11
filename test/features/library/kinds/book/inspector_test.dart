import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/partial_date.dart';
import 'package:collectarr_app/features/library/details/section.dart';
import 'package:collectarr_app/features/library/domain/target_ref.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_library_entry.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_metadata.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_personal_data.dart';
import 'package:collectarr_app/features/library/kinds/book/entries/book_entry_details.dart';
import 'package:collectarr_app/features/library/kinds/book/presentation_builder.dart';
import 'package:collectarr_app/features/library/kinds/book/workspace/data.dart';
import 'package:collectarr_app/features/library/workspace/entry/context.dart';
import 'package:collectarr_app/features/library/workspace/entry/item.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('populated Books inspector keeps edition and copy facts once',
      (tester) async {
    final entry = BookLibraryEntry(
      id: const LibraryEntryId('reference'),
      updatedAt: DateTime.utc(2026),
      createdAt: DateTime.utc(2025),
      metadata: const BookCatalogMetadata(
        title: 'Reference',
        originalTitle: 'Original reference',
        originalPublicationDateParts: PartialDate(year: 2020, month: 3),
        originalPublicationPlace: 'Paris',
        printedBy: 'Reference Printer',
        paperType: 'Acid-free',
        printingNumber: 3,
        firstEdition: true,
        audioLengthMinutes: 525,
        audioAbridged: false,
        extras: ['Dust jacket'],
      ),
      personal: BookPersonalData(
        ownerLabel: 'Reference Owner',
        condition: 'Very Good',
        purchaseDate: DateTime.utc(2024, 9, 15),
        purchaseStore: 'Reference Bookshop',
        pricePaidCents: 2495,
        soldAt: DateTime.utc(2025, 2, 20),
        sellPriceCents: 3150,
        personalNotes: 'Reference notes',
        details: const BookEntryDetails(
          dustJacketPresent: true,
          dustJacketCondition: 'Fine',
          retailPriceCents: 3995,
        ),
      ),
    );
    final summary = BookLibraryEntryProjection.toSummary(entry);
    final source = LibraryWorkspaceContext(
      item: WorkspaceItem(
        target: EntryTargetRef(summary.ref),
        entrySummary: summary,
        kindPresentationData: BookWorkspaceData(metadata: entry.metadata),
        libraryEntryDispatch: OpaqueLibraryEntryDispatch(
            ref: summary.ref, kind: CatalogMediaKind.book, value: entry),
      ),
      personal: const PersonalOverlay(locationPath: 'Reference Shelf'),
    );
    final item = LibraryProjectionItem.fromShelf(
        source, libraryKindRegistrationForKind(CatalogMediaKind.book));
    final sections = <LibraryDetailSection>[];
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      sections.addAll(const BookLibraryMediaPresentationBuilder()
          .buildInspectorSections(
              context: context, item: item, accent: Colors.purple)
          .whereType<LibraryDetailSection>());
      return const SizedBox.shrink();
    })));
    final fields = {
      for (final section in sections)
        section.title: {
          for (final field in section.fields) field.label: field.value
        }
    };
    expect(
        fields['Details'], containsPair('Original Publication Place', 'Paris'));
    expect(fields['Details'], containsPair('Audiobook Length', '08:45'));
    expect(fields['Details'], containsPair('Audiobook Abridged', 'No'));
    expect(fields['Details'], containsPair('First Edition', 'Yes'));
    expect(fields['Details'], containsPair('Printed By', 'Reference Printer'));
    expect(fields['Value'], containsPair('Book Condition', 'Very Good'));
    expect(fields['Value'], containsPair('Dust Jacket', 'Yes'));
    expect(fields['Value'], containsPair('Dust Jacket Condition', 'Fine'));
    expect(
        fields['Value'], containsPair('Purchase Store', 'Reference Bookshop'));
    expect(fields['Personal'], isNot(contains('Book Condition')));
    expect(
        sections.where((section) => section.title == 'Personal'), hasLength(1));
    final capability = libraryInspectorForKind(CatalogMediaKind.book);
    expect(capability.showsActionBar, isFalse);
    expect(capability.showsDefaultPersonalSection, isFalse);
    expect(capability.supportsLibraryEntryImages, isTrue);
  });
}
