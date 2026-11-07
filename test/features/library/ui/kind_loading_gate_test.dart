import 'package:collectarr_app/features/library/ui/kind_loading_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget gate(String kind, List<String> built) => MaterialApp(
        home: Scaffold(
          body: LibraryKindLoadingGate(
            kind: kind,
            builder: (_) {
              built.add(kind);
              return Text('page $kind');
            },
          ),
        ),
      );

  testWidgets('each kind shows the loading screen before its page',
      (tester) async {
    final built = <String>[];
    await tester.pumpWidget(gate('comic', built));
    expect(find.text('Loading...'), findsOneWidget);
    expect(built, isEmpty);

    await tester.pump();
    expect(find.text('page comic'), findsOneWidget);
    expect(find.text('Loading...'), findsNothing);

    await tester.pumpWidget(gate('game', built));
    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('page comic'), findsNothing);

    await tester.pump();
    expect(find.text('page game'), findsOneWidget);
    expect(built, ['comic', 'game']);
  });

  testWidgets('rebuilding the same kind keeps its page', (tester) async {
    final built = <String>[];
    await tester.pumpWidget(gate('comic', built));
    await tester.pump();
    await tester.pumpWidget(gate('comic', built));
    expect(find.text('page comic'), findsOneWidget);
    expect(find.text('Loading...'), findsNothing);
  });

  testWidgets('switching away before the page builds skips it', (tester) async {
    final built = <String>[];
    await tester.pumpWidget(gate('comic', built));
    await tester.pumpWidget(gate('game', built));
    await tester.pump();
    expect(built, ['game']);
  });
}
