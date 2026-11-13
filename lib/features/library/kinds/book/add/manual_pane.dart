import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_editor_dialog.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_options.dart';
import 'package:collectarr_app/features/library/add/controllers/dialog_requests.dart';
import 'package:collectarr_app/features/library/add/panes/manual_pane_shell.dart';
import 'package:collectarr_app/features/library/add/panes/status_strip.dart';
import 'package:collectarr_app/features/library/forms/schema.dart';
import 'package:collectarr_app/features/library/config/physical_media_formats.dart';
import 'package:collectarr_app/features/library/kinds/book/add/schema.dart';
import 'package:collectarr_app/features/library/kinds/book/add/manual_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/catalog_form_draft.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/catalog_form_field_ids.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/external_links_editor.dart';
import 'package:collectarr_app/features/library/kinds/book/forms/image_type_field.dart';
import 'package:collectarr_app/features/library/kinds/book/vocabulary/book_vocabularies.dart';
import 'package:collectarr_app/features/library/providers/media_catalog_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter/material.dart';
import '../edit/covers_tab.dart';
import '../edit/personal_form_layout.dart';
import 'draft.dart';
import 'copy_fields.dart';
import 'read_history.dart';
import 'package:collectarr_app/features/library/add/panes/manual_personal_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';

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
        selectedValue: draft.values.publisher,
      ),
      loadSingleValuePickListOptions(
        db,
        listName: BookVocabularyIds.format.value,
        mediaKind: CatalogMediaKind.book.apiValue,
        builtInValues: [for (final format in formats) format.label],
        selectedValue: draft.values.format,
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
    final draft = widget.request.manualDraftAs<BookAddManualDraft>();
    final request = widget.request;
    final copyDraft =
        request.kindDraft as BookAddDraft? ?? const BookAddDraft();

    LibraryFormSchema<BookCatalogFormDraft> schemaFor(
      Set<String> fieldIds, {
      Map<String, String> sectionLabels = const {},
    }) =>
        bookAddSchemaFor(
          fieldIds: fieldIds,
          sectionLabels: sectionLabels,
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
              for (final format in _currentPhysicalFormats()) format.label,
            ],
          ),
        );

    LibraryAddManualPaneTab schemaTab({
      required String id,
      required String label,
      required IconData icon,
      required Set<String> fieldIds,
      Map<String, String> sectionLabels = const {},
      bool validateSchema = false,
    }) =>
        LibraryAddManualPaneTab.fromSchema<BookCatalogFormDraft>(
          id: id,
          label: label,
          icon: icon,
          schema: schemaFor(fieldIds, sectionLabels: sectionLabels),
          draft: draft,
          mediaKind: request.kind.apiValue,
          onVocabularyValueChanged: request.onVocabularyValueChanged,
          onVocabularyValuesChanged: request.onVocabularyValuesChanged,
          onChanged: request.onManualDraftChanged,
          validateSchema: validateSchema,
        );

    void updateCopy(BookAddDraft value) {
      request.onKindDraftChanged?.call(value);
      setState(() {});
    }

    return LibraryAddManualPaneShell(
      request: request,
      footerContent: LibraryAddStatusStrip(
        request: request,
        indexValue: copyDraft.indexNumber,
        quantity: copyDraft.quantity,
        onIndexChanged: (value) =>
            updateCopy(copyDraft.copyWith(indexNumber: value)),
        onQuantityChanged: (value) =>
            updateCopy(copyDraft.copyWith(quantity: value)),
      ),
      tabOrder: const [
        'main',
        'details',
        'credits',
        'personal',
        'custom_fields',
        'read_history',
        'value',
        'covers',
        'my_images',
        'plot',
        'links'
      ],
      tabs: [
        schemaTab(
          id: 'main',
          label: 'Main',
          icon: AppIcons.book,
          fieldIds: bookMainFieldIds,
          validateSchema: true,
          sectionLabels: const {
            'edition': 'Edition',
            'publication': 'Publication',
          },
        ),
        schemaTab(
          id: 'details',
          label: 'Details',
          icon: AppIcons.tabDetails,
          fieldIds: bookDetailsFieldIds,
        ),
        LibraryAddManualPaneTab(
          id: 'personal',
          label: 'Personal',
          icon: AppIcons.tabPersonal,
          content: LibraryAddManualPersonalTab(
            request: request,
            fieldKeys: const {
              'owner_label',
              'condition',
              'location_id',
              'tags',
              'personal_notes'
            },
            layoutBuilder: bookPersonalFormLayout,
            fieldOverrides: {
              'rating': BookManualRatingField(request: request),
              ...bookManualCopyFields(copyDraft, updateCopy),
            },
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'read_history',
          label: 'Read History',
          icon: AppIcons.bookReader,
          content: BookManualReadHistory(
            request: request,
            events: copyDraft.readEvents,
            pageCount: draft.values.pageCount,
            onEventsChanged: (events) =>
                updateCopy(copyDraft.copyWith(readEvents: events)),
          ),
        ),
        LibraryAddManualPaneTab(
          id: 'value',
          label: 'Value',
          icon: AppIcons.tabValue,
          content: LibraryAddManualPersonalTab(
            request: request,
            title: 'Value',
            fieldKeys: const {
              'purchase_date',
              'price_paid_cents',
              'purchase_store'
            },
            layoutBuilder: bookValueFormLayout,
            fieldOverrides: bookManualValueFields(copyDraft, updateCopy),
          ),
        ),
        schemaTab(
          id: 'credits',
          label: 'Credits',
          icon: AppIcons.tabCredits,
          fieldIds: bookCreditFieldIds,
          sectionLabels: const {'publication': 'Credits'},
        ),
        LibraryAddManualPaneTab(
          id: 'links',
          label: 'Links',
          icon: AppIcons.tabLinks,
          content: BookExternalLinksEditor(
              links: draft.externalLinks,
              accent: request.accent,
              onChanged: request.onManualDraftChanged),
        ),
        LibraryAddManualPaneTab(
          id: 'covers',
          label: 'Covers',
          icon: AppIcons.tabCovers,
          content: BookCoversTab(
            images: request.itemImages,
            coverImageUrl: draft.values.coverImageUrl,
            originalCoverImageUrl: '',
            backCoverImageUrl: draft.values.backCoverImageUrl,
            originalBackCoverImageUrl: '',
            onBackCoverImageUrlChanged: (value) {
              draft.values.backCoverImageUrl = value;
              request.onManualDraftChanged?.call();
            },
            onCoverImageUrlChanged: (url) {
              draft.values.coverImageUrl = url;
              request.onManualDraftChanged?.call();
            },
            onEdits: request.onItemImagesChanged ?? (_) {},
            searchTitle: () => draft.catalogTitle,
          ),
        ),
        schemaTab(
          id: 'plot',
          label: 'Plot',
          icon: AppIcons.tabDescription,
          fieldIds: bookPlotFieldIds,
          sectionLabels: const {'publication': 'Plot'},
        ),
        LibraryAddManualPaneTab(
          id: 'my_images',
          label: 'My Images',
          icon: AppIcons.tabImages,
          content: ItemImagesEditSection(
            images: [
              for (final image in request.itemImages)
                if (image.imageType != 'front_cover' &&
                    image.imageType != 'back_cover')
                  image,
            ],
            accent: request.accent,
            helperText: bookImagesHelperText,
            defaultImageType: bookDefaultImageType,
            uniqueImageTypes: const {},
            imageTypeFieldBuilder: buildBookImageTypeField,
            onChanged: request.onItemImagesChanged ?? (_) {},
          ),
        ),
      ],
    );
  }
}

Widget buildBookAddManualPane(
  BuildContext context,
  LibraryAddManualPaneRequest request,
) {
  return BookAddManualPane(request: request);
}
