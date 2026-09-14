import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/kind_registry/ast_source.dart';

void main() {
  test('discovers an inferred typed dev-seed contributor', () {
    final contributor = findTopLevelVariable(
      File('lib/dev/seeds/anime_seeds.dart'),
      nameWhere: (name) => name == 'animeDevSeedContributor',
    );

    expect(contributor?.name, 'animeDevSeedContributor');
    expect(
      contributor?.declaredType,
      startsWith('TypedDevSeedKindContributor<AnimeOwnedItem>'),
    );
  });

  test('discovers contributor implementations without source markers', () {
    final contributors = findClassesImplementing(
      File(
        'lib/features/library/kinds/comic/calendar/'
        'comic_calendar_contributor.dart',
      ),
      'LibraryCalendarContributor',
    );

    expect(contributors, contains('ComicCalendarContributor'));
  });

  test('discovers all local Drift tables from declarations', () {
    final tables = findTableClasses(
      File(
        'lib/features/library/kinds/comic/data/local/comic_local_tables.dart',
      ),
    );

    expect(tables, contains('ComicMediaRows'));
    expect(tables, contains('ComicOwnedItemsRows'));
  });

  test('requires a real static const vocabulary collection', () {
    final vocabulary = findTopLevelClass(
      File(
        'lib/features/library/kinds/comic/vocabulary/comic_vocabularies.dart',
      ),
      where: (declaration) =>
          declaration.namePart.typeName.lexeme == 'ComicVocabularies' &&
          hasStaticConstField(declaration, 'all'),
    );

    expect(vocabulary, 'ComicVocabularies');
  });
}
