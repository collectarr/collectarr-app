import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _text(List<TextSpan> spans) => spans.map((span) => span.text).join();

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
      for (final span in spans)
        if (span.style?.fontWeight == FontWeight.bold) span.text,
    ];
    expect(bold, ['Control the rage', 'A dangerous new era']);
  });

  test('italic, underline, paragraphs and unknown tags', () {
    final spans = parseAppFormattedText(
        '<p>One <i>two</i> <u>three</u></p><p><span>Four</span> &amp; 5</p>');

    expect(_text(spans), 'One two three\n\nFour & 5');
    expect(spans.firstWhere((s) => s.text == 'two').style?.fontStyle,
        FontStyle.italic);
    expect(spans.firstWhere((s) => s.text == 'three').style?.decoration,
        TextDecoration.underline);
  });
}
