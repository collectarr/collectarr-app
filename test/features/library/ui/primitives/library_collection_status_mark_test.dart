import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_collection_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<(Icon, BoxDecoration?)> _mark(
  WidgetTester tester,
  LibraryCollectionStatusScope status, {
  LibraryCollectionStatusMarkStyle style = LibraryCollectionStatusMarkStyle.row,
  bool onSelection = false,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Center(
      child: LibraryCollectionStatusMark(
          collectionStatus: status, style: style, onSelection: onSelection),
    ),
  ));
  final container = tester.widget<Container>(find.descendant(
      of: find.byType(LibraryCollectionStatusMark),
      matching: find.byType(Container)));
  return (
    tester.widget<Icon>(find.byType(Icon)),
    container.decoration as BoxDecoration?,
  );
}

void main() {
  testWidgets('In Collection is a bare tick, white on the selected row',
      (tester) async {
    var (icon, box) =
        await _mark(tester, LibraryCollectionStatusScope.inCollection);
    expect(box, isNull);
    expect(icon.color, LibraryCollectionStatusScope.inCollection.color);
    (icon, box) = await _mark(tester, LibraryCollectionStatusScope.inCollection,
        onSelection: true);
    expect(icon.color, Colors.white);
  });

  testWidgets('other statuses are white glyphs on their colour',
      (tester) async {
    final (icon, box) = await _mark(
        tester, LibraryCollectionStatusScope.wishList,
        onSelection: true);
    expect(box!.color, LibraryCollectionStatusScope.wishList.color);
    expect(icon.color, Colors.white);
  });

  testWidgets('covers outline a white tick and horizontal cards fill it',
      (tester) async {
    var (icon, box) = await _mark(
        tester, LibraryCollectionStatusScope.inCollection,
        style: LibraryCollectionStatusMarkStyle.cover);
    expect(box, isNull);
    expect(icon.color, Colors.white);
    expect(icon.shadows, isNotEmpty);
    (icon, box) = await _mark(tester, LibraryCollectionStatusScope.inCollection,
        style: LibraryCollectionStatusMarkStyle.pill);
    expect(box!.color, LibraryCollectionStatusScope.inCollection.color);
  });
}
