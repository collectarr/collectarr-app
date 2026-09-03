import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_metadata.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/manga_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/edit/media/manga_media_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/models/library_catalog_item_view.dart';
import 'package:collectarr_app/features/library/models/library_item_identity.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/media_edit_contract.dart';

void main() {
  defineMediaEditContract<EditSchema<MangaMetadata, MangaEditDraft>>(
    name: 'Manga',
    create: () => mangaMediaEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares Manga media tabs and field ordering', () {
    expect(mangaMediaEditSchema.tabs.map((tab) => tab.id), [
      'main',
      'publication',
    ]);
    expect(
      [
        for (final tab in mangaMediaEditSchema.tabs)
          for (final section in tab.sections)
            for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
    expect(
      mangaMediaEditSchema.tabs.first.sections.first.fields
          .map((field) => field.id),
      [
        'volume_number',
        'edition_title',
        'variant',
        'barcode',
        'format',
        'release_date',
      ],
    );
  });

  test('binds Manga vocabularies and preserves typed media values', () {
    final draft = _createDraft(
      const MangaMetadata(
        title: 'Frieren',
        volumeNumber: 1,
        publisher: 'Shogakukan',
        editionFormat: MangaEditionFormat.tankobon,
        pageCount: 192,
        genres: ['Fantasy'],
      ),
    );
    addTearDown(draft.dispose);

    final format =
        _field('format') as VocabularyEditField<MangaEditDraft, String>;
    final publisher =
        _field('publisher') as VocabularyEditField<MangaEditDraft, String>;
    expect(
      format.options.map((option) => option.value),
      MangaVocabularies.format.builtIns,
    );
    expect(
      publisher.options.map((option) => option.value),
      MangaVocabularies.publisher.builtIns,
    );

    format.setValue(draft, 'Digital');
    publisher.setValue(draft, 'VIZ Media');
    expect(format.value(draft), 'Digital');
    expect(publisher.value(draft), 'VIZ Media');

    final volume = _field('volume_number') as TextEditField<MangaEditDraft>;
    volume.setValue(draft, '3');
    expect(volume.value(draft), '3');

    final pageCount = _field('page_count') as NumberEditField<MangaEditDraft>;
    pageCount.setValue(draft, 224);
    expect(pageCount.value(draft), 224);

    final releaseDate = _field('release_date') as DateEditField<MangaEditDraft>;
    releaseDate.setValue(draft, DateTime(2026, 4, 12));
    expect(releaseDate.value(draft), DateTime(2026, 4, 12));

    final genres = _field('genres') as TextEditField<MangaEditDraft>;
    genres.setValue(draft, 'Action, Fantasy');
    expect(genres.value(draft), 'Action, Fantasy');
  });

  test('rejects invalid Manga media values', () {
    final draft = _createDraft(const MangaMetadata(title: 'Frieren'));
    addTearDown(draft.dispose);

    final pageCount = _field('page_count') as NumberEditField<MangaEditDraft>;
    pageCount.setValue(draft, -1);
    expect(
      mangaMediaEditSchema.validate!(const MangaMetadata(), draft),
      'Page count cannot be negative',
    );

    pageCount.setValue(draft, null);
    final releaseDate = _field('release_date') as DateEditField<MangaEditDraft>;
    releaseDate.setValue(draft, null);
    draft.releaseDateController.text = 'not-a-date';
    expect(releaseDate.validate(draft), 'Release date is invalid');
  });
}

MangaEditDraft _createDraft(MangaMetadata metadata) {
  final item = LibraryCatalogItemView(
    identity: const LibraryItemIdentity(
      id: 'manga-1',
      mediaKind: CatalogMediaKind.manga,
    ),
    kindMetadata: metadata,
  );
  return createMangaEditDraft(
    item: item,
    textControllers: TextControllerGroup(),
  ) as MangaEditDraft;
}

EditFieldSpec<MangaEditDraft> _field(String id) {
  return [
    for (final tab in mangaMediaEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
