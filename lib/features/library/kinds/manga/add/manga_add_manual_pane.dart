import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/serial/serial_authority_dialog.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaAddManualPane extends ConsumerStatefulWidget {
  const MangaAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  ConsumerState<MangaAddManualPane> createState() => _MangaAddManualPaneState();
}

class _MangaAddManualPaneState extends ConsumerState<MangaAddManualPane> {
  late final TextEditingController _seriesController;
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _formatOptions = const [];
  List<SerialAuthorityEntry> _seriesEntries = const [];
  String? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
    final draft = widget.request.manualDraftAs<MangaAddManualDraft>();
    _seriesController = TextEditingController(text: draft.values.seriesTitle);
    _selectedSeriesId = draft.values.seriesId;
    _loadVocabularies();
  }

  @override
  void dispose() {
    _seriesController.dispose();
    super.dispose();
  }

  Future<void> _loadVocabularies() async {
    final db = ref.read(localDatabaseProvider);
    final draft = widget.request.manualDraftAs<MangaAddManualDraft>();
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: MangaVocabularyIds.publisher.value,
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedValue: draft.values.publisher,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: MangaVocabularyIds.imprint.value,
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedValue: draft.values.imprint,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: MangaVocabularyIds.format.value,
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedValue: draft.values.format,
      ),
      SerialAuthorityRepository(db).searchEntries(
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedTitle: _seriesController.text,
        selectedSeriesId: _selectedSeriesId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _imprintOptions = List<String>.from(results[1] as List<String>);
      _formatOptions = List<String>.from(results[2] as List<String>);
      _seriesEntries = List<SerialAuthorityEntry>.from(
          results[3] as List<SerialAuthorityEntry>);
    });
  }

  Future<void> _openManualSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: CatalogMediaKind.manga.apiValue,
      selectedTitle: _seriesController.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedSeriesId = selected.coreSeriesId;
      final values = widget.request.manualDraftAs<MangaAddManualDraft>().values;
      values
        ..seriesId = selected.coreSeriesId ?? ''
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
      final values = widget.request.manualDraftAs<MangaAddManualDraft>().values;
      values
        ..seriesTitle = normalized
        ..seriesId = match?.coreSeriesId ?? '';
    });
  }

  Future<void> _managePublishers() async {
    await _manageVocabulary(MangaVocabularyIds.publisher, 'Publishers');
  }

  Future<void> _manageImprints() async {
    await _manageVocabulary(MangaVocabularyIds.imprint, 'Imprints');
  }

  Future<void> _manageFormats() async {
    await _manageVocabulary(MangaVocabularyIds.format, 'Formats');
  }

  Future<void> _manageVocabulary(
    VocabularyId<String> vocabularyId,
    String label,
  ) async {
    await showPickListEditorDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      listName: vocabularyId.value,
      label: label,
      mediaKind: CatalogMediaKind.manga.apiValue,
    );
    if (!mounted) return;
    await _loadVocabularies();
  }

  AddSchema<MangaAddManualDraft> _schema() {
    return mangaAddSchemaFor(
      publisherOptions: _publisherOptions.isEmpty
          ? MangaVocabularies.publisher.builtIns
          : _publisherOptions,
      imprintOptions: _imprintOptions.isEmpty
          ? MangaVocabularies.imprint.builtIns
          : _imprintOptions,
      formatOptions: _formatOptions.isEmpty
          ? MangaVocabularies.format.builtIns
          : _formatOptions,
      onManagePublisher: _managePublishers,
      onManageImprint: _manageImprints,
      onManageFormat: _manageFormats,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.request.manualDraftAs<MangaAddManualDraft>();
    final request = widget.request;
    final schema = _schema();
    final identitySchema = AddSchema<MangaAddManualDraft>(
      validate: schema.validate,
      sections: [schema.sections.first],
    );
    final publicationSchema = AddSchema<MangaAddManualDraft>(
      validate: schema.validate,
      sections: [schema.sections.last],
    );
    return LibraryAddManualPaneShell(
      request: request,
      identityDetails: SingleValuePickField(
        controller: _seriesController,
        options: [for (final entry in _seriesEntries) entry.title],
        label: 'Series',
        onChanged: _setManualSeries,
        onManage: _openManualSeriesPicker,
      ),
      tabs: [
        LibraryAddManualPaneTab(
          id: 'identity',
          label: 'Identity',
          icon: Icons.title,
          content: AddSchemaRenderer<MangaAddManualDraft>.embedded(
            schema: identitySchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'publication',
          label: 'Publication',
          icon: Icons.menu_book,
          content: AddSchemaRenderer<MangaAddManualDraft>.embedded(
            schema: publicationSchema,
            draft: draft,
            mediaKind: request.kind.apiValue,
            onVocabularyValueChanged: request.onVocabularyValueChanged,
            onVocabularyValuesChanged: request.onVocabularyValuesChanged,
            onChanged: request.onManualDraftChanged,
          ),
        ),
      ],
    );
  }
}

Widget buildMangaAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return MangaAddManualPane(request: request);
}
