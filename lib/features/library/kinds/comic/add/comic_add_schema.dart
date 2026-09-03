import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/edit/schema/edit_schema.dart'
    show EditOption;
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';

final AddSchema<ComicAddManualDraft> comicAddSchema =
    AddSchema<ComicAddManualDraft>(
  title: (_) => 'Manual comic issue',
  validate: (_) => null,
  sections: [
    AddSectionSpec<ComicAddManualDraft>(
      id: 'main',
      label: 'Main',
      visibleWhen: (_) => true,
      fields: [
        TextAddField<ComicAddManualDraft>(
          id: 'number',
          label: 'Issue No.',
          value: (draft) => draft.numberController.text,
          setValue: (draft, value) => draft.numberController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'variant',
          label: 'Variant',
          value: (draft) => draft.variantController.text,
          setValue: (draft, value) => draft.variantController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'barcode',
          label: 'Barcode',
          value: (draft) => draft.barcodeController.text,
          setValue: (draft, value) => draft.barcodeController.text = value,
        ),
        VocabularyAddField<ComicAddManualDraft, String>(
          id: 'format',
          label: 'Format',
          value: (draft) => _nullableText(
            draft.physicalFormatLabelController.text,
          ),
          setValue: (draft, value) =>
              draft.physicalFormatLabelController.text = value ?? '',
          options: _optionsFrom(ComicVocabularies.physicalFormat.builtIns),
        ),
        NumberAddField<ComicAddManualDraft>(
          id: 'coverDate',
          label: 'Cover Date (YYYY)',
          value: (draft) => int.tryParse(draft.yearController.text),
          setValue: (draft, value) =>
              draft.yearController.text = value?.toInt().toString() ?? '',
        ),
        VocabularyAddField<ComicAddManualDraft, String>(
          id: 'publisher',
          label: 'Publisher',
          value: (draft) => _nullableText(draft.publisherController.text),
          setValue: (draft, value) =>
              draft.publisherController.text = value ?? '',
          options: _optionsFrom(ComicVocabularies.publisher.builtIns),
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'coverImageUrl',
          label: 'Cover image URL',
          value: (draft) => draft.coverController.text,
          setValue: (draft, value) => draft.coverController.text = value,
        ),
      ],
    ),
    AddSectionSpec<ComicAddManualDraft>(
      id: 'collector',
      label: 'Collector',
      visibleWhen: (_) => true,
      fields: [
        TextAddField<ComicAddManualDraft>(
          id: 'rawOrSlabbed',
          label: 'Raw / Slabbed',
          value: (draft) => draft.rawOrSlabbedController.text,
          setValue: (draft, value) => draft.rawOrSlabbedController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'gradingCompany',
          label: 'Grading Co.',
          value: (draft) => draft.gradingCompanyController.text,
          setValue: (draft, value) =>
              draft.gradingCompanyController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'certificationNumber',
          label: 'Certification No.',
          value: (draft) => draft.certificationNumberController.text,
          setValue: (draft, value) =>
              draft.certificationNumberController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'labelType',
          label: 'Label Type',
          value: (draft) => draft.labelTypeController.text,
          setValue: (draft, value) => draft.labelTypeController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'pageQuality',
          label: 'Page Quality',
          value: (draft) => draft.pageQualityController.text,
          setValue: (draft, value) => draft.pageQualityController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'signedBy',
          label: 'Signed by',
          value: (draft) => draft.signedByController.text,
          setValue: (draft, value) => draft.signedByController.text = value,
        ),
        TextAddField<ComicAddManualDraft>(
          id: 'graderNotes',
          label: 'Grader Notes',
          value: (draft) => draft.graderNotesController.text,
          setValue: (draft, value) => draft.graderNotesController.text = value,
          maxLines: 4,
        ),
      ],
    ),
  ],
);

String? _nullableText(String value) => value.isEmpty ? null : value;

List<EditOption<String>> _optionsFrom(Iterable<String> values) => [
      for (final value in values) EditOption(value: value, label: value),
    ];
