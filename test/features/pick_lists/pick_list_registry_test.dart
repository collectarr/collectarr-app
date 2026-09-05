import 'package:collectarr_app/features/pick_lists/models/pick_list_scope.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_registry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry exposes built-in definitions for active kinds', () {
    final registry = defaultPickListRegistry;
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
    final registry = defaultPickListRegistry;
    final condition = registry.definitionForField(
      fieldKey: 'conditions',
      mediaKind: 'comic',
      scope: PickListScope.ownedCopy,
    );
    final customField = registry.definitionForField(
      fieldKey: 'customField:abc',
      mediaKind: 'book',
      scope: PickListScope.customField,
    );

    expect(condition?.listName, 'conditions');
    expect(customField?.listName, 'customfield:abc');
  });

  test('kind definitions come from owned vocabulary modules', () {
    final registry = defaultPickListRegistry;
    final comicDefinitions = registry.definitionsForKind('comic');

    expect(
      comicDefinitions.any(
        (definition) =>
            definition.listName == ComicVocabularyIds.publisher.value,
      ),
      isTrue,
    );
    expect(
      comicDefinitions.any((definition) => definition.listName == 'publisher'),
      isFalse,
    );
    expect(
      comicDefinitions.any(
        (definition) =>
            definition.listName == ComicVocabularyIds.storyArc.value,
      ),
      isTrue,
    );
  });

  test('registry definitions do not duplicate list/scope pairs per kind', () {
    final registry = defaultPickListRegistry;
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
