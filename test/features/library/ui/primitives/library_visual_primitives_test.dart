import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Size size = const Size(800, 600)}) {
  return MaterialApp(
    theme: buildLibraryTheme(),
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('LibraryTextTheme Extension Tests', () {
    testWidgets('semantic text style tokens are accessible and structured', (tester) async {
      late TextTheme theme;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              theme = context.libraryTextTheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(theme.panelTitle.fontWeight, FontWeight.w800);
      expect(theme.sectionTitle.fontWeight, FontWeight.w800);
      expect(theme.metadataLabel.fontWeight, FontWeight.w700);
      expect(theme.supportingText, isNotNull);
      expect(theme.tableHeader.fontWeight, FontWeight.w800);
    });
  });

  group('LibraryFormSection Tests', () {
    testWidgets('renders title, icon, trailing, and child', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LibraryFormSection(
            title: 'General Details',
            icon: Icons.book,
            accent: Colors.blue,
            trailing: Text('Optional'),
            child: Text('Form Content'),
          ),
        ),
      );

      expect(find.text('General Details'), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Form Content'), findsOneWidget);
    });
  });

  group('LibraryResponsiveFormRow Tests', () {
    testWidgets('lays out horizontally when width >= breakpoint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LibraryResponsiveFormRow(
            breakpoint: 500,
            children: [
              LibraryResponsiveFormItem(
                flex: 2,
                child: Text('First Field'),
              ),
              LibraryResponsiveFormItem(
                flex: 1,
                child: Text('Second Field'),
              ),
            ],
          ),
          size: const Size(600, 300),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
      expect(find.text('First Field'), findsOneWidget);
      expect(find.text('Second Field'), findsOneWidget);
    });

    testWidgets('stacks vertically when width < breakpoint', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LibraryResponsiveFormRow(
            breakpoint: 500,
            children: [
              LibraryResponsiveFormItem(
                flex: 2,
                child: Text('First Field'),
              ),
              LibraryResponsiveFormItem(
                flex: 1,
                child: Text('Second Field'),
              ),
            ],
          ),
          size: const Size(400, 300),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('First Field'), findsOneWidget);
      expect(find.text('Second Field'), findsOneWidget);
    });
  });

  group('LibraryInfoPanel Tests', () {
    testWidgets('renders title, message, and action', (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        _wrap(
          LibraryInfoPanel(
            title: 'Provider Notice',
            message: 'Data sourced from external catalog.',
            variant: LibraryInfoPanelVariant.warning,
            action: TextButton(
              onPressed: () => actionTapped = true,
              child: const Text('Details'),
            ),
          ),
        ),
      );

      expect(find.text('Provider Notice'), findsOneWidget);
      expect(find.text('Data sourced from external catalog.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      await tester.tap(find.text('Details'));
      expect(actionTapped, isTrue);
    });
  });

  group('LibraryActionFooter Tests', () {
    testWidgets('renders cancel and submit actions with callbacks', (tester) async {
      var cancelled = false;
      var submitted = false;

      await tester.pumpWidget(
        _wrap(
          LibraryActionFooter(
            onCancel: () => cancelled = true,
            onSubmit: () => submitted = true,
            cancelLabel: 'Discard',
            submitLabel: 'Save Changes',
            submitIcon: Icons.check,
          ),
        ),
      );

      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Discard'));
      expect(cancelled, isTrue);

      await tester.tap(find.text('Save Changes'));
      expect(submitted, isTrue);
    });

    testWidgets('disables actions and shows progress indicator when loading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          LibraryActionFooter(
            onCancel: () {},
            onSubmit: () {},
            isLoading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final outlinedBtn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(outlinedBtn.onPressed, isNull);
      final filledBtn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(filledBtn.onPressed, isNull);
    });
  });

  group('LibraryPanelHeader Tests', () {
    testWidgets('renders title, subtitle, icon, close, and back buttons', (tester) async {
      var closed = false;
      var backed = false;

      await tester.pumpWidget(
        _wrap(
          LibraryPanelHeader(
            title: 'Edit Item',
            subtitle: 'Volume 1 (2024)',
            onBack: () => backed = true,
            onClose: () => closed = true,
            trailing: const Text('Badge'),
          ),
        ),
      );

      expect(find.text('Edit Item'), findsOneWidget);
      expect(find.text('Volume 1 (2024)'), findsOneWidget);
      expect(find.text('Badge'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backed, isTrue);

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });
  });

  group('LibraryEmptyVisualState Tests', () {
    testWidgets('renders empty state with primary and secondary actions', (tester) async {
      var primaryAction = false;
      var secondaryAction = false;

      await tester.pumpWidget(
        _wrap(
          LibraryEmptyVisualState(
            icon: Icons.inventory_2_outlined,
            title: 'No items found',
            message: 'Try adjusting your search criteria.',
            actionLabel: 'Add New',
            onAction: () => primaryAction = true,
            secondaryActionLabel: 'Reset Filters',
            onSecondaryAction: () => secondaryAction = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Try adjusting your search criteria.'), findsOneWidget);
      expect(find.text('Add New'), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      await tester.tap(find.text('Add New'));
      expect(primaryAction, isTrue);

      await tester.tap(find.text('Reset Filters'));
      expect(secondaryAction, isTrue);
    });
  });

  group('LibraryErrorState Tests', () {
    testWidgets('renders error message and retry button', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        _wrap(
          LibraryErrorState(
            title: 'Failed to Load',
            message: 'Network connection timeout.',
            details: 'HTTP 504 Gateway Timeout',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to Load'), findsOneWidget);
      expect(find.text('Network connection timeout.'), findsOneWidget);
      expect(find.text('HTTP 504 Gateway Timeout'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('LibraryLoadingState Tests', () {
    testWidgets('renders progress indicator and message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LibraryLoadingState(
            message: 'Fetching catalog items...',
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Fetching catalog items...'), findsOneWidget);
    });
  });

  group('LibraryResultRow Tests', () {
    testWidgets('renders result row components and handles taps', (tester) async {
      var tapped = false;
      var doubleTapped = false;

      await tester.pumpWidget(
        _wrap(
          LibraryResultRow(
            title: 'Batman: Year One',
            subtitle: 'DC Comics (1987)',
            leading: const Icon(Icons.menu_book),
            badges: const [
              Text('TPB'),
              Text('In Library'),
            ],
            trailing: const Icon(Icons.arrow_forward_ios),
            isSelected: true,
            onTap: () => tapped = true,
            onDoubleTap: () => doubleTapped = true,
          ),
        ),
      );

      expect(find.text('Batman: Year One'), findsOneWidget);
      expect(find.text('DC Comics (1987)'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(find.text('TPB'), findsOneWidget);
      expect(find.text('In Library'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tapped, isTrue);

      await tester.tap(find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(InkWell));
      await tester.pump(const Duration(milliseconds: 500));
      expect(doubleTapped, isTrue);
    });
  });
}
