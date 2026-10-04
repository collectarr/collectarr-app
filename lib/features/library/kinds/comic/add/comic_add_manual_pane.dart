import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/serial/serial_authority_dialog.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_links_tab.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_person_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/forms/comic_people_editors.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
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
  late final TextEditingController _seriesController;
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _seriesGroupOptions = const [];
  List<String> _physicalFormatOptions = const [];
  List<SerialAuthorityEntry> _seriesEntries = const [];
  String? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
    final draft = widget.request.manualDraftAs<ComicAddManualDraft>();
    _seriesController = TextEditingController(text: draft.values.seriesTitle);
    _selectedSeriesId = draft.values.seriesId;
    _loadVocabularies();
  }

  @override
  void dispose() {
    _seriesController.dispose();
    super.dispose();
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
    final db = ref.read(localDatabaseProvider);
    final comicDraft = widget.request.manualDraftAs<ComicAddManualDraft>();
    final formats = _currentPhysicalFormats();
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: ComicVocabularyIds.publisher.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.publisher.builtIns,
        selectedValue: comicDraft.values.publisher,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: ComicVocabularyIds.imprint.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.imprint.builtIns,
        selectedValue: comicDraft.values.imprint,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: ComicVocabularyIds.seriesGroup.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.seriesGroup.builtIns,
        selectedValue: comicDraft.values.seriesGroup,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: ComicVocabularyIds.physicalFormat.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: [for (final format in formats) format.label],
        selectedValue: comicDraft.values.physicalFormatLabel,
      ),
      SerialAuthorityRepository(db).searchEntries(
        mediaKind: CatalogMediaKind.comic.apiValue,
        selectedTitle: _seriesController.text,
        selectedSeriesId: _selectedSeriesId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _imprintOptions = List<String>.from(results[1] as List<String>);
      _seriesGroupOptions = List<String>.from(results[2] as List<String>);
      _physicalFormatOptions = List<String>.from(results[3] as List<String>);
      _seriesEntries = List<SerialAuthorityEntry>.from(
          results[4] as List<SerialAuthorityEntry>);
    });
  }

  Future<void> _openManualSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: CatalogMediaKind.comic.apiValue,
      selectedTitle: _seriesController.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedSeriesId = selected.coreSeriesId;
      final values = widget.request.manualDraftAs<ComicAddManualDraft>().values;
      values
        ..seriesId = selected.coreSeriesId
        ..seriesTitle = selected.title;
      _seriesController.value = TextEditingValue(
        text: selected.title,
        selection: TextSelection.collapsed(offset: selected.title.length),
      );
    });
    await _loadVocabularies();
  }

  void _setManualSeries(String? value) {
    final normalized = (value ?? '').trim();
    final match = _seriesEntries.cast<SerialAuthorityEntry?>().firstWhere(
          (entry) =>
              entry != null &&
              entry.title.trim().toLowerCase() == normalized.toLowerCase(),
          orElse: () => null,
        );
    setState(() {
      _selectedSeriesId = match?.coreSeriesId;
      final values = widget.request.manualDraftAs<ComicAddManualDraft>().values;
      values
        ..seriesTitle = normalized
        ..seriesId = match?.coreSeriesId;
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
    AddSchema<ComicAddManualDraft> schemaFor(
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

    Widget buildFields(Set<String> fieldIds, String sectionLabel) =>
        AddSchemaRenderer<ComicAddManualDraft>.embedded(
          schema: schemaFor(fieldIds, sectionLabel),
          draft: comicDraft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
        );
    return LibraryAddManualPaneShell(
      request: request,
      identityDetails: LibraryVocabularyField(
        controller: _seriesController,
        options: [for (final entry in _seriesEntries) entry.title],
        label: 'Series',
        onChanged: _setManualSeries,
        onManage: _openManualSeriesPicker,
        manageTooltip: 'Select or manage series',
      ),
      tabs: [
        LibraryAddManualPaneTab(
          id: 'main',
          label: 'Main',
          icon: Icons.article_outlined,
          content: buildFields(
            const {'catalog_title', 'issue_number'},
            'Main',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'edition',
          label: 'Edition Details',
          icon: Icons.inventory_2_outlined,
          content: buildFields(
            const {
              'variant',
              'edition_title',
              'barcode',
              'isbn',
              'upc',
              'physical_format',
              'cover_date',
              'release_date',
            },
            'Edition details',
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'details',
          label: 'Details',
          icon: Icons.info_outline,
          content: buildFields(
            const {
              'publisher',
              'imprint',
              'series_group',
              'page_count',
              'age_rating',
              'genres',
              'language',
              'country',
              'crossover',
              'story_arcs',
            },
            'Publication details',
          ),
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
              () =>
                  comicDraft.characters.add(EditableComicCharacter.custom('')),
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
          content: buildFields(
            const {'cover_image_url'},
            'Cover',
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
      ],
    );
  }
}

Widget buildComicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return ComicAddManualPane(request: request);
}
