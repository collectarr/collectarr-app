import 'package:collectarr_app/features/pick_lists/models/pick_list_scope.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry exposes built-in definitions for active kinds', () {
    final registry = PickListRegistry();
    for (final kind in const [
      'comic',
      'manga',
      'anime',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'music',
    ]) {
      expect(registry.definitionsForKind(kind), isNotEmpty);
    }
  });

  test('registry resolves built-in fields and custom field lists', () {
    final registry = PickListRegistry();
    final condition = registry.definitionForField(
      fieldKey: 'condition',
      mediaKind: 'comic',
      scope: PickListScope.ownedCopy,
    );
    final customField = registry.definitionForField(
      fieldKey: 'customField:abc',
      mediaKind: 'book',
      scope: PickListScope.customField,
    );

    expect(condition?.listName, 'condition');
    expect(customField?.listName, 'customfield:abc');
  });

  test('registry definitions do not duplicate list/scope pairs per kind', () {
    final registry = PickListRegistry();
    for (final kind in const [
      'comic',
      'manga',
      'anime',
      'book',
      'game',
      'boardgame',
      'movie',
      'tv',
      'music',
    ]) {
      final defs = registry.definitionsForKind(kind);
      final seen = <String>{};
      for (final def in defs) {
        expect(
          seen.add('${def.listName}:${def.mediaKind}:${def.scope.name}'),
          isTrue,
        );
      }
    }
  });
}
