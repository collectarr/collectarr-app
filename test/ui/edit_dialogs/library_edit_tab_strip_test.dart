import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('material tab bar reordering keeps logical view order stable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: _MaterialTabBarHarness()),
    );

    expect(find.text('Main tab content'), findsOneWidget);
    expect(find.text('Details tab content'), findsNothing);

    final detailsLabel = find.text('Details').first;
    final mainLabel = find.text('Main').first;
    final gesture = await tester.startGesture(tester.getCenter(detailsLabel));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveTo(tester.getCenter(mainLabel));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(detailsLabel).dx,
      lessThan(tester.getTopLeft(mainLabel).dx),
    );
    expect(find.text('Main tab content'), findsOneWidget);

    await tester.tap(detailsLabel);
    await tester.pumpAndSettle();

    expect(find.text('Details tab content'), findsOneWidget);
    expect(find.text('Main tab content'), findsNothing);
  });
}

class _MaterialTabBarHarness extends StatefulWidget {
  @override
  State<_MaterialTabBarHarness> createState() => _MaterialTabBarHarnessState();
}

class _MaterialTabBarHarnessState extends State<_MaterialTabBarHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late final List<Widget> _tabs = List<Widget>.of(const [
    Tab(child: EditTab(icon: Icons.info_outline, label: 'Main')),
    Tab(child: EditTab(icon: Icons.tune, label: 'Details')),
  ]);
  late final List<Widget> _views = List<Widget>.of(const [
    SizedBox.expand(child: Text('Main tab content')),
    SizedBox.expand(child: Text('Details tab content')),
  ]);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onReorderItem(int oldIndex, int newIndex) {
    final currentTab = _tabs[_tabController.index];
    setState(() {
      final movedTab = _tabs.removeAt(oldIndex);
      _tabs.insert(newIndex, movedTab);
      final movedView = _views.removeAt(oldIndex);
      _views.insert(newIndex, movedView);
    });
    final nextIndex = _tabs.indexOf(currentTab);
    if (nextIndex >= 0) {
      _tabController.index = nextIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LibraryEditMaterialTabBar(
            accent: Colors.teal,
            tabs: _tabs,
            tabController: _tabController,
            allowReorder: true,
            onReorderItem: _onReorderItem,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _views,
            ),
          ),
        ],
      ),
    );
  }
}
