import 'package:collectarr_app/core/models/admin_metadata.dart';
import 'package:collectarr_app/features/library/add/library_add_dialog.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/metadata/provider_status_provider.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/library_add_test_harness.dart';

import '../../../helpers/test_constants.dart';

void main() {
  testWidgets('manual add flow surfaces digital ownership type', (tester) async {
    configureLibraryAddDesktopViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaCatalogProvider.overrideWith((ref) async => fallbackMediaCatalog),
          metadataProviderStatusesProvider.overrideWith(
            (ref) async => const <String, AdminProviderStatus>{},
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LibraryAddDialog(
              type: moviesLibraryConfig,
              autoLookupInitialBarcode: false,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Manual'));
    await pumpUntilSettled(tester);

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Physical format',
      ),
      'Digital',
    );
    await pumpUntilSettled(tester);

    expect(
      find.text(
        'Owned copies created from this draft will be saved as Digital copy.',
      ),
      findsOneWidget,
    );
  });
}
