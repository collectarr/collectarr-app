import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_shell_state.dart';
import 'package:collectarr_app/features/library/edit/sections/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_host.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_models.dart';
import 'package:collectarr_app/features/library/schema/library_field_spec.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_dropdown_pick_field.dart';
import 'package:collectarr_app/features/pick_lists/models/universal_vocabularies.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_select_dialog.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_capability_types.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/serial/serial_authority_dialog.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicEditHostAdapter implements ComicEditHost {
  ComicEditHostAdapter({
    required this.context,
    required this.draft,
    required this.media,
    required this.accent,
    required this.scope,
    required this.markDirty,
  });

  final BuildContext context;
  final LibraryEditShellState draft;
  final ComicMedia media;
  final Color accent;
  final LibraryEntityScope scope;
  final VoidCallback markDirty;

  ComicEditDraft? get _comicDraft => draft.session.workSession is ComicEditDraft
      ? draft.session.workSession as ComicEditDraft
      : null;

  Widget _comicDropdown({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    String? listName,
    ValueChanged<String?>? onChanged,
  }) {
    final current = controller.text.trim();
    return LibraryDropdownPickField<String>(
      label: label,
      value: current.isEmpty ? null : current,
      options: [
        for (final option in options)
          LibraryFieldOption<String>(value: option, label: option),
      ],
      allowCustomValue: true,
      openPicker: ({required label, required selectedValue, required options}) {
        final db = listName == null
            ? null
            : ProviderScope.containerOf(context, listen: false)
                .read(localDatabaseProvider);
        return showPickListSelectDialog(
          context: context,
          label: label,
          options: options,
          selectedValue: selectedValue,
          listName: listName,
          mediaKind: draft.type.kind.apiValue,
          allowUserValues: true,
          db: db,
        );
      },
      onChanged: (value) {
        controller.text = value ?? '';
        if (onChanged == null) {
          markDirty();
        } else {
          onChanged(value);
        }
      },
    );
  }

  @override
  BuildContext get comicContext => context;

  @override
  ProviderContainer get comicRef => ProviderScope.containerOf(context);

  @override
  Color get comicAccent => accent;

  @override
  LibraryKindRegistration get comicLibraryType => draft.type;

  @override
  ComicMedia get comicMedia => media;

  @override
  List<ItemImage> get comicItemImages => draft.itemImages;

  @override
  LibraryEditPresentationState get comicEditPresentation =>
      comicKindEditCapabilities.presentationCapability.presentation.builder
          .build(
        context: LibraryEditPresentationContext(
          isOwned: draft.isOwned,
          isTrackingOnly: draft.isTrackingOnly,
          hasTrackingContext: draft.hasTrackingContext,
          hasWishlistContext: draft.hasWishlistContext,
          isDigitalFormat: (_comicDraft
                      ?.comicEdit.physicalFormatLabelController.text
                      .trim()
                      .toLowerCase() ??
                  '') ==
              'digital',
          hasPhysicalFormats: true,
          hasOwnedTargetOptions: false,
          hasAdditionalTargetOptions: false,
          hasCustomFields: draft.customFieldDefinitions.isNotEmpty,
          scope: scope,
        ),
      );

  @override
  List<EditableComicCreator> get comicCreators =>
      _comicDraft?.comicEdit.creators ?? const [];

  @override
  List<EditableComicCharacter> get comicCharacters =>
      _comicDraft?.comicEdit.characters ?? const [];

  @override
  List<Map<String, TextEditingController>> get comicLinks =>
      _comicDraft?.comicEdit.links ?? const [];

  @override
  TextEditingController get comicCharacterDraftController =>
      _comicDraft?.comicEdit.characterDraftController ??
      TextEditingController();

  @override
  TextEditingController get comicTitleController =>
      draft.formFields.controller(ComicCanonicalEditField.title);

  @override
  TextEditingController get comicOriginalTitleController =>
      draft.formFields.controller(ComicCanonicalEditField.originalTitle);

  @override
  TextEditingController get comicEditionTitleController =>
      _comicDraft?.comicEdit.editionTitleController ?? TextEditingController();

  @override
  TextEditingController get comicVariantController =>
      _comicDraft?.comicEdit.variantController ?? TextEditingController();

  @override
  TextEditingController get comicNumberController =>
      _comicDraft?.comicEdit.numberController ?? TextEditingController();

  @override
  TextEditingController get comicBarcodeController =>
      _comicDraft?.comicEdit.barcodeController ?? TextEditingController();

  @override
  TextEditingController get comicPhysicalFormatLabelController =>
      _comicDraft?.comicEdit.physicalFormatLabelController ??
      TextEditingController();

  @override
  TextEditingController get comicCoverDateController =>
      _comicDraft?.comicEdit.coverDateController ?? TextEditingController();

  @override
  TextEditingController get comicReleaseDateController =>
      _comicDraft?.comicEdit.releaseDateController ?? TextEditingController();

  @override
  TextEditingController get comicLocalizedTitleController =>
      draft.formFields.controller(ComicCanonicalEditField.localizedTitle);

  @override
  TextEditingController get comicSearchAliasesController =>
      draft.formFields.controller(ComicCanonicalEditField.searchAliases);

  @override
  TextEditingController get comicSortKeyController =>
      draft.formFields.controller(ComicCanonicalEditField.sortTitle);

  @override
  TextEditingController get comicAgeRatingController =>
      _comicDraft?.comicEdit.ageRatingController ?? TextEditingController();

  @override
  TextEditingController get comicPageCountController =>
      _comicDraft?.comicEdit.pageCountController ?? TextEditingController();

  @override
  TextEditingController get comicGenresEditController =>
      _comicDraft?.comicEdit.genresEditController ?? TextEditingController();

  @override
  TextEditingController get comicLanguageController =>
      _comicDraft?.comicEdit.languageController ?? TextEditingController();

  @override
  TextEditingController get comicOwnerLabelController =>
      draft.personal.ownerLabelController;

  @override
  TextEditingController get comicTagsController =>
      draft.personal.tagsController;

  static final _dummyStorageController = TextEditingController();

  @override
  TextEditingController get comicStorageDeviceController =>
      _dummyStorageController;

  @override
  TextEditingController get comicStorageSlotController =>
      _dummyStorageController;

  @override
  TextEditingController get comicTrackingNotesController =>
      draft.tracking.trackingNotesController;

  @override
  TextEditingController get comicNotesController =>
      draft.personal.notesController;

  @override
  TextEditingController get comicTrackingController =>
      draft.tracking.trackingController;

  @override
  TextEditingController get comicRatingController =>
      draft.tracking.ratingController;

  @override
  TextEditingController get comicGradeController =>
      draft.personal.gradeController;

  @override
  TextEditingController get comicConditionController =>
      draft.personal.conditionController;

  @override
  TextEditingController get comicRawOrSlabbedController =>
      _comicDraft?.rawOrSlabbedController ?? TextEditingController();

  @override
  TextEditingController get comicGradingCompanyController =>
      _comicDraft?.gradingCompanyController ?? TextEditingController();

  @override
  TextEditingController get comicGraderNotesController =>
      _comicDraft?.graderNotesController ?? TextEditingController();

  @override
  TextEditingController get comicSignedByController =>
      _comicDraft?.signedByController ?? TextEditingController();

  @override
  TextEditingController get comicLabelTypeController =>
      _comicDraft?.labelTypeController ?? TextEditingController();

  TextEditingController get comicPageQualityController =>
      _comicDraft?.pageQualityController ?? TextEditingController();

  @override
  TextEditingController get comicCertificationNumberController =>
      _comicDraft?.certificationNumberController ?? TextEditingController();

  @override
  TextEditingController get comicCoverPriceController =>
      _comicDraft?.coverPriceController ?? TextEditingController();

  @override
  TextEditingController get comicKeyReasonController =>
      _comicDraft?.keyReasonController ?? TextEditingController();

  @override
  TextEditingController get comicKeyCategoryController =>
      _comicDraft?.keyCategoryController ?? TextEditingController();

  @override
  TextEditingController get comicPriceController =>
      draft.personal.priceController;

  @override
  TextEditingController get comicCurrencyController =>
      draft.personal.currencyController;

  @override
  TextEditingController get comicMarketValueController =>
      draft.personal.marketValueController;

  @override
  TextEditingController get comicPurchaseDateController =>
      draft.personal.purchaseDateController;

  @override
  TextEditingController get comicPurchaseStoreController =>
      draft.personal.purchaseStoreController;

  @override
  TextEditingController get comicSellPriceController =>
      draft.personal.sellPriceController;

  @override
  TextEditingController get comicSoldToController =>
      draft.personal.soldToController;

  @override
  TextEditingController get comicCoverController =>
      draft.formFields.controller(ComicCanonicalEditField.coverImage);

  @override
  TextEditingController get comicThumbnailController =>
      draft.formFields.controller(ComicCanonicalEditField.thumbnailImage);

  @override
  bool get comicKeyComic => _comicDraft?.keyComic ?? false;

  @override
  set comicKeyComic(bool value) {
    if (_comicDraft != null) {
      _comicDraft!.keyComic = value;
      markDirty();
    }
  }

  @override
  DateTime? get comicLastBagBoardDate => _comicDraft?.lastBagBoardDate;

  @override
  set comicLastBagBoardDate(DateTime? value) {
    if (_comicDraft != null) {
      _comicDraft!.lastBagBoardDate = value;
      markDirty();
    }
  }

  @override
  DateTime? get comicStartedAt => draft.tracking.startedAt;

  @override
  set comicStartedAt(DateTime? value) {
    draft.tracking.startedAt = value;
    markDirty();
  }

  @override
  DateTime? get comicFinishedAt => draft.tracking.finishedAt;

  @override
  set comicFinishedAt(DateTime? value) {
    draft.tracking.finishedAt = value;
    markDirty();
  }

  @override
  DateTime? get comicSoldAt => draft.personal.soldAt;

  @override
  set comicSoldAt(DateTime? value) {
    draft.personal.soldAt = value;
    markDirty();
  }

  @override
  String? get comicSelectedBundleReleaseId =>
      draft.personal.selectedOwnedTargetRef?.entityType.apiValue ==
              'bundle_release'
          ? draft.personal.selectedOwnedTargetRef?.id
          : null;

  @override
  set comicSelectedBundleReleaseId(String? value) {
    final id = value?.trim();
    draft.personal.selectedOwnedTargetRef = id == null || id.isEmpty
        ? null
        : CatalogEntityRef(
            kind: draft.type.kind,
            entityType: const CatalogEntityTypeId('bundle_release'),
            id: id,
            rootId: draft.kindItem.reference.id,
          );
    markDirty();
  }

  @override
  bool get comicShowPhysicalOwnedFields =>
      draft.isOwned &&
      (_comicDraft?.comicEdit.physicalFormatLabelController.text
              .trim()
              .toLowerCase() !=
          'digital');

  @override
  String get comicSelectedOwnedAnchorType =>
      switch (draft.personal.selectedOwnedTargetRef?.entityType.apiValue) {
        'edition' => 'edition',
        'release' => 'variant',
        'bundle_release' => 'bundle_release',
        _ => 'item',
      };

  @override
  List<ItemImageEdit> get comicItemImageEdits => draft.itemImageEdits;

  @override
  set comicItemImageEdits(List<ItemImageEdit> value) {
    draft.itemImageEdits = List.of(value);
    markDirty();
  }

  Future<List<SerialAuthorityEntry>> get _comicSeriesEntries {
    final comicDraft = _comicDraft;
    if (comicDraft == null) {
      return Future.value(const <SerialAuthorityEntry>[]);
    }
    return comicDraft.seriesEntriesFuture ??= SerialAuthorityRepository(
      comicRef.read(localDatabaseProvider),
    ).searchEntries(
      mediaKind: draft.type.kind.apiValue,
    );
  }

  @override
  List<String> get comicGenreOptions => const [
        'Action',
        'Adventure',
        'Fantasy',
        'Horror',
        'Mystery',
        'Sci-Fi',
        'Superhero',
        'Thriller',
      ];

  @override
  List<String> get comicTagOptions => draft.tagOptions;

  @override
  List<String> get comicOwnerOptions => draft.ownerOptions;

  @override
  void comicMutateState(VoidCallback fn) {
    fn();
    markDirty();
  }

  @override
  void comicOpenEditTab(String id) {}

  @override
  Map<String, TextEditingController> comicCreateLinkControllers({
    String title = '',
    String url = '',
  }) {
    return _comicDraft?.comicEdit
            .createLinkControllers(title: title, url: url) ??
        {
          'title': TextEditingController(text: title),
          'url': TextEditingController(text: url),
        };
  }

  @override
  Widget buildComicCrossoverPickField({String label = 'Crossover'}) {
    return _comicDropdown(
      controller:
          _comicDraft?.comicEdit.crossoverController ?? TextEditingController(),
      label: label,
      options: draft.kindVocabularies[ComicVocabularyIds.crossover.value] ??
          const [],
      listName: ComicVocabularyIds.crossover.value,
    );
  }

  @override
  Widget buildComicStoryArcPickField({String label = 'Story Arc'}) {
    return _comicDropdown(
      controller:
          _comicDraft?.comicEdit.storyArcsController ?? TextEditingController(),
      label: label,
      options:
          draft.kindVocabularies[ComicVocabularyIds.storyArc.value] ?? const [],
      listName: ComicVocabularyIds.storyArc.value,
    );
  }

  @override
  Widget buildComicCountryPickField({String label = 'Country'}) {
    return _comicDropdown(
      controller:
          _comicDraft?.comicEdit.countryController ?? TextEditingController(),
      label: label,
      options: const [
        'United States',
        'United Kingdom',
        'Japan',
        'France',
        'Canada'
      ],
    );
  }

  @override
  Widget buildComicPageQualityPickField({String label = 'Page quality'}) {
    return _comicDropdown(
      controller: comicPageQualityController,
      label: label,
      options: draft.kindVocabularies[ComicVocabularyIds.pageQuality.value] ??
          ComicVocabularies.pageQuality.builtIns,
      listName: ComicVocabularyIds.pageQuality.value,
    );
  }

  @override
  Widget buildComicKeyCategoryPickField({String label = 'Key category'}) {
    return _comicDropdown(
      controller: comicKeyCategoryController,
      label: label,
      options: draft.kindVocabularies[ComicVocabularyIds.keyCategory.value] ??
          ComicVocabularies.keyCategory.builtIns,
      listName: ComicVocabularyIds.keyCategory.value,
    );
  }

  @override
  Widget buildComicSeriesField() {
    return FutureBuilder<List<SerialAuthorityEntry>>(
      future: _comicSeriesEntries,
      builder: (context, snapshot) {
        SerialAuthorityEntry? selectedSeries;
        return LibraryDropdownPickField<String>(
          label: 'Series',
          value: _comicDraft?.comicEdit.seriesTitleController.text,
          options: [
            for (final entry in snapshot.data ?? const <SerialAuthorityEntry>[])
              LibraryFieldOption<String>(
                value: entry.title,
                label: entry.title,
              ),
          ],
          openPicker: (
              {required label,
              required selectedValue,
              required options}) async {
            final db = ProviderScope.containerOf(context, listen: false)
                .read(localDatabaseProvider);
            selectedSeries = await showSeriesPickerDialog(
              context: context,
              db: db,
              mediaKind: draft.type.kind.apiValue,
              selectedTitle: selectedValue ?? '',
            );
            return selectedSeries?.title;
          },
          onChanged: (value) {
            if (value != null && value.isNotEmpty) {
              if (selectedSeries != null && _comicDraft != null) {
                _comicDraft!.comicEdit.seriesTitleController.text =
                    selectedSeries!.title;
                _comicDraft!.comicEdit.seriesId = selectedSeries!.id;
              }
              draft.formFields.controller(ComicCanonicalEditField.title).text =
                  value;
            }
            markDirty();
          },
        );
      },
    );
  }

  @override
  Widget buildComicPublisherField({String label = 'Publisher'}) {
    return _comicDropdown(
      controller:
          _comicDraft?.comicEdit.publisherController ?? TextEditingController(),
      label: label,
      options: draft.kindVocabularies[ComicVocabularyIds.publisher.value] ??
          ComicVocabularies.publisher.builtIns,
      listName: ComicVocabularyIds.publisher.value,
    );
  }

  @override
  Widget buildComicImprintField() {
    return _comicDropdown(
      controller:
          _comicDraft?.comicEdit.imprintController ?? TextEditingController(),
      label: 'Imprint',
      options: draft.kindVocabularies[ComicVocabularyIds.imprint.value] ??
          ComicVocabularies.imprint.builtIns,
      listName: ComicVocabularyIds.imprint.value,
    );
  }

  @override
  Widget buildComicSeriesGroupField({String label = 'Series Group'}) {
    return _comicDropdown(
      controller: _comicDraft?.comicEdit.seriesGroupController ??
          TextEditingController(),
      label: label,
      options: draft.kindVocabularies[ComicVocabularyIds.seriesGroup.value] ??
          ComicVocabularies.seriesGroup.builtIns,
      listName: ComicVocabularyIds.seriesGroup.value,
    );
  }

  @override
  Widget buildComicPhysicalFormatField({String label = 'Format'}) {
    return _comicDropdown(
      controller: _comicDraft?.comicEdit.physicalFormatLabelController ??
          TextEditingController(),
      label: label,
      options:
          draft.kindVocabularies[ComicVocabularyIds.physicalFormat.value] ??
              ComicVocabularies.physicalFormat.builtIns,
      listName: ComicVocabularyIds.physicalFormat.value,
    );
  }

  @override
  Widget buildComicTagsDropdownField({String label = 'Tags'}) {
    return TagPickListField(
      controller: draft.personal.tagsController,
      options: draft.tagOptions,
      label: label,
    );
  }

  @override
  Widget buildComicOwnerPickField({String label = 'Owner'}) {
    return _comicDropdown(
      controller: draft.personal.ownerLabelController,
      label: label,
      options: draft.ownerOptions,
      listName: UniversalVocabularies.owners.key,
    );
  }

  @override
  Widget buildComicOwnershipAnchorSelectionField() {
    return const SizedBox.shrink();
  }

  @override
  Widget buildComicEditionSelectionField() {
    return const SizedBox.shrink();
  }

  @override
  Widget buildComicVariantSelectionField() {
    return const SizedBox.shrink();
  }

  @override
  Widget buildComicBundleReleaseSelectionField({
    Key? fieldKey,
    required String label,
    required String? selectedBundleReleaseId,
    required ValueChanged<String?> onChanged,
  }) {
    return const SizedBox.shrink();
  }

  @override
  TextEditingController get comicIndexNumberController =>
      draft.personal.indexNumberController;

  @override
  TextEditingController get comicQuantityController =>
      draft.personal.quantityController;

  @override
  String? get comicCollectionStatus => draft.personal.collectionStatus;

  @override
  set comicCollectionStatus(String? value) {
    draft.personal.collectionStatus = value;
    markDirty();
  }

  @override
  String? get comicSelectedLocationId => draft.personal.selectedLocationId;

  @override
  String? get comicSelectedLocationName => draft.personal.availableLocations
      .where((l) => l.id == draft.personal.selectedLocationId)
      .firstOrNull
      ?.name;

  @override
  Widget buildComicCollectionStatusPickField(
      {String label = 'Collection Status'}) {
    return _comicDropdown(
      controller:
          TextEditingController(text: draft.personal.collectionStatus ?? ''),
      label: label,
      options: const [
        'In Collection',
        'Wishlist',
        'For Sale',
        'Sold',
        'On Loan'
      ],
      onChanged: (val) {
        draft.personal.collectionStatus = val;
        markDirty();
      },
    );
  }

  @override
  Widget buildComicLocationPickerField({String label = 'Location'}) {
    return InkWell(
      onTap: () async {
        final db =
            ProviderScope.containerOf(context).read(localDatabaseProvider);
        final locationId = await showLocationPickerDialog(
          context: context,
          db: db,
          currentLocationId: draft.personal.selectedLocationId,
        );
        if (locationId != null) {
          draft.personal.selectedLocationId = locationId;
          draft.personal.locationChanged = true;
          markDirty();
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.place),
        ),
        child: Text(
          comicSelectedLocationName ?? 'Pick location...',
          style: TextStyle(
            color: comicSelectedLocationName != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildComicFlexRow(
    List<Widget> children, {
    required List<int> flexes,
    double breakpoint = 880,
  }) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++)
          Expanded(
            flex: i < flexes.length ? flexes[i] : 1,
            child: children[i],
          ),
      ],
    );
  }
}
