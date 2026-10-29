import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/forms/library_form_schema.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_status_strip.dart';
import 'package:collectarr_app/features/library/edit/sections/custom_fields_edit_section.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import '../edit/entry/entry_draft.dart';
import '../edit/covers_tab.dart';
import 'draft.dart';
import '../domain/comic_personal_data.dart';
import 'personal_tabs.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/links_tab.dart';
import 'package:collectarr_app/features/library/kinds/comic/config/comic_field_identities.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/person_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/people_editors.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicAddManualPane extends ConsumerStatefulWidget {
  const ComicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  ConsumerState<ComicAddManualPane> createState() => _ComicAddManualPaneState();
}

class _ComicAddManualPaneState extends ConsumerState<ComicAddManualPane> {
  late final LocalDatabase _database;
  late final ComicEntryEditDraft _entry;

  ComicAddDraft get _personal => widget.request.kindDraft is ComicAddDraft
      ? widget.request.kindDraft as ComicAddDraft
      : const ComicAddDraft();
  void _updatePersonal(ComicPersonalData value) =>
      widget.request.onKindDraftChanged
          ?.call(_personal.copyWith(personal: value));

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _seriesGroupOptions = const [];
  List<String> _physicalFormatOptions = const [];

  @override
  void initState() {
    super.initState();
    _database = ref.read(localDatabaseProvider);
    _entry = ComicEntryEditDraft.fromDetails(_personal.personal.details);
    _loadVocabularies();
  }

  List<PhysicalMediaFormat> _currentPhysicalFormats() {
    return physicalMediaFormatsForKind(
      ref.read(mediaCatalogProvider).maybeWhen(
            data: (value) => value,
            orElse: () => fallbackMediaCatalog,
          ),
      CatalogMediaKind.comic,
    );
  }

  Future<void> _loadVocabularies() async {
    final comicDraft = widget.request.manualDraftAs<ComicAddManualDraft>();
    final formats = _currentPhysicalFormats();
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        _database,
        listName: ComicVocabularyIds.publisher.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.publisher.builtIns,
        selectedValue: comicDraft.values.publisher,
      ),
      loadSingleValuePickListOptions(
        _database,
        listName: ComicVocabularyIds.imprint.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.imprint.builtIns,
        selectedValue: comicDraft.values.imprint,
      ),
      loadSingleValuePickListOptions(
        _database,
        listName: ComicVocabularyIds.seriesGroup.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.seriesGroup.builtIns,
        selectedValue: comicDraft.values.seriesGroup,
      ),
      loadSingleValuePickListOptions(
        _database,
        listName: ComicVocabularyIds.physicalFormat.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: [for (final format in formats) format.label],
        selectedValue: comicDraft.values.physicalFormatLabel,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _imprintOptions = List<String>.from(results[1] as List<String>);
      _seriesGroupOptions = List<String>.from(results[2] as List<String>);
      _physicalFormatOptions = List<String>.from(results[3] as List<String>);
    });
  }

  Future<void> _manageSingleValuePickList({
    required String listName,
    required String label,
    List<String> builtInValues = const [],
  }) async {
    await showPickListEditorDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      listName: listName,
      label: label,
      mediaKind: CatalogMediaKind.comic.apiValue,
      builtInValues: builtInValues,
    );
    if (!mounted) return;
    await _loadVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    final comicDraft = widget.request.manualDraftAs<ComicAddManualDraft>();
    final request = widget.request;
    LibraryFormSchema<ComicAddManualDraft> schemaFor(
      Set<String> fieldIds,
      String sectionLabel,
    ) =>
        comicAddSchemaFor(
          fieldIds: fieldIds,
          sectionLabels: {
            'issue': sectionLabel,
            'publication': sectionLabel,
          },
          publisherOptions: _publisherOptions.isEmpty
              ? ComicVocabularies.publisher.builtIns
              : _publisherOptions,
          imprintOptions: _imprintOptions.isEmpty
              ? ComicVocabularies.imprint.builtIns
              : _imprintOptions,
          seriesGroupOptions: _seriesGroupOptions.isEmpty
              ? ComicVocabularies.seriesGroup.builtIns
              : _seriesGroupOptions,
          physicalFormatOptions: _physicalFormatOptions.isEmpty
              ? [
                  for (final format in _currentPhysicalFormats()) format.label,
                ]
              : _physicalFormatOptions,
          onManagePublisher: () => _manageSingleValuePickList(
            listName: ComicVocabularyIds.publisher.value,
            label: 'Publishers',
          ),
          onManageImprint: () => _manageSingleValuePickList(
            listName: ComicVocabularyIds.imprint.value,
            label: 'Imprints',
          ),
          onManageSeriesGroup: () => _manageSingleValuePickList(
            listName: ComicVocabularyIds.seriesGroup.value,
            label: 'Series Groups',
          ),
          onManagePhysicalFormat: () => _manageSingleValuePickList(
            listName: ComicVocabularyIds.physicalFormat.value,
            label: 'Physical Formats',
            builtInValues: [
              for (final format in _currentPhysicalFormats()) format.label,
            ],
          ),
          includeTitle: false,
        );

    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required Set<String> fieldIds,
      required String sectionLabel,
      bool validateSchema = false,
    }) =>
        LibraryAddManualPaneTab.fromSchema<ComicAddManualDraft>(
          id: id,
          label: label,
          icon: icon,
          schema: schemaFor(fieldIds, sectionLabel),
          draft: comicDraft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
          validateSchema: validateSchema,
        );
    final tabs = <LibraryAddManualPaneTab>[
      schemaTab(
        id: 'main',
        label: 'Main',
        icon: Icons.article_outlined,
        fieldIds: const {
          ComicFieldIdentities.seriesId,
          ComicFieldIdentities.issueNumberId,
          ComicFieldIdentities.variantId,
          'variant_description',
          'barcode',
          'physical_format',
          'series_group',
          'cover_date',
          'release_date',
          'publisher',
          ComicFieldIdentities.imprintId,
        },
        sectionLabel: 'Main',
        validateSchema: true,
      ),
      schemaTab(
        id: 'details',
        label: 'Details',
        icon: Icons.info_outline,
        fieldIds: const {
          'catalog_title',
          'edition_title',
          'isbn',
          'upc',
          ComicFieldIdentities.pageCountId,
          'age_rating',
          'publication_age',
          'subtitle',
          'genres',
          'language',
          'country',
          'crossover',
          'story_arcs',
        },
        sectionLabel: 'Publication details',
      ),
      LibraryAddManualPaneTab(
        id: 'creators',
        label: 'Creators',
        icon: Icons.people_outline,
        content: ComicCreatorListEditor(
          creators: comicDraft.creators,
          accent: request.accent,
          onAdd: () => setState(
            () => comicDraft.creators.add(EditableComicCreator.custom()),
          ),
          onRemove: (index) => setState(
            () => comicDraft.creators.removeAt(index).dispose(),
          ),
          onReorder: (oldIndex, newIndex) => setState(() {
            final creator = comicDraft.creators.removeAt(oldIndex);
            comicDraft.creators.insert(newIndex, creator);
          }),
          onChanged: request.onManualDraftChanged ?? () {},
        ),
      ),
      LibraryAddManualPaneTab(
        id: 'characters',
        label: 'Characters',
        icon: Icons.face_outlined,
        content: ComicCharacterListEditor(
          characters: comicDraft.characters,
          accent: request.accent,
          onAdd: () => setState(
            () => comicDraft.characters.add(EditableComicCharacter.custom('')),
          ),
          onRemove: (index) => setState(
            () => comicDraft.characters.removeAt(index).dispose(),
          ),
          onReorder: (oldIndex, newIndex) => setState(() {
            final character = comicDraft.characters.removeAt(oldIndex);
            comicDraft.characters.insert(newIndex, character);
          }),
          onChanged: request.onManualDraftChanged ?? () {},
        ),
      ),
      LibraryAddManualPaneTab(
        id: 'covers',
        label: 'Covers',
        icon: Icons.camera_alt_outlined,
        content: ComicCoversTab(
          searchTitle: () => comicDraft.values.seriesTitle,
          images: [
            for (final image in request.itemImages)
              if (_isCover(image)) image
          ],
          coverImageUrl: comicDraft.values.coverImageUrl,
          originalCoverImageUrl: '',
          onCoverImageUrlChanged: (value) {
            comicDraft.values.coverImageUrl = value;
            request.onManualDraftChanged?.call();
          },
          onEdits: (edits) {
            final changed = {for (final edit in edits) edit.imageType};
            request.onItemImagesChanged?.call([
              for (final image in request.itemImages)
                if (!changed.contains(image.imageType)) _imageEdit(image),
              for (final edit in edits)
                if (!edit.deleted) edit,
            ]);
          },
        ),
      ),
      LibraryAddManualPaneTab(
        id: 'links',
        label: 'Links',
        icon: Icons.public,
        content: ComicAddLinksTab(
          draft: comicDraft,
          accent: request.accent,
          onChanged: request.onManualDraftChanged,
        ),
      ),
      LibraryAddManualPaneTab(
        id: 'value',
        label: 'Value',
        icon: Icons.payments_outlined,
        content: ComicAddPersonalTab(
            request: request, entry: _entry, valueTab: true),
      ),
      LibraryAddManualPaneTab(
        id: 'personal',
        label: 'Personal',
        icon: Icons.person_outline,
        content: ComicAddPersonalTab(
            request: request, entry: _entry, valueTab: false),
      ),
      LibraryAddManualPaneTab(
        id: 'custom_fields',
        label: 'Custom Fields',
        icon: Icons.edit_note_outlined,
        content: CustomFieldsEditSection(
          definitions: request.customFieldDefinitions,
          values: request.customFieldValues,
          accent: request.accent,
          mediaKind: request.kind.apiValue,
          onChanged: (values) =>
              request.onCustomFieldValuesChanged?.call(values),
          onCustomValueChanged: (id, value) => request.onVocabularyValueChanged
              ?.call(
                  fieldId: 'customField:$id',
                  listName: 'customField:$id',
                  value: value),
        ),
      ),
      LibraryAddManualPaneTab(
        id: 'my_images',
        label: 'My Images',
        icon: Icons.photo_library_outlined,
        content: ItemImagesEditSection(
          images: [
            for (final image in request.itemImages)
              if (!_isCover(image)) image
          ],
          accent: request.accent,
          onChanged: (edits) => request.onItemImagesChanged?.call([
            for (final image in request.itemImages)
              if (_isCover(image)) _imageEdit(image),
            for (final edit in edits)
              if (!edit.deleted) edit,
          ]),
        ),
      ),
      LibraryAddManualPaneTab.fromSchema<ComicAddManualDraft>(
        id: 'plot',
        label: 'Plot',
        icon: Icons.subject,
        schema: LibraryFormSchema(sections: [
          LibraryFormSectionSpec(
            id: 'plot',
            label: '',
            maxColumns: 1,
            fields: [
              LibraryTextFieldSpec<ComicAddManualDraft>(
                id: 'description',
                label: 'Plot',
                maxLines: 18,
                value: (draft) => draft.values.description,
                setValue: (draft, value) => draft.values.description = value,
              )
            ],
          )
        ]),
        draft: comicDraft,
        mediaKind: request.kind.apiValue,
        onChanged: request.onManualDraftChanged,
      ),
    ];
    final byId = {for (final tab in tabs) tab.id: tab};
    return LibraryAddManualPaneShell(
      request: request,
      footerContent: LibraryAddStatusStrip(
        request: request,
        indexValue: _personal.personal.indexNumber,
        quantity: _personal.personal.quantity,
        onIndexChanged: (value) =>
            _updatePersonal(_personal.personal.copyWith(indexNumber: value)),
        onQuantityChanged: (value) =>
            _updatePersonal(_personal.personal.copyWith(quantity: value)),
      ),
      tabs: [
        for (final id in const [
          'main',
          'details',
          'value',
          'personal',
          'custom_fields',
          'covers',
          'my_images',
          'creators',
          'characters',
          'plot',
          'links'
        ])
          byId[id]!
      ],
    );
  }
}

bool _isCover(ItemImageContent image) =>
    image.imageType == 'front_cover' || image.imageType == 'back_cover';
ItemImageEdit _imageEdit(ItemImageDraft image) => ItemImageEdit(
      id: image.id,
      imageData: image.imageData,
      caption: image.caption,
      createdAt: image.createdAt,
      imageType: image.imageType,
      sortOrder: image.sortOrder,
    );

Widget buildComicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return ComicAddManualPane(request: request);
}
