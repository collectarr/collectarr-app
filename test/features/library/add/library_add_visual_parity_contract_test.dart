import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_manual_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/ui/library_chrome_tokens.dart';
import 'package:collectarr_app/features/library/ui/library_density_scope.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all active kinds render Add manual parity matrix',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    expect(collectarrKindModules, hasLength(9));
    for (final runtime in collectarrKindModules) {
      final manualDraft = LibraryAddManualDraft(
        customFieldValues: const [],
        itemImages: const [],
        kindDraft: runtime.add.createManualDraft(),
      );
      final request = LibraryAddManualPaneRequest(
        kind: runtime.kind,
        accent: runtime.identity.accent,
        type: runtime,
        commonDraft: const LibraryAddCommonDraft(),
        kindDraft: null,
        manualDraft: manualDraft.kindDraft,
        titleController: manualDraft.titleController,
        tagsController: manualDraft.tagsController,
        personalNotesController: manualDraft.personalNotesController,
        coverPriceController: manualDraft.coverPriceController,
        priceController: manualDraft.priceController,
        purchaseDateController: manualDraft.purchaseDateController,
        purchaseStoreController: manualDraft.purchaseStoreController,
        sellPriceController: manualDraft.sellPriceController,
        soldDateController: manualDraft.soldDateController,
        ownerLabelController: manualDraft.ownerLabelController,
        linksController: manualDraft.linksController,
        isAdding: false,
        defaultCondition: runtime.edit.defaultCondition,
        defaultGrade: runtime.edit.defaultGrade,
        defaultLocationLabel: null,
        defaultPurchaseDate: null,
        defaultTags: null,
        onAddOwned: () {},
        onAddWishlist: () {},
        onAddTrack: () {},
      );
      for (final density in LibraryDensity.values) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localDatabaseProvider.overrideWithValue(db),
              mediaCatalogProvider.overrideWith(
                (ref) async => fallbackMediaCatalog,
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 1200,
                  height: 900,
                  child: _AddManualParityHarness(
                    runtime: runtime,
                    request: request,
                    density: density,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(LibraryAddManualActionBar), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      manualDraft.dispose();
    }
  });
}

class _AddManualParityHarness extends StatelessWidget {
  const _AddManualParityHarness({
    required this.runtime,
    required this.request,
    required this.density,
  });

  final LibraryKindRuntime runtime;
  final LibraryAddManualPaneRequest request;
  final LibraryDensity density;

  @override
  Widget build(BuildContext context) {
    return LibraryDensityScope(
      density: density,
      child: runtime.add.buildManualPane(context, request),
    );
  }
}
