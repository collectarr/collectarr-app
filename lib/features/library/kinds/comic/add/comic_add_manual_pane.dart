import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/serial_authority_dialog.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicAddManualPane extends ConsumerStatefulWidget {
  const ComicAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  ConsumerState<ComicAddManualPane> createState() => _ComicAddManualPaneState();
}

class _ComicAddManualPaneState extends ConsumerState<ComicAddManualPane> {
  List<String> _publisherOptions = const [];
  List<String> _physicalFormatOptions = const [];
  List<SerialAuthorityEntry> _seriesEntries = const [];
  String? _selectedSeriesId;

  @override
  void initState() {
    super.initState();
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
    final db = ref.read(localDatabaseProvider);
    final comicDraft = widget.request.manualDraftAs<ComicAddManualDraft>();
    final formats = _currentPhysicalFormats();
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: ComicVocabularyIds.publisher.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: ComicVocabularies.publisher.builtIns,
        selectedValue: comicDraft.publisherController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: ComicVocabularyIds.physicalFormat.value,
        mediaKind: CatalogMediaKind.comic.apiValue,
        builtInValues: [for (final format in formats) format.label],
        selectedValue: comicDraft.physicalFormatLabelController.text,
      ),
      SerialAuthorityRepository(db).searchEntries(
        mediaKind: CatalogMediaKind.comic.apiValue,
        selectedTitle: widget.request.titleController.text,
        selectedSeriesId: _selectedSeriesId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _physicalFormatOptions = List<String>.from(results[1] as List<String>);
      _seriesEntries = List<SerialAuthorityEntry>.from(
          results[2] as List<SerialAuthorityEntry>);
    });
  }

  Future<void> _openManualSeriesPicker() async {
    final selected = await showSeriesPickerDialog(
      context: context,
      db: ref.read(localDatabaseProvider),
      mediaKind: CatalogMediaKind.comic.apiValue,
      selectedTitle: widget.request.titleController.text,
      selectedSeriesId: _selectedSeriesId,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedSeriesId = selected.coreSeriesId;
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
    final palette = appPalette(context);
    final comicDraft = widget.request.manualDraftAs<ComicAddManualDraft>();
    final request = widget.request;
    final schema = comicAddSchemaFor(
      publisherOptions: _publisherOptions.isEmpty
          ? ComicVocabularies.publisher.builtIns
          : _publisherOptions,
      physicalFormatOptions: _physicalFormatOptions.isEmpty
          ? [
              for (final format in _currentPhysicalFormats()) format.label,
            ]
          : _physicalFormatOptions,
      onManagePublisher: () => _manageSingleValuePickList(
        listName: ComicVocabularyIds.publisher.value,
        label: 'Publishers',
      ),
      onManagePhysicalFormat: () => _manageSingleValuePickList(
        listName: ComicVocabularyIds.physicalFormat.value,
        label: 'Physical Formats',
        builtInValues: [
          for (final format in _currentPhysicalFormats()) format.label,
        ],
      ),
    );
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
              title: 'Manual comic issue',
              subtitle:
                  'Set issue basics here, then review collector fields before saving.',
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
                      manageTooltip: 'Select or manage series',
                    ),
                  ),
                  AddSchemaRenderer<ComicAddManualDraft>(
                    schema: schema,
                    draft: comicDraft,
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

Widget buildComicAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return ComicAddManualPane(request: request);
}
