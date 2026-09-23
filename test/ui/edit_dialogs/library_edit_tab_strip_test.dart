import 'package:collectarr_app/features/library/edit/fields/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/edit/library_edit_tab_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('tab order persistence round-trips and rejects invalid orders',
      () async {
    SharedPreferences.setMockInitialValues({});

    await saveLibraryEditTabOrder(
      storageKey: 'edit-tabs',
      order: [2, 0, 1],
    );
    expect(
      await loadLibraryEditTabOrder(storageKey: 'edit-tabs', tabCount: 3),
      [2, 0, 1],
    );

    SharedPreferences.setMockInitialValues({
      'edit-tabs': ['0', '0', '1'],
    });
    expect(
      await loadLibraryEditTabOrder(storageKey: 'edit-tabs', tabCount: 3),
      isNull,
    );
  });

  testWidgets('callback-backed reorderable strip preserves selected tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: _CallbackTabStripHarness()),
    );

    expect(find.text('Main tab content'), findsOneWidget);
    final detailsLabel = find.text('Details').first;
    final mainLabel = find.text('Main').first;
    final gesture = await tester.startGesture(tester.getCenter(detailsLabel));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveTo(tester.getCenter(mainLabel));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Main tab content'), findsOneWidget);
    expect(
      tester.getTopLeft(detailsLabel).dx,
      lessThan(tester.getTopLeft(mainLabel).dx),
    );
  });

  testWidgets(
    'controller-backed reorderable strip keeps logical view order stable',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: _ControllerTabStripHarness()),
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
    },
  );
}

class _CallbackTabStripHarness extends StatefulWidget {
  @override
  State<_CallbackTabStripHarness> createState() =>
      _CallbackTabStripHarnessState();
}

class _CallbackTabStripHarnessState extends State<_CallbackTabStripHarness> {
  var _selectedIndex = 0;
  var _mainIndex = 0;
  final _tabs = <Widget>[
    const EditTab(icon: Icons.info_outline, label: 'Main'),
    const EditTab(icon: Icons.tune, label: 'Details'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LibraryEditReorderableTabStrip(
            accent: Colors.teal,
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onSelect: (index) => setState(() => _selectedIndex = index),
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                final selectedTab = _tabs[_selectedIndex];
                final tab = _tabs.removeAt(oldIndex);
                _tabs.insert(newIndex, tab);
                _selectedIndex = _tabs.indexOf(selectedTab);
                if (_mainIndex == oldIndex) {
                  _mainIndex = newIndex;
                } else if (oldIndex < _mainIndex && newIndex >= _mainIndex) {
                  _mainIndex--;
                } else if (oldIndex > _mainIndex && newIndex <= _mainIndex) {
                  _mainIndex++;
                }
              });
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                _selectedIndex == _mainIndex
                    ? 'Main tab content'
                    : 'Details tab content',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControllerTabStripHarness extends StatefulWidget {
  @override
  State<_ControllerTabStripHarness> createState() =>
      _ControllerTabStripHarnessState();
}

class _ControllerTabStripHarnessState extends State<_ControllerTabStripHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  late final List<Widget> _tabs = List<Widget>.of(const [
    EditTab(icon: Icons.info_outline, label: 'Main'),
    EditTab(icon: Icons.tune, label: 'Details'),
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
          LibraryEditReorderableTabStrip(
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
