import 'package:collectarr_app/features/comics/comics_add_preview_pane.dart';
import 'package:collectarr_app/features/library/metadata/provider_candidate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('provider metadata summary is parsed into description facts',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 640,
              child: AddComicPreviewPane(
                item: null,
                candidate: ProviderCandidate(
                  provider: 'gcd',
                  providerItemId: '148725',
                  title:
                      'Over the Garden Wall (2015 series) #1 [Baltimore Comic Con Exclusive Cover]',
                  kind: 'comic',
                  summary: 'August 2015 · 3.99 USD · 28 pages · variant',
                ),
                selectedProviderLabel: 'GCD',
                selectedIsOwned: false,
                selectedIsWishlisted: false,
                searchedServer: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Plot'), findsNothing);
    expect(find.text('Details'), findsNothing);
    expect(
      find.textContaining('Series: Over the Garden Wall (2015 series)'),
      findsOneWidget,
    );
    expect(find.textContaining('Issue: #1'), findsOneWidget);
    expect(
      find.textContaining('Cover: Baltimore Comic Con Exclusive Cover'),
      findsOneWidget,
    );
    expect(find.textContaining('Publication: August 2015'), findsOneWidget);
    expect(find.textContaining('Cover price: 3.99 USD'), findsOneWidget);
    expect(find.textContaining('Pages: 28 pages'), findsOneWidget);
    expect(find.textContaining('Type: Variant cover'), findsOneWidget);
    expect(find.textContaining('Provider: gcd (148725)'), findsNothing);
    expect(find.text('Metadata candidate'), findsOneWidget);
  });
}
