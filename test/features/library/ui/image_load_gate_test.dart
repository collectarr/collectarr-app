import 'package:collectarr_app/features/library/ui/image_load_gate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settles once every registered cover is in', (tester) async {
    final loads = LibraryImageLoads();
    addTearDown(loads.dispose);
    loads.expect('front');
    loads.expect('back');
    await tester.pumpWidget(const SizedBox());
    expect(loads.settled, isFalse);

    loads.done('front');
    await tester.pump();
    expect(loads.settled, isFalse);
    loads.done('back');
    await tester.pump();
    expect(loads.settled, isTrue);

    // A cover that rebuilds after it is in does not wait again.
    loads.expect('front');
    expect(loads.settled, isTrue);
  });

  testWidgets('waits for pending data reported under the gate', (tester) async {
    final loads = LibraryImageLoads();
    addTearDown(loads.dispose);
    var pending = true;
    late StateSetter rebuild;
    await tester.pumpWidget(LibraryImageLoadGate(
      loads: loads,
      child: StatefulBuilder(builder: (context, setState) {
        rebuild = setState;
        reportLibraryPanelLoad(context, 'label', pending: pending);
        return const SizedBox();
      }),
    ));
    await tester.pump();
    expect(loads.settled, isFalse);

    rebuild(() => pending = false);
    await tester.pump();
    expect(loads.settled, isTrue);
  });

  testWidgets('stops waiting for a slow cover after the timeout',
      (tester) async {
    final loads = LibraryImageLoads(timeout: const Duration(seconds: 2));
    addTearDown(loads.dispose);
    loads.expect('front');
    await tester.pumpWidget(const SizedBox());
    expect(loads.settled, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(loads.settled, isTrue);
  });
}
