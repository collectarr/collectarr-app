import 'package:collectarr_app/ui/app_formatted_text.dart';
import 'package:flutter/material.dart';

/// An inline format of [AppFormattedTextController]; [bit] marks a character.
enum AppTextMark {
  bold(1, 'b'),
  italic(2, 'i'),
  underline(4, 'u');

  const AppTextMark(this.bit, this.tag);

  final int bit;
  final String tag;
}

enum AppTextList { bullet, numbered }

/// Edits the light HTML of [AppFormattedText] as what it shows: the text field
/// holds the visible text, each character carries its marks, and [source]
/// writes them back as tags.
///
/// A list item is a line that starts with its indent, its marker and
/// [_markerEnd]. The invisible character tells a marker from typed text, so a
/// line such as "2001. A year" is never taken for a list and renumbered.
final class AppFormattedTextController extends TextEditingController {
  AppFormattedTextController([String source = '']) {
    load(source);
  }

  /// Advances when the text or a format changes, not when the caret moves.
  int get revision => _revision;
  int _revision = 0;

  List<int> _flags = const [];
  int? _pendingFlags;
  final _snapshots = <String, List<int>>{};

  static const _sentinel = '​';
  static const _markerEnd = '$_sentinel ';
  static const _bullet = '•';
  static const _indent = '    ';
  static const _snapshotLimit = 200;
  static final _marker = RegExp('^( *)($_bullet|\\d+\\.)$_markerEnd');

  /// Replaces the content with [source]; not an edit, so [revision] stays.
  void load(String source) {
    final buffer = StringBuffer();
    final flags = <int>[];
    void write(String text, [int mark = 0]) {
      buffer.write(text);
      flags.addAll(List<int>.filled(text.length, mark));
    }

    for (final (index, block) in parseAppFormattedText(source).indexed) {
      if (index > 0) write('\n');
      final marker = block.marker;
      if (marker != null) {
        write('${_indent * (block.depth - 1)}$marker$_markerEnd');
      }
      for (final span in block.spans) {
        write(span.text ?? '', _flagsOf(span.style));
      }
    }
    _flags = flags;
    _pendingFlags = null;
    _snapshots.clear();
    final text = buffer.toString();
    _remember(text);
    super.value = TextEditingValue(
        text: text, selection: TextSelection.collapsed(offset: text.length));
  }

  /// The content as light HTML. Without any format it stays plain text, line
  /// breaks included.
  String get source {
    final lines = text.split('\n');
    if (!_flags.any((flag) => flag != 0) &&
        !lines.any((line) => _marker.hasMatch(line))) {
      return _escape(text.replaceAll(_sentinel, ''));
    }
    final out = StringBuffer();
    final open = <String>[];
    var offset = 0;
    for (final (index, line) in lines.indexed) {
      final match = _marker.firstMatch(line);
      final start = offset + (match?.end ?? 0);
      final end = offset + line.length;
      if (match == null) {
        while (open.isNotEmpty) {
          out.write('</li></${open.removeLast()}>');
        }
        out.write(_inline(start, end));
        final next = index + 1 < lines.length ? lines[index + 1] : null;
        if (next != null && !_marker.hasMatch(next)) out.write('<br>');
      } else {
        final depth = match.group(1)!.length ~/ _indent.length + 1;
        final tag = match.group(2) == _bullet ? 'ul' : 'ol';
        while (open.length > depth) {
          out.write('</li></${open.removeLast()}>');
        }
        if (open.length == depth) {
          if (open.last == tag) {
            out.write('</li>');
          } else {
            out.write('</li></${open.removeLast()}>');
          }
        }
        while (open.length < depth) {
          out.write('<$tag>');
          open.add(tag);
        }
        out.write('<li>${_inline(start, end)}');
      }
      offset = end + 1;
    }
    while (open.isNotEmpty) {
      out.write('</li></${open.removeLast()}>');
    }
    return out.toString();
  }

  /// Whether the selected text, or text typed at the caret, has [mark].
  bool hasMark(AppTextMark mark) {
    final selected = _selectedCharacters();
    if (selected == null) return _caretFlags() & mark.bit != 0;
    return selected.isNotEmpty &&
        selected.every((index) => _flags[index] & mark.bit != 0);
  }

  /// Toggles [mark] on the selection, or for the next text typed at the caret.
  void toggleMark(AppTextMark mark) {
    final selected = _selectedCharacters();
    if (selected == null) {
      _pendingFlags = _caretFlags() ^ mark.bit;
      notifyListeners();
      return;
    }
    if (selected.isEmpty) return;
    final add = !hasMark(mark);
    _flags = List<int>.of(_flags);
    for (final index in selected) {
      _flags[index] =
          add ? _flags[index] | mark.bit : _flags[index] & ~mark.bit;
    }
    _remember(text);
    _revision++;
    notifyListeners();
  }

  /// Whether every selected line is an item of a [list].
  bool hasList(AppTextList list) {
    final lines = _selectedLines();
    return lines.isNotEmpty && lines.every((line) => _listOf(line.$2) == list);
  }

  /// Makes the selected lines items of a [list], or plain lines when they
  /// already are.
  void toggleList(AppTextList list) {
    final remove = hasList(list);
    final edit = _Edit(text, _flags, selection);
    for (final (start, line) in _selectedLines().reversed) {
      final match = _marker.firstMatch(line);
      final marker = remove
          ? ''
          : '${match?.group(1) ?? ''}${list == AppTextList.bullet ? _bullet : '1.'}$_markerEnd';
      edit.replace(start, start + (match?.end ?? 0), marker);
    }
    _renumber(edit);
    _commit(edit, composing: TextRange.empty);
  }

  @override
  set value(TextEditingValue next) {
    if (next.text == text) {
      if (next.selection != selection) _pendingFlags = null;
      super.value = next.copyWith(selection: _snapped(next));
      return;
    }
    // Undo and redo bring back a text this field had, with its marks. A format
    // chosen for the next typed text wins over the earlier marks.
    final snapshot = _pendingFlags == null ? _snapshots[next.text] : null;
    if (snapshot != null) {
      _flags = snapshot;
      _pendingFlags = null;
      _revision++;
      super.value = next.copyWith(selection: _snapped(next));
      return;
    }
    _commit(_applyEdit(next), composing: next.composing);
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final spans = <TextSpan>[];
    var start = 0;
    final length = text.length;
    for (var index = 1; index <= length; index++) {
      if (index < length && _flags[index] == _flags[start]) continue;
      spans.add(TextSpan(
          text: text.substring(start, index), style: _styleOf(_flags[start])));
      start = index;
    }
    return TextSpan(style: style, children: spans);
  }

  _Edit _applyEdit(TextEditingValue next) {
    final old = text;
    final caret = next.selection.isValid && next.selection.isCollapsed
        ? next.selection.start
        : next.text.length;
    // The typed text ends at the caret, so it never joins equal text after it.
    var suffix = 0;
    final maxSuffix = _min(old.length, next.text.length - caret);
    while (suffix < maxSuffix &&
        old.codeUnitAt(old.length - 1 - suffix) ==
            next.text.codeUnitAt(next.text.length - 1 - suffix)) {
      suffix++;
    }
    var prefix = 0;
    final maxPrefix = _min(old.length - suffix, next.text.length - suffix);
    while (prefix < maxPrefix &&
        old.codeUnitAt(prefix) == next.text.codeUnitAt(prefix)) {
      prefix++;
    }
    final removedEnd = old.length - suffix;
    final inserted = next.text.substring(prefix, next.text.length - suffix);
    final mark = _pendingFlags ?? _inheritedFlags(prefix);
    _pendingFlags = null;

    final edit = _Edit(old, _flags, selection);
    final lineStart = prefix == 0 ? 0 : old.lastIndexOf('\n', prefix - 1) + 1;
    final lineEnd = old.indexOf('\n', lineStart);
    final line = old.substring(lineStart, lineEnd == -1 ? old.length : lineEnd);
    final match = _marker.firstMatch(line);
    final markerEnd = lineStart + (match?.end ?? 0);

    if (inserted == '\n' &&
        removedEnd == prefix &&
        match != null &&
        prefix >= markerEnd) {
      if (markerEnd == lineStart + line.length) {
        // Enter on an empty item ends the list.
        edit
          ..replace(lineStart, markerEnd, '')
          ..selection = TextSelection.collapsed(offset: lineStart);
      } else {
        // Enter in an item starts the next one.
        final marker = '\n${line.substring(0, match.end)}';
        edit
          ..replace(prefix, prefix, marker, mark: 0)
          ..selection = TextSelection.collapsed(offset: prefix + marker.length);
      }
    } else if (inserted.isEmpty &&
        match != null &&
        prefix < markerEnd &&
        !old.substring(prefix, removedEnd).contains('\n')) {
      // Deleting into a marker removes all of it, never leaving a part.
      edit
        ..replace(lineStart, _max(markerEnd, removedEnd), '')
        ..selection = TextSelection.collapsed(offset: lineStart);
    } else {
      edit
        ..replace(prefix, removedEnd, inserted, mark: mark)
        ..selection = next.selection;
    }
    _renumber(edit);
    return edit;
  }

  void _commit(_Edit edit, {required TextRange composing}) {
    final changed = edit.text != text;
    _flags = edit.flags;
    _pendingFlags = null;
    if (changed) {
      _remember(edit.text);
      _revision++;
    }
    final next = TextEditingValue(
      text: edit.text,
      selection: edit.selection,
      // An edit that also changed the markers moved the composing range.
      composing: composing.isValid && composing.end <= edit.text.length
          ? composing
          : TextRange.empty,
    );
    super.value = next.copyWith(selection: _snapped(next));
  }

  void _remember(String snapshotText) {
    _snapshots
      ..remove(snapshotText)
      ..[snapshotText] = _flags;
    if (_snapshots.length > _snapshotLimit) {
      _snapshots.remove(_snapshots.keys.first);
    }
  }

  /// Numbers each run of numbered items at a level from 1.
  void _renumber(_Edit edit) {
    final counters = <int, int>{};
    var offset = 0;
    while (offset <= edit.text.length) {
      final end = edit.text.indexOf('\n', offset);
      final lineEnd = end == -1 ? edit.text.length : end;
      final match = _marker.firstMatch(edit.text.substring(offset, lineEnd));
      var shift = 0;
      if (match == null) {
        counters.clear();
      } else {
        final depth = match.group(1)!.length ~/ _indent.length;
        counters.removeWhere((level, _) => level > depth);
        if (match.group(2) == _bullet) {
          counters.remove(depth);
        } else {
          final number = (counters[depth] ?? 0) + 1;
          counters[depth] = number;
          final expected = '$number.';
          if (match.group(2) != expected) {
            final start = offset + match.group(1)!.length;
            edit.replace(start, start + match.group(2)!.length, expected);
            shift = expected.length - match.group(2)!.length;
          }
        }
      }
      if (end == -1) break;
      offset = lineEnd + shift + 1;
    }
  }

  /// Keeps a caret out of a marker. Moving left from an item's first character
  /// goes on to the line above instead of stopping there.
  TextSelection _snapped(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) return selection;
    final offset = selection.start;
    final lineStart =
        offset == 0 ? 0 : value.text.lastIndexOf('\n', offset - 1) + 1;
    final lineEnd = value.text.indexOf('\n', lineStart);
    final match = _marker.firstMatch(value.text
        .substring(lineStart, lineEnd == -1 ? value.text.length : lineEnd));
    if (match == null) return selection;
    final markerEnd = lineStart + match.end;
    if (offset >= markerEnd) return selection;
    final movedLeft = this.selection.isCollapsed &&
        this.selection.start == markerEnd &&
        offset == markerEnd - 1;
    return TextSelection.collapsed(
        offset: movedLeft && lineStart > 0 ? lineStart - 1 : markerEnd);
  }

  /// The selected characters outside markers and line ends; null at a caret.
  List<int>? _selectedCharacters() {
    if (!selection.isValid || selection.isCollapsed) return null;
    final indexes = <int>[];
    var offset = 0;
    for (final line in text.split('\n')) {
      final start = offset + (_marker.firstMatch(line)?.end ?? 0);
      final end = offset + line.length;
      for (var index = start; index < end; index++) {
        if (index >= selection.start && index < selection.end) {
          indexes.add(index);
        }
      }
      offset = end + 1;
    }
    return indexes;
  }

  /// The lines the selection touches, each with its start offset.
  List<(int, String)> _selectedLines() {
    if (!selection.isValid) return const [];
    final lines = <(int, String)>[];
    var offset = 0;
    for (final line in text.split('\n')) {
      final end = offset + line.length;
      final touched = selection.isCollapsed
          ? selection.start >= offset && selection.start <= end
          : selection.start <= end && selection.end > offset;
      if (touched) lines.add((offset, line));
      offset = end + 1;
    }
    return lines;
  }

  AppTextList? _listOf(String line) => switch (_marker.firstMatch(line)) {
        null => null,
        final match =>
          match.group(2) == _bullet ? AppTextList.bullet : AppTextList.numbered,
      };

  int _caretFlags() {
    if (_pendingFlags != null) return _pendingFlags!;
    return selection.isValid ? _inheritedFlags(selection.start) : 0;
  }

  /// New text takes the marks of the character before it on its line, or at a
  /// line start of the one after it.
  int _inheritedFlags(int offset) {
    if (offset > 0 && offset <= text.length && text[offset - 1] != '\n') {
      final before = _flags[offset - 1];
      if (before != 0 || text[offset - 1] != ' ') return before;
    }
    if (offset < text.length && text[offset] != '\n') return _flags[offset];
    return 0;
  }

  String _inline(int start, int end) {
    final out = StringBuffer();
    var run = start;
    for (var index = start + 1; index <= end; index++) {
      if (index < end && _flags[index] == _flags[run]) continue;
      final marks = [
        for (final mark in AppTextMark.values)
          if (_flags[run] & mark.bit != 0) mark.tag,
      ];
      out
        ..writeAll(marks.map((tag) => '<$tag>'))
        ..write(_escape(text.substring(run, index).replaceAll(_sentinel, '')))
        ..writeAll(marks.reversed.map((tag) => '</$tag>'));
      run = index;
    }
    return out.toString();
  }

  static int _flagsOf(TextStyle? style) =>
      (style?.fontWeight == FontWeight.bold ? AppTextMark.bold.bit : 0) |
      (style?.fontStyle == FontStyle.italic ? AppTextMark.italic.bit : 0) |
      (style?.decoration == TextDecoration.underline
          ? AppTextMark.underline.bit
          : 0);

  static TextStyle? _styleOf(int flags) => flags == 0
      ? null
      : TextStyle(
          fontWeight:
              flags & AppTextMark.bold.bit != 0 ? FontWeight.bold : null,
          fontStyle:
              flags & AppTextMark.italic.bit != 0 ? FontStyle.italic : null,
          decoration: flags & AppTextMark.underline.bit != 0
              ? TextDecoration.underline
              : null,
        );

  static int _min(int a, int b) => a < b ? a : b;
  static int _max(int a, int b) => a > b ? a : b;
}

/// Text, marks and selection while one change is worked out.
final class _Edit {
  _Edit(this.text, List<int> flags, this.selection)
      : flags = List<int>.of(flags);

  String text;
  final List<int> flags;
  TextSelection selection;

  void replace(int start, int end, String inserted, {int mark = 0}) {
    text = text.replaceRange(start, end, inserted);
    flags.replaceRange(start, end, List<int>.filled(inserted.length, mark));
    if (selection.isValid) {
      int moved(int offset) => offset <= start
          ? offset
          : offset >= end
              ? offset + inserted.length - (end - start)
              : start + inserted.length;
      selection = selection.copyWith(
          baseOffset: moved(selection.baseOffset),
          extentOffset: moved(selection.extentOffset));
    }
  }
}

final _literalEntity = RegExp(r'&(?=(#x[0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+);)');
final _literalTag = RegExp(r'<(?=\s*/?\s*[a-zA-Z])');

/// Escapes only text that [parseAppFormattedText] would read as markup.
String _escape(String text) =>
    text.replaceAll(_literalEntity, '&amp;').replaceAll(_literalTag, '&lt;');
