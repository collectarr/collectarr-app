import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/serial/serial_authority_dialog.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaAddManualPane extends ConsumerStatefulWidget {
  const MangaAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  ConsumerState<MangaAddManualPane> createState() => _MangaAddManualPaneState();
}

class _MangaAddManualPaneState extends ConsumerState<MangaAddManualPane> {
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _formatOptions = const [];
  List<SerialAuthorityEntry> _seriesEntries = const [];
  String? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
    _selectedSeriesId =
        widget.request.manualDraftAs<MangaAddManualDraft>().values.seriesId;
    _loadVocabularies();
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
        selectedTitle: widget.request.titleController.text,
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
      selectedTitle: widget.request.titleController.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedSeriesId = selected.coreSeriesId;
      widget.request.manualDraftAs<MangaAddManualDraft>().values.seriesId =
          selected.coreSeriesId ?? '';
      widget.request.titleController.value = TextEditingValue(
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
      widget.request.manualDraftAs<MangaAddManualDraft>().values.seriesId =
          match?.coreSeriesId ?? '';
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
    final palette = appPalette(context);
    final draft = widget.request.manualDraftAs<MangaAddManualDraft>();
    final request = widget.request;
    final schema = _schema();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.panel,
        border: Border(left: BorderSide(color: palette.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LibraryAddManualIntroCard(
              icon: request.type.identity.icon,
              accent: request.accent,
              title: 'Manual manga volume',
              subtitle:
                  'Set series, volume, and release details before saving to your collection.',
              badges: [
                const LibraryAddResultBadge('main'),
                libraryAddManualIntroBadge(
                  'owned defaults',
                  accent: request.accent,
                ),
                if (request.defaultLocationLabel != null)
                  libraryAddManualIntroBadge(
                    request.defaultLocationLabel!,
                    accent: request.accent,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  LibraryFormSection(
                    title: 'Series',
                    accent: request.accent,
                    child: SingleValuePickField(
                      controller: request.titleController,
                      options: [
                        for (final entry in _seriesEntries) entry.title,
                      ],
                      label: 'Series',
                      onChanged: _setManualSeries,
                      onManage: _openManualSeriesPicker,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AddSchemaRenderer<MangaAddManualDraft>(
                    schema: schema,
                    draft: draft,
                    showFooter: false,
                    onSubmit: (_) async {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LibraryAddManualActionBar(request: request),
          ],
        ),
      ),
    );
  }
}

Widget buildMangaAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return MangaAddManualPane(request: request);
}
