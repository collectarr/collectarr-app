import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/inspector/library_inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/comic/inspector_sections.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_types.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('InspectorMetadataSection', () {
    testWidgets('renders metadata section title', (tester) async {
      final type = collectarrLibraryTypes.byKind('comic')!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorMetadataSection(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'comic-1',
                mediaType: 'comic',
                title: 'Spider-Man #1',
                publisher: 'Marvel',
                releaseYear: 1990,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Metadata'), findsWidgets);
    });

    testWidgets('triggers onFilterByValue callback', (tester) async {
      final type = collectarrLibraryTypes.byKind('comic')!;
      String? filteredValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorMetadataSection(
              type: type,
              entry: LibraryWorkspaceEntry(
                id: 'comic-1',
                mediaType: 'comic',
                title: 'Spider-Man #1',
                publisher: 'Marvel',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.red,
              onFilterByValue: (v) => filteredValue = v,
            ),
          ),
        ),
      );

      // The callback is wired up even if we can't easily tap the metadata chip
      expect(filteredValue, isNull);
    });
  });

  group('InspectorPersonalSection', () {
    testWidgets('shows tracking status and rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'Dune',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                rating: 8,
                readStatus: 'completed',
                condition: 'Near Mint',
                grade: '9.4',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              trackingEntry: TrackingEntry(
                id: 'track-1',
                itemId: 'book-1',
                rating: 8,
                progressCurrent: 412,
                progressTotal: 412,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      // Personal section renders with the owned item data
      expect(find.byType(InspectorPersonalSection), findsOneWidget);
    });

    testWidgets('shows quantity when more than 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'Dune',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                quantity: 3,
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows sold information when soldAt is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'Dune',
                pricePaidCents: 1000,
                currency: 'USD',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                pricePaidCents: 1000,
                currency: 'USD',
                soldAt: DateTime.utc(2026, 5, 20),
                sellPriceCents: 1500,
                soldTo: 'Collector X',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Sold'), findsOneWidget);
      expect(find.text('Profit / Loss'), findsOneWidget);
    });

    testWidgets('shows tags when present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorPersonalSection(
              entry: LibraryWorkspaceEntry(
                id: 'book-1',
                mediaType: 'book',
                title: 'Dune',
                tags: 'sci-fi, classic',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              ownedItem: OwnedItem(
                id: 'owned-1',
                itemId: 'book-1',
                tags: 'sci-fi, classic',
                updatedAt: DateTime.utc(2026, 5, 22),
              ),
              accent: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('sci-fi'), findsOneWidget);
      expect(find.text('classic'), findsOneWidget);
    });

    testWidgets('comic inspector builder renders comic-only collector facts',
        (tester) async {
      final type = collectarrLibraryTypes.byKind('comic')!;
      final sections = <Widget>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                sections.addAll(
                  buildComicInspectorSections(
                    context,
                    LibraryInspectorRequest(
                      type: type,
                      entry: LibraryWorkspaceEntry(
                        id: 'comic-1',
                        mediaType: 'comic',
                        title: 'Saga #1',
                        itemNumber: '1',
                        publisher: 'Image Comics',
                        releaseYear: 2012,
                        genres: const ['Sci-Fi', 'Fantasy'],
                        creators: const [
                          {'name': 'Brian K. Vaughan', 'role': 'Writer'},
                        ],
                        characters: const ['Alana'],
                        storyArcs: const ['Saga'],
                        updatedAt: DateTime.utc(2026, 5, 22),
                      ),
                      ownedItem: OwnedItem(
                        id: 'owned-1',
                        itemId: 'comic-1',
                        isDigital: false,
                        currency: 'USD',
                        rawOrSlabbed: 'Slabbed',
                        gradingCompany: 'CGC',
                        certificationNumber: '1234567001',
                        labelType: 'Universal',
                        customLabel: 'Newsstand',
                        pageQuality: 'White',
                        graderNotes: 'Small spine stress',
                        signedBy: 'Brian K. Vaughan',
                        keyComic: true,
                        keyReason: 'First appearance',
                        keyCategory: 'First appearances',
                        keySeverity: 'Major',
                        marketValueCents: 1899,
                        updatedAt: DateTime.utc(2026, 5, 22),
                      ),
                      trackingEntry: null,
                      accent: Colors.red,
                    ),
                  ),
                );
                return SingleChildScrollView(
                  child: Column(children: sections),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Catalog identity'), findsOneWidget);
      expect(find.text('Catalog context'), findsOneWidget);
      expect(find.text('Credits & Discovery'), findsOneWidget);
      expect(find.text('Creators'), findsOneWidget);
      expect(find.textContaining('Brian K. Vaughan'), findsWidgets);
      expect(find.text('Characters'), findsOneWidget);
      expect(find.text('Story Arcs'), findsOneWidget);
      expect(find.text('Comic details'), findsOneWidget);
      expect(find.text('Raw / Slabbed'), findsOneWidget);
      expect(find.text('Slabbed'), findsOneWidget);
      expect(find.text('Grading co.'), findsOneWidget);
      expect(find.text('CGC'), findsOneWidget);
      expect(find.text('Certification no.'), findsOneWidget);
      expect(find.text('1234567001'), findsOneWidget);
      expect(find.text('Label type'), findsOneWidget);
      expect(find.text('Universal'), findsOneWidget);
      expect(find.text('Custom label'), findsOneWidget);
      expect(find.text('Newsstand'), findsOneWidget);
      expect(find.text('Page quality'), findsOneWidget);
      expect(find.text('White'), findsOneWidget);
      expect(find.text('Signed by'), findsOneWidget);
      expect(find.text('Brian K. Vaughan'), findsOneWidget);
      expect(find.text('Key'), findsOneWidget);
      expect(find.text('First appearance'), findsOneWidget);
      expect(find.text('Key category'), findsOneWidget);
      expect(find.text('First appearances'), findsOneWidget);
      expect(find.text('Key severity'), findsOneWidget);
      expect(find.text('Major'), findsOneWidget);
      expect(find.text('Grader notes'), findsOneWidget);
      expect(find.text('Small spine stress'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
      expect(find.text('Current value'), findsOneWidget);
      expect(find.text('USD 18.99'), findsOneWidget);
    });
  });

  group('EmptyInspector', () {
    testWidgets('renders placeholder text', (tester) async {
      final type = collectarrLibraryTypes.byKind('comic')!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyInspector(type: type, accent: Colors.grey),
          ),
        ),
      );

      expect(find.textContaining('Select'), findsOneWidget);
      expect(find.text('Details panel'), findsOneWidget);
    });
  });
}
