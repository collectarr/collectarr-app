import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _text(List<AppFormattedBlock> blocks) =>
    blocks.map((block) => block.text).join('|');

List<TextSpan> _spans(List<AppFormattedBlock> blocks) =>
    [for (final block in blocks) ...block.spans];

void main() {
  test('plain text keeps its own line breaks and literal brackets', () {
    final spans = parseAppFormattedText('Line one\n\n  Line <two> & co');
    expect(_text(spans), 'Line one\n\n  Line <two> & co');
  });

  test('reference markup renders bold headings and breaks', () {
    // The shape of a reference Games description.
    const source = '<b>Control the rage</b>\n<br/><br/>\n'
        'The God of War has changed&hellip; and this is not the Kratos.\n'
        '<br/><br/>\n<b>A dangerous new era</b><br/>\n'
        'This startling reimagining&nbsp;deconstructs it.\n  <br/><br/>';
    final spans = parseAppFormattedText(source);

    expect(
      _text(spans),
      'Control the rage\n\n'
      'The God of War has changed… and this is not the Kratos.\n\n'
      'A dangerous new era\n'
      'This startling reimagining deconstructs it.',
    );
    final bold = [
      for (final span in _spans(spans))
        if (span.style?.fontWeight == FontWeight.bold) span.text,
    ];
    expect(bold, ['Control the rage', 'A dangerous new era']);
  });

  test('italic, underline, paragraphs and unknown tags', () {
    final spans = parseAppFormattedText(
        '<p>One <i>two</i> <u>three</u></p><p><span>Four</span> &amp; 5</p>');

    expect(_text(spans), 'One two three\n\nFour & 5');
    expect(_spans(spans).firstWhere((s) => s.text == 'two').style?.fontStyle,
        FontStyle.italic);
    expect(_spans(spans).firstWhere((s) => s.text == 'three').style?.decoration,
        TextDecoration.underline);
  });

  test('bullet lists become indented items after the text', () {
    // A reference Games description, shortened.
    const source = 'The best-selling LEGO Batman videogame franchise returns!  '
        "Now the heroes must unite before it's too late.  \n"
        '<br /><br />\n<ul>\n'
        '   <li><b>Exciting space combat</b> - For the first time ever, '
        'battle in outer space. </li>\n'
        '   <li><b>Hack computer terminals</b> - Enter a virtual world.</li>\n'
        '</ul>';
    final blocks = parseAppFormattedText(source);

    expect(blocks.map((block) => block.marker), [null, '•', '•']);
    expect(blocks.map((block) => block.depth), [0, 1, 1]);
    expect(
        _text(blocks),
        "The best-selling LEGO Batman videogame franchise returns! Now the "
        "heroes must unite before it's too late.|"
        'Exciting space combat - For the first time ever, battle in outer '
        'space.|'
        'Hack computer terminals - Enter a virtual world.');
    expect(blocks[1].spans.first.text, 'Exciting space combat');
    expect(blocks[1].spans.first.style?.fontWeight, FontWeight.bold);
  });

  test('numbered and nested lists', () {
    final blocks = parseAppFormattedText(
        '<ol><li>One</li><li>Two<ul><li>Inner</li></ul></li><li>Three</li></ol>'
        'After');

    expect(blocks.map((block) => block.marker), ['1.', '2.', '•', '3.', null]);
    expect(blocks.map((block) => block.depth), [1, 1, 2, 1, 0]);
    expect(_text(blocks), 'One|Two|Inner|Three|After');
  });

  testWidgets('items show their bullet beside the text', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          child: AppFormattedText(
              'Intro<ul><li>First item</li><li>Second item</li></ul>'),
        ),
      ),
    ));

    expect(find.text('•'), findsNWidgets(2));
    final bullet = tester.getTopLeft(find.text('•').first);
    final item = tester.getTopLeft(find.text('First item'));
    expect(item.dx, 40);
    expect(bullet.dx, lessThan(item.dx));
    expect(bullet.dy, item.dy);
    expect(tester.getTopLeft(find.text('Intro')).dy, lessThan(bullet.dy));
  });
}
