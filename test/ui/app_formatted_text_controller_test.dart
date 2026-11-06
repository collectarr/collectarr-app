import 'package:collectarr_app/ui/app_formatted_text_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void _select(AppFormattedTextController controller, String part) {
  final start = controller.text.indexOf(part);
  controller.selection =
      TextSelection(baseOffset: start, extentOffset: start + part.length);
}

void _caretAtEnd(AppFormattedTextController controller) =>
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);

void _type(AppFormattedTextController controller, String typed) {
  final caret = controller.selection.start;
  controller.value = TextEditingValue(
    text: controller.text.replaceRange(caret, caret, typed),
    selection: TextSelection.collapsed(offset: caret + typed.length),
  );
}

void main() {
  test('plain text stays plain, line breaks included', () {
    final controller = AppFormattedTextController('one\n\ntwo & three');
    addTearDown(controller.dispose);
    expect(controller.text, 'one\n\ntwo & three');
    expect(controller.source, 'one\n\ntwo & three');
  });

  test('marks and lists round trip through the source', () {
    const source = 'A <b>bold</b> and <i>italic</i>'
        '<ul><li><u>one</u></li><li>two</li></ul>'
        '<ol><li>three</li></ol>end';
    final controller = AppFormattedTextController(source);
    addTearDown(controller.dispose);
    expect(controller.source, source);
  });

  test('nested lists keep their levels', () {
    const source = '<ul><li>one<ol><li>two</li></ol></li><li>three</li></ul>';
    final controller = AppFormattedTextController(source);
    addTearDown(controller.dispose);
    expect(controller.source, source);
  });

  test('toggling a mark changes the selection and advances the revision', () {
    final controller = AppFormattedTextController('one two');
    addTearDown(controller.dispose);
    final revision = controller.revision;
    _select(controller, 'two');
    expect(controller.revision, revision);

    controller.toggleMark(AppTextMark.bold);
    expect(controller.source, 'one <b>two</b>');
    expect(controller.hasMark(AppTextMark.bold), isTrue);
    expect(controller.revision, greaterThan(revision));

    controller.toggleMark(AppTextMark.bold);
    expect(controller.source, 'one two');
  });

  test('a mark chosen at the caret applies to the next typed text', () {
    final controller = AppFormattedTextController('one ');
    addTearDown(controller.dispose);
    _caretAtEnd(controller);
    controller.toggleMark(AppTextMark.italic);
    expect(controller.hasMark(AppTextMark.italic), isTrue);
    _type(controller, 'two');
    expect(controller.source, 'one <i>two</i>');
  });

  test('typing inside bold text stays bold', () {
    final controller = AppFormattedTextController('<b>ab</b>');
    addTearDown(controller.dispose);
    controller.selection = const TextSelection.collapsed(offset: 1);
    _type(controller, 'x');
    expect(controller.source, '<b>axb</b>');
  });

  test('literal markup and entities are escaped', () {
    final controller = AppFormattedTextController();
    addTearDown(controller.dispose);
    _type(controller, 'a <b> &amp; Tom & Jerry');
    expect(controller.source, 'a &lt;b> &amp;amp; Tom & Jerry');
    controller.load(controller.source);
    expect(controller.text, 'a <b> &amp; Tom & Jerry');
  });

  test('a numbered list renumbers and continues on Enter', () {
    final controller = AppFormattedTextController('one');
    addTearDown(controller.dispose);
    _caretAtEnd(controller);
    controller.toggleList(AppTextList.numbered);
    expect(controller.hasList(AppTextList.numbered), isTrue);
    _caretAtEnd(controller);
    _type(controller, '\n');
    _type(controller, 'two');
    expect(controller.source, '<ol><li>one</li><li>two</li></ol>');
    expect(controller.text, contains('2.'));
  });

  test('Enter on an empty item ends the list', () {
    final controller = AppFormattedTextController('<ul><li>one</li></ul>');
    addTearDown(controller.dispose);
    _caretAtEnd(controller);
    _type(controller, '\n');
    _type(controller, '\n');
    _type(controller, 'after');
    expect(controller.source, '<ul><li>one</li></ul>after');
  });

  test('deleting into a marker removes all of it', () {
    final controller = AppFormattedTextController('<ul><li>one</li></ul>');
    addTearDown(controller.dispose);
    final markerEnd = controller.text.indexOf('one');
    controller.value = TextEditingValue(
      text: controller.text.replaceRange(markerEnd - 1, markerEnd, ''),
      selection: TextSelection.collapsed(offset: markerEnd - 1),
    );
    expect(controller.text, 'one');
    expect(controller.source, 'one');
  });

  test('a typed line that looks like a list item stays text', () {
    final controller = AppFormattedTextController('2001. A year\n• dot');
    addTearDown(controller.dispose);
    _caretAtEnd(controller);
    _type(controller, '!');
    expect(controller.source, '2001. A year\n• dot!');
  });

  test('undo brings a text back with its marks', () {
    final controller = AppFormattedTextController('<b>ab</b>');
    addTearDown(controller.dispose);
    final before = controller.value;
    _caretAtEnd(controller);
    controller.value = const TextEditingValue(
        text: 'a', selection: TextSelection.collapsed(offset: 1));
    expect(controller.source, '<b>a</b>');
    controller.value = before;
    expect(controller.source, '<b>ab</b>');
  });
}
