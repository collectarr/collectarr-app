import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/pick_lists/models/vocabulary_id.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_pane_shell.dart';
import 'package:collectarr_app/features/library/schema/library_form_schema.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/serial/library_series_selector_field.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/manga/add/manga_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/manga/vocabulary/manga_vocabularies.dart';
import 'package:collectarr_app/features/library/edit/fields/library_external_links_draft_editor.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MangaAddManualPane extends ConsumerStatefulWidget {
  const MangaAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  ConsumerState<MangaAddManualPane> createState() => _MangaAddManualPaneState();
}

class _MangaAddManualPaneState extends ConsumerState<MangaAddManualPane> {
  late final LocalDatabase _database;
  List<String> _publisherOptions = const [];
  List<String> _imprintOptions = const [];
  List<String> _formatOptions = const [];

  @override
  void initState() {
    super.initState();
    _database = ref.read(localDatabaseProvider);
    _loadVocabularies();
  }

  Future<void> _loadVocabularies() async {
    final draft = widget.request.manualDraftAs<MangaAddManualDraft>();
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        _database,
        listName: MangaVocabularyIds.publisher.value,
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedValue: draft.values.publisher,
      ),
      loadSingleValuePickListOptions(
        _database,
        listName: MangaVocabularyIds.imprint.value,
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedValue: draft.values.imprint,
      ),
      loadSingleValuePickListOptions(
        _database,
        listName: MangaVocabularyIds.format.value,
        mediaKind: CatalogMediaKind.manga.apiValue,
        selectedValue: draft.values.format,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _imprintOptions = List<String>.from(results[1] as List<String>);
      _formatOptions = List<String>.from(results[2] as List<String>);
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

  @override
  Widget build(BuildContext context) {
    final draft = widget.request.manualDraftAs<MangaAddManualDraft>();
    final request = widget.request;
    LibraryFormSchema<MangaAddManualDraft> schemaFor(
      Set<String> fieldIds,
      String sectionLabel,
    ) =>
        mangaAddSchemaFor(
          fieldIds: fieldIds,
          sectionLabels: {
            'volume': sectionLabel,
            'publication': sectionLabel,
          },
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

    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required Set<String> fieldIds,
      required String sectionLabel,
      bool validateSchema = false,
    }) =>
        LibraryAddManualPaneTab.fromSchema<MangaAddManualDraft>(
          id: id,
          label: label,
          icon: icon,
          schema: schemaFor(fieldIds, sectionLabel),
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
          validateSchema: validateSchema,
        );

    return LibraryAddManualPaneShell(
      request: request,
      identityDetails: LibrarySeriesSelectorField(
        database: _database,
        mediaKind: CatalogMediaKind.manga.apiValue,
        initialTitle: draft.values.seriesTitle,
        initialSeriesId:
            draft.values.seriesId.isEmpty ? null : draft.values.seriesId,
        onChanged: (title, coreSeriesId) {
          draft.values
            ..seriesTitle = title
            ..seriesId = coreSeriesId ?? '';
          request.onManualDraftChanged?.call();
        },
      ),
      tabs: [
        schemaTab(
          id: 'main',
          label: 'Main',
          icon: Icons.menu_book_outlined,
          fieldIds: const {'catalog_title', 'volume_number', 'series_group'},
          sectionLabel: 'Main',
          validateSchema: true,
        ),
        schemaTab(
          id: 'edition',
          label: 'Edition Details',
          icon: Icons.inventory_2_outlined,
          fieldIds: const {
            'release_title',
            'variant',
            'format',
            'binding',
            'publisher',
            'imprint',
            'isbn',
            'barcode',
            'language',
            'release_date',
            'page_count',
            'publication_year',
            'release_description',
          },
          sectionLabel: 'Edition details',
        ),
        schemaTab(
          id: 'details',
          label: 'Details',
          icon: Icons.info_outline,
          fieldIds: const {
            'authors',
            'artists',
            'characters',
            'genres',
            'themes',
            'age_rating',
            'country',
            'demographic',
            'publication_status',
            'serialization_platform',
          },
          sectionLabel: 'Details',
        ),
        schemaTab(
          id: 'plot',
          label: 'Plot',
          icon: Icons.notes_outlined,
          fieldIds: const {'synopsis'},
          sectionLabel: 'Plot',
        ),
        schemaTab(
          id: 'covers',
          label: 'Covers',
          icon: Icons.camera_alt_outlined,
          fieldIds: const {'cover_image_url', 'back_cover_image_url'},
          sectionLabel: 'Covers',
        ),
        LibraryAddManualPaneTab(
          id: 'links',
          label: 'Links',
          icon: Icons.public,
          content: LibraryExternalLinksDraftEditor(
            links: draft.externalLinks,
            accent: request.accent,
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
