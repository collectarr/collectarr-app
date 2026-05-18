import 'package:collectarr_app/features/comics/comics_add_bottom_bar.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('owned target shows defaults on the same control row',
      (tester) async {
    final storageController = TextEditingController();
    addTearDown(storageController.dispose);

    await tester.pumpWidget(
      _host(
        addTarget: LibraryAddTarget.owned,
        storageController: storageController,
      ),
    );

    expect(find.text('Add as owned'), findsOneWidget);
    expect(find.text('Owned defaults'), findsOneWidget);
    expect(find.text('Near Mint'), findsOneWidget);
    expect(find.text('Ungraded'), findsOneWidget);
    final storageBoxField = find.widgetWithText(TextField, 'Storage box');
    expect(storageBoxField, findsOneWidget);
    expect(
      tester.widget<TextField>(storageBoxField).textAlign,
      TextAlign.center,
    );
    expect(tester.widget<TextField>(storageBoxField).expands, isTrue);
    expect(find.byType(DropdownButtonFormField), findsNothing);
  });

  testWidgets('wishlist target hides owned defaults', (tester) async {
    final storageController = TextEditingController();
    addTearDown(storageController.dispose);

    await tester.pumpWidget(
      _host(
        addTarget: LibraryAddTarget.wishlist,
        storageController: storageController,
      ),
    );

    expect(find.text('Add to wishlist'), findsOneWidget);
    expect(find.text('Owned defaults'), findsNothing);
    expect(find.widgetWithText(TextField, 'Storage box'), findsNothing);
    expect(find.byType(DropdownButtonFormField), findsNothing);
  });
}

Widget _host({
  required LibraryAddTarget addTarget,
  required TextEditingController storageController,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 1040,
          child: AddComicBottomBar(
            selectedItem: null,
            selectedCandidate: null,
            selectedIsOwned: false,
            selectedIsWishlisted: false,
            proposalProviderLabel: 'GCD',
            proposalCount: 0,
            addTarget: addTarget,
            addCount: 1,
            isSubmitting: false,
            defaultCondition: 'Near Mint',
            defaultGrade: 'Ungraded',
            defaultStorageBoxController: storageController,
            defaultPurchaseDate: null,
            onAddTargetChanged: (_) {},
            onDefaultConditionChanged: (_) {},
            onDefaultGradeChanged: (_) {},
            onDefaultPurchaseDateChanged: (_) {},
            onAdd: () {},
            onPropose: null,
          ),
        ),
      ),
    ),
  );
}
