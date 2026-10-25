import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows a description that may carry the light HTML of the reference's
/// Description fields: `<b>`/`<strong>`, `<i>`/`<em>`, `<u>`, `<br>` and
/// `<p>`, plus the common entities. Other tags are dropped and their text
/// kept. Text without any of these tags is shown as written, line breaks
/// included.
class AppFormattedText extends StatelessWidget {
  const AppFormattedText(
    this.source, {
    super.key,
    this.style,
    this.textAlign,
  });

  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(children: parseAppFormattedText(source)),
        style: style,
        textAlign: textAlign,
      );
}

final _tag = RegExp(r'<\s*(/?)\s*([a-zA-Z][a-zA-Z0-9]*)[^>]*?(/?)\s*>');
final _knownTag =
    RegExp(r'<\s*/?\s*(b|strong|i|em|u|br|p)\b[^>]*>', caseSensitive: false);
final _entity = RegExp(r'&(#x[0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+);');
const _entities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'ndash': '–',
  'mdash': '—',
  'hellip': '…',
  'rsquo': '’',
  'lsquo': '‘',
  'rdquo': '”',
  'ldquo': '“',
};

/// The spans of [source]; see [AppFormattedText] for what is understood.
List<TextSpan> parseAppFormattedText(String source) {
  if (!_knownTag.hasMatch(source)) {
    return [TextSpan(text: _decodeEntities(source))];
  }
  final spans = <TextSpan>[];
  var bold = 0;
  var italic = 0;
  var underline = 0;
  final buffer = StringBuffer();
  // HTML whitespace: runs collapse to one space, and a break swallows the
  // spaces around it so source line wrapping does not indent lines.
  var atLineStart = true;

  void flush() {
    if (buffer.isEmpty) return;
    spans.add(TextSpan(
      text: buffer.toString(),
      style: TextStyle(
        fontWeight: bold > 0 ? FontWeight.bold : null,
        fontStyle: italic > 0 ? FontStyle.italic : null,
        decoration: underline > 0 ? TextDecoration.underline : null,
      ),
    ));
    buffer.clear();
  }

  void addText(String raw) {
    final text = _decodeEntities(raw.replaceAll(RegExp(r'\s+'), ' '));
    for (final char in text.split('')) {
      if (char == ' ' && (atLineStart || _endsWithSpace(buffer, spans))) {
        continue;
      }
      buffer.write(char);
      atLineStart = false;
    }
  }

  void lineBreak() {
    _trimTrailingSpace(buffer);
    buffer.write('\n');
    atLineStart = true;
  }

  var index = 0;
  for (final match in _tag.allMatches(source)) {
    addText(source.substring(index, match.start));
    index = match.end;
    final closing = match.group(1) == '/';
    final name = match.group(2)!.toLowerCase();
    switch (name) {
      case 'br':
        lineBreak();
      case 'p':
        if (!closing && !_isEmptyOrEndsWithBlankLine(buffer, spans)) {
          lineBreak();
          lineBreak();
        }
      case 'b' || 'strong':
        flush();
        bold = closing ? math.max(0, bold - 1) : bold + 1;
      case 'i' || 'em':
        flush();
        italic = closing ? math.max(0, italic - 1) : italic + 1;
      case 'u':
        flush();
        underline = closing ? math.max(0, underline - 1) : underline + 1;
    }
  }
  addText(source.substring(index));
  // Trailing breaks would leave blank lines under the text.
  final tail = buffer.toString().trimRight();
  buffer
    ..clear()
    ..write(tail);
  flush();
  return spans;
}

bool _endsWithSpace(StringBuffer buffer, List<TextSpan> spans) {
  final last = buffer.isNotEmpty
      ? buffer.toString()
      : spans.isEmpty
          ? ''
          : spans.last.text ?? '';
  return last.endsWith(' ') || last.endsWith('\n');
}

bool _isEmptyOrEndsWithBlankLine(StringBuffer buffer, List<TextSpan> spans) {
  final text = '${spans.map((span) => span.text).join()}$buffer';
  return text.trim().isEmpty || text.endsWith('\n\n');
}

void _trimTrailingSpace(StringBuffer buffer) {
  final text = buffer.toString();
  if (!text.endsWith(' ')) return;
  buffer
    ..clear()
    ..write(text.replaceFirst(RegExp(r' +$'), ''));
}

String _decodeEntities(String text) => text.replaceAllMapped(_entity, (m) {
      final name = m.group(1)!;
      if (name.startsWith('#x') || name.startsWith('#X')) {
        final code = int.tryParse(name.substring(2), radix: 16);
        return code == null ? m.group(0)! : String.fromCharCode(code);
      }
      if (name.startsWith('#')) {
        final code = int.tryParse(name.substring(1));
        return code == null ? m.group(0)! : String.fromCharCode(code);
      }
      return _entities[name.toLowerCase()] ?? m.group(0)!;
    });
