import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/library/add/controllers/library_add_dialog_requests.dart';
import 'package:collectarr_app/features/library/add/library_add_manual_intro_card.dart';
import 'package:collectarr_app/features/library/add/library_add_result_badge.dart';
import 'package:collectarr_app/features/library/add/panes/library_add_manual_action_bar.dart';
import 'package:collectarr_app/features/library/add/schema/add_schema_renderer.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_schema.dart';
import 'package:collectarr_app/features/library/kinds/book/add/book_add_manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_visual_primitives.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookAddManualPane extends ConsumerStatefulWidget {
  const BookAddManualPane({super.key, required this.request});

  final LibraryAddManualPaneRequest request;

  @override
  ConsumerState<BookAddManualPane> createState() => _BookAddManualPaneState();
}

class _BookAddManualPaneState extends ConsumerState<BookAddManualPane> {
  List<String> _publisherOptions = const [];
  List<String> _physicalFormatOptions = const [];

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
      CatalogMediaKind.book,
    );
  }

  Future<void> _loadVocabularies() async {
    final db = ref.read(localDatabaseProvider);
    final draft = widget.request.manualDraftAs<BookAddManualDraft>();
    final formats = _currentPhysicalFormats();
    final results = await Future.wait<dynamic>([
      loadSingleValuePickListOptions(
        db,
        listName: BookVocabularyIds.publisher.value,
        mediaKind: CatalogMediaKind.book.apiValue,
        selectedValue: draft.publisherController.text,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: BookVocabularyIds.format.value,
        mediaKind: CatalogMediaKind.book.apiValue,
        builtInValues: [for (final format in formats) format.label],
        selectedValue: draft.physicalFormatLabelController.text,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _publisherOptions = List<String>.from(results[0] as List<String>);
      _physicalFormatOptions = List<String>.from(results[1] as List<String>);
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
      mediaKind: CatalogMediaKind.book.apiValue,
      builtInValues: builtInValues,
    );
    if (!mounted) return;
    await _loadVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final draft = widget.request.manualDraftAs<BookAddManualDraft>();
    final request = widget.request;
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
              title: 'Manual book',
              subtitle:
                  'Set identity and publication details before saving to your library.',
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
                    title: 'Identity',
                    accent: request.accent,
                    child: TextField(
                      controller: request.titleController,
                      decoration: const InputDecoration(
                        labelText: 'Book Title',
                        prefixIcon: Icon(Icons.book_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AddSchemaRenderer<BookAddManualDraft>(
                    schema: bookAddSchemaFor(
                      publisherOptions: _publisherOptions.isEmpty
                          ? BookVocabularies.publisher.builtIns
                          : _publisherOptions,
                      formatOptions: _physicalFormatOptions.isEmpty
                          ? BookVocabularies.format.builtIns
                          : _physicalFormatOptions,
                      onManagePublisher: () => _manageSingleValuePickList(
                        listName: BookVocabularyIds.publisher.value,
                        label: 'Publishers',
                      ),
                      onManageFormat: () => _manageSingleValuePickList(
                        listName: BookVocabularyIds.format.value,
                        label: 'Physical Formats',
                        builtInValues: [
                          for (final format in _currentPhysicalFormats())
                            format.label,
                        ],
                      ),
                    ),
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

Widget buildBookAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return BookAddManualPane(request: request);
}
