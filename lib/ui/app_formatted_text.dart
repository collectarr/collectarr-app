import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows a description that may carry the light HTML of the reference's
/// Description fields: `<b>`/`<strong>`, `<i>`/`<em>`, `<u>`, `<br>`, `<p>`
/// and `<ul>`/`<ol>` lists of `<li>` items, plus the common entities. Other
/// tags are dropped and their text kept. Text without any of these tags is
/// shown as written, line breaks included.
///
/// As in a browser, list items are indented 40 px per level with their
/// bullet or number before them, wrapped lines stay under the item's text,
/// and a list is set off from the text around it by a blank line.
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

  static const double _listIndent = 40;
  static const double _markerGap = 6;

  @override
  Widget build(BuildContext context) {
    final blocks = parseAppFormattedText(source);
    if (blocks.length == 1 && blocks.single.marker == null) {
      return Text.rich(TextSpan(children: blocks.single.spans),
          style: style, textAlign: textAlign);
    }
    final effective = DefaultTextStyle.of(context).style.merge(style);
    final lineGap = (effective.fontSize ?? 14) * (effective.height ?? 1.2);
    final children = <Widget>[];
    for (final (index, block) in blocks.indexed) {
      final previous = index == 0 ? null : blocks[index - 1];
      if (previous != null &&
          (previous.marker == null) != (block.marker == null)) {
        children.add(SizedBox(height: lineGap));
      }
      final text = Text.rich(TextSpan(children: block.spans),
          style: style, textAlign: textAlign);
      final marker = block.marker;
      children.add(marker == null
          ? text
          : Padding(
              padding: EdgeInsets.only(left: _listIndent * (block.depth - 1)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: _listIndent,
                  child: Padding(
                    padding: const EdgeInsets.only(right: _markerGap),
                    child:
                        Text(marker, style: style, textAlign: TextAlign.right),
                  ),
                ),
                Expanded(child: text),
              ]),
            ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// A paragraph of [AppFormattedText], or a list item when it has a [marker].
final class AppFormattedBlock {
  const AppFormattedBlock(this.spans, {this.marker, this.depth = 0});

  final List<TextSpan> spans;

  /// `•` for a bullet item or `1.` for a numbered one; null for a paragraph.
  final String? marker;

  /// The list nesting level of an item, from 1.
  final int depth;

  String get text => spans.map((span) => span.text).join();
}

final _tag = RegExp(r'<\s*(/?)\s*([a-zA-Z][a-zA-Z0-9]*)[^>]*?(/?)\s*>');
final _knownTag = RegExp(r'<\s*/?\s*(b|strong|i|em|u|br|p|ul|ol|li)\b[^>]*>',
    caseSensitive: false);
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
  'bull': '•',
};

/// The blocks of [source]; see [AppFormattedText] for what is understood.
List<AppFormattedBlock> parseAppFormattedText(String source) {
  if (!_knownTag.hasMatch(source)) {
    return [
      AppFormattedBlock([TextSpan(text: _decodeEntities(source))]),
    ];
  }
  final blocks = <AppFormattedBlock>[];
  var spans = <TextSpan>[];
  String? marker;
  var depth = 0;
  // Each open list: null for a bullet list, the next number for a numbered
  // one.
  final lists = <int?>[];
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

  // Ends the current paragraph or item. Breaks at its edges would only add
  // blank lines, so they are dropped.
  void endBlock() {
    final tail = buffer.toString().trimRight();
    buffer
      ..clear()
      ..write(tail);
    flush();
    while (spans.isNotEmpty && (spans.last.text ?? '').trim().isEmpty) {
      spans.removeLast();
    }
    if (spans.isNotEmpty) {
      final last = spans.removeLast();
      spans.add(TextSpan(text: last.text!.trimRight(), style: last.style));
    }
    while (spans.isNotEmpty && (spans.first.text ?? '').trim().isEmpty) {
      spans.removeAt(0);
    }
    if (spans.isNotEmpty) {
      final first = spans.removeAt(0);
      spans.insert(
          0, TextSpan(text: first.text!.trimLeft(), style: first.style));
    }
    if (spans.isNotEmpty || marker != null) {
      blocks.add(AppFormattedBlock(spans, marker: marker, depth: depth));
    }
    spans = <TextSpan>[];
    marker = null;
    depth = 0;
    atLineStart = true;
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
      case 'ul' || 'ol':
        endBlock();
        if (closing) {
          if (lists.isNotEmpty) lists.removeLast();
        } else {
          lists.add(name == 'ol' ? 1 : null);
        }
      case 'li':
        endBlock();
        if (!closing) {
          if (lists.isEmpty) lists.add(null);
          final number = lists.last;
          if (number != null) lists[lists.length - 1] = number + 1;
          marker = number == null ? '•' : '$number.';
          depth = lists.length;
        }
    }
  }
  addText(source.substring(index));
  endBlock();
  return blocks;
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
