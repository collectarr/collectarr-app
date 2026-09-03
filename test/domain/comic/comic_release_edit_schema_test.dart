import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/release/comic_release_edit_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../contracts/release_contract.dart';
import '../../contracts/release_edit_contract.dart';

void main() {
  final release = ComicRelease(
    id: 'release-1',
    title: 'Batman: Year One',
    publisher: 'DC Comics',
    imprint: 'Black Label',
    isbn: '978-1-4012-3456-7',
    upc: '761941000001',
    releaseDate: DateTime(2024, 5, 10),
    coverImageUrl: 'https://example.com/cover.jpg',
    variants: [
      CatalogVariantDto(
        id: 'variant-1',
        name: 'Newsstand',
        barcode: '761941000002',
      ),
    ],
  );

  defineReleaseContract<ComicRelease>(
    name: 'Comic',
    create: () => release,
    id: (subject) => subject.id,
    title: (subject) => subject.title,
  );

  defineReleaseEditContract<EditSchema<ComicRelease, ComicReleaseEditDraft>>(
    name: 'Comic',
    create: () => comicReleaseEditSchema,
    tabIds: (schema) => schema.tabs.map((tab) => tab.id),
    fieldIds: (schema, tabId) => [
      for (final tab in schema.tabs)
        if (tab.id == tabId)
          for (final section in tab.sections)
            for (final field in section.fields) field.id,
    ],
  );

  test('declares release, edition, identifier, and variant fields', () {
    expect(comicReleaseEditSchema.tabs.map((tab) => tab.id), ['release']);
    expect(
      comicReleaseEditSchema.tabs.single.sections.map((section) => section.id),
      [
        'release_identity',
        'release_publication',
        'release_artwork',
        'release_variants',
      ],
    );
    expect(
      [
        for (final section in comicReleaseEditSchema.tabs.single.sections)
          for (final field in section.fields) field.label,
      ].every((label) => label.isNotEmpty),
      isTrue,
    );
  });

  test('round trips typed release values through the edit draft', () {
    final draft = ComicReleaseEditDraft.fromRelease(release);
    addTearDown(draft.dispose);

    expect(draft.toRelease().toJson(), release.toJson());
    expect(draft.variants.single.name, 'Newsstand');

    final title =
        _field('release_title') as TextEditField<ComicReleaseEditDraft>;
    final publisher = _field('publisher')
        as VocabularyEditField<ComicReleaseEditDraft, String>;
    final releaseDate =
        _field('release_date') as DateEditField<ComicReleaseEditDraft>;
    final cover = _field('cover_image_url')
        as ImageEditField<ComicReleaseEditDraft, String>;

    expect(
      publisher.options.map((option) => option.value),
      ComicVocabularies.publisher.builtIns,
    );
    title.setValue(draft, 'Batman: Year One Deluxe');
    publisher.setValue(draft, 'Marvel Comics');
    releaseDate.setValue(draft, DateTime(2026, 2, 3));
    cover.setValue(draft, 'https://example.com/new-cover.jpg');

    expect(draft.title, 'Batman: Year One Deluxe');
    expect(draft.publisher, 'Marvel Comics');
    expect(draft.releaseDate, DateTime(2026, 2, 3));
    expect(draft.coverImageUrl, 'https://example.com/new-cover.jpg');
  });

  test('validates release identity', () {
    final draft = ComicReleaseEditDraft.fromRelease(release);
    addTearDown(draft.dispose);

    draft.title = '';
    expect(
      comicReleaseEditSchema.validate!(release, draft),
      'Release title is required',
    );
  });
}

EditFieldSpec<ComicReleaseEditDraft> _field(String id) {
  return [
    for (final tab in comicReleaseEditSchema.tabs)
      for (final section in tab.sections)
        for (final field in section.fields)
          if (field.id == id) field,
  ].single;
}
