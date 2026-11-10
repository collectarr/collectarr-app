import 'package:collectarr_app/features/library/edit/covers/editor.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/covers_tab.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/audio_length_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Books back cover remove and restore keep the front cover',
      (tester) async {
    String? front;
    String? back;
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: BookCoversTab(
          images: const [],
          coverImageUrl: 'https://example.invalid/front.webp',
          originalCoverImageUrl: 'https://example.invalid/front.webp',
          backCoverImageUrl: 'https://example.invalid/back.webp',
          originalBackCoverImageUrl: 'https://example.invalid/back.webp',
          onCoverImageUrlChanged: (value) => front = value,
          onBackCoverImageUrlChanged: (value) => back = value,
          onEdits: (_) {},
          searchTitle: () => 'Book'),
    ))));
    LibraryCoverEditor panel() => tester
        .widgetList<LibraryCoverEditor>(find.byType(LibraryCoverEditor))
        .singleWhere((item) => item.title == 'Back Cover');
    expect(panel().coreCoverUrl, 'https://example.invalid/back.webp');
    panel().onRemoveCoreCover();
    await tester.pump();
    expect(back, '');
    expect(front, isNull);
    panel().onRestoreCoreCover();
    await tester.pump();
    expect(back, 'https://example.invalid/back.webp');
    expect(front, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Books audiobook length converts hours and validates minutes',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    int? saved;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Form(
                key: formKey,
                child: BookAudioLengthField(
                    minutes: 95, onChanged: (value) => saved = value)))));
    final inputs = find.byType(TextFormField);
    expect(tester.widget<TextFormField>(inputs.first).controller!.text, '1');
    expect(tester.widget<TextFormField>(inputs.last).controller!.text, '35');
    await tester.enterText(inputs.first, '2');
    expect(saved, 155);
    await tester.enterText(inputs.last, '70');
    expect(formKey.currentState!.validate(), isFalse);
    await tester.enterText(inputs.last, '0');
    expect(formKey.currentState!.validate(), isTrue);
    expect(saved, 120);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
