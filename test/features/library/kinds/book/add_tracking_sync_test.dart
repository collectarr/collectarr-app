import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/models/tracking_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/add/read_history.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/tracking/media_rating_field.dart';
import 'package:collectarr_app/features/library/ui/primitives/selection_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Books add keeps rating and reading history in sync',
      (tester) async {
    var tracking =
        const LibraryAddTrackingDraft(notes: 'Keep', readStatus: 'Reading');
    final draft = BookAddManualDraft();
    addTearDown(draft.dispose);
    final controllers = List.generate(8, (_) => TextEditingController());
    addTearDown(() {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
    final tags = LibraryValuesController();
    addTearDown(tags.dispose);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: StatefulBuilder(builder: (context, setState) {
      final request = LibraryAddManualPaneRequest(
          kind: CatalogMediaKind.book,
          accent: Colors.purple,
          type: const BookRegistration(),
          manualDraft: draft,
          trackingDraft: tracking,
          onTrackingDraftChanged: (value) => setState(() => tracking = value),
          tags: tags,
          personalNotesController: controllers[0],
          coverPriceController: controllers[1],
          priceController: controllers[2],
          purchaseDateController: controllers[3],
          purchaseStoreController: controllers[4],
          sellPriceController: controllers[5],
          soldDateController: controllers[6],
          ownerLabelController: controllers[7],
          isAdding: false,
          defaultCondition: '',
          defaultLocationLabel: null,
          defaultPurchaseDate: null,
          defaultTags: null,
          onAddEntry: () {},
          onAddWishlist: () {},
          onAddTrack: () {});
      return Column(children: [
        BookManualRatingField(request: request),
        Expanded(child: BookManualReadHistory(request: request))
      ]);
    }))));
    var fields = tester
        .widgetList<MediaRatingField>(find.byType(MediaRatingField))
        .toList();
    fields.first.controller.text = '8';
    await tester.pump();
    fields = tester
        .widgetList<MediaRatingField>(find.byType(MediaRatingField))
        .toList();
    expect(fields.last.controller.text, '8');
    expect(tracking.notes, 'Keep');
    fields.last.controller.text = '6';
    await tester.pump();
    fields = tester
        .widgetList<MediaRatingField>(find.byType(MediaRatingField))
        .toList();
    expect(fields.first.controller.text, '6');
    expect(tracking.readStatus, 'Reading');
    expect(tracking.notes, 'Keep');
  });
}
