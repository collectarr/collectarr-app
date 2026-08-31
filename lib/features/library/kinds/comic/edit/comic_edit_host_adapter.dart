import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/edit/library_edit_scope.dart';
import 'package:collectarr_app/features/library/kinds/comic/catalog/comic_catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/comic_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_host.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_models.dart';
import 'package:collectarr_app/features/library/location_picker_dialog.dart';
import 'package:collectarr_app/features/library/series/series_registry_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/ui/single_value_pick_field.dart';
import 'package:collectarr_app/ui/tag_pick_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComicEditHostAdapter implements ComicEditHost {
  ComicEditHostAdapter({
    required this.context,
    required this.draft,
    required this.catalogItem,
    required this.accent,
    required this.scope,
    required this.markDirty,
  });

  final BuildContext context;
  final LibraryEditDraft draft;
  final ComicCatalogItem catalogItem;
  final Color accent;
  final LibraryEditScope scope;
  final VoidCallback markDirty;

  ComicEditDraft? get _comicDraft => draft.kindDetails is ComicEditDraft
      ? draft.kindDetails as ComicEditDraft
      : null;

  @override
  BuildContext get comicContext => context;

  @override
  ProviderContainer get comicRef => ProviderScope.containerOf(context);

  @override
  Color get comicAccent => accent;

  @override
  LibraryTypeConfig get comicLibraryType => draft.type;

  @override
  ComicCatalogItem get comicCatalogItem => catalogItem;

  @override
  List<ItemImage> get comicItemImages => draft.itemImages;

  @override
  LibraryEditPresentationState get comicEditPresentation =>
      comicKindModule.edit.presentation.builder.build(
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
          hasEditionAnchors: false,
          hasBundleReleaseAnchors: false,
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
      draft.metadata.titleController;

  @override
  TextEditingController get comicOriginalTitleController =>
      draft.metadata.originalTitleController;

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
  TextEditingController get comicCoverDateYearPartController =>
      _comicDraft?.comicEdit.coverDateYearPartController ??
      TextEditingController();

  @override
  TextEditingController get comicCoverDateMonthPartController =>
      _comicDraft?.comicEdit.coverDateMonthPartController ??
      TextEditingController();

  @override
  TextEditingController get comicCoverDateDayPartController =>
      _comicDraft?.comicEdit.coverDateDayPartController ??
      TextEditingController();

  @override
  TextEditingController get comicReleaseDateController =>
      draft.metadata.releaseDateController;

  @override
  TextEditingController get comicReleaseDateYearPartController =>
      draft.metadata.releaseDateYearPartController;

  @override
  TextEditingController get comicReleaseDateMonthPartController =>
      draft.metadata.releaseDateMonthPartController;

  @override
  TextEditingController get comicReleaseDateDayPartController =>
      draft.metadata.releaseDateDayPartController;

  @override
  TextEditingController get comicLocalizedTitleController =>
      draft.metadata.localizedTitleController;

  @override
  TextEditingController get comicSearchAliasesController =>
      draft.metadata.searchAliasesController;

  @override
  TextEditingController get comicSortKeyController =>
      draft.metadata.sortKeyController;

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
      draft.metadata.coverController;

  @override
  TextEditingController get comicThumbnailController =>
      draft.metadata.thumbnailController;

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
      draft.personal.selectedBundleReleaseId;

  @override
  set comicSelectedBundleReleaseId(String? value) {
    draft.personal.selectedBundleReleaseId = value;
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
      draft.personal.selectedOwnedAnchorType.apiValue;

  @override
  List<ItemImageEdit> get comicItemImageEdits => draft.itemImageEdits;

  @override
  set comicItemImageEdits(List<ItemImageEdit> value) {
    draft.itemImageEdits = List.of(value);
    markDirty();
  }

  List<String> get comicSeriesOptions =>
      draft.seriesEntries.map((e) => e.title).toList();

  @override
  List<String> get comicGenreOptions =>
      draft.vocabulary?.genreOptions ??
      const [
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
  List<String> get comicTagOptions => draft.vocabulary?.tagOptions ?? const [];

  @override
  List<String> get comicOwnerOptions =>
      draft.vocabulary?.ownerOptions ?? const [];

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
    return SingleValuePickField(
      controller:
          _comicDraft?.comicEdit.crossoverController ?? TextEditingController(),
      label: label,
      options: draft.vocabulary?.crossoverOptions ?? const [],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicStoryArcPickField({String label = 'Story Arc'}) {
    return SingleValuePickField(
      controller:
          _comicDraft?.comicEdit.storyArcsController ?? TextEditingController(),
      label: label,
      options: draft.vocabulary?.storyArcOptions ?? const [],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicCountryPickField({String label = 'Country'}) {
    return SingleValuePickField(
      controller:
          _comicDraft?.comicEdit.countryController ?? TextEditingController(),
      label: label,
      options: draft.vocabulary?.countryOptions ?? const [],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicPageQualityPickField({String label = 'Page quality'}) {
    return SingleValuePickField(
      controller: comicPageQualityController,
      label: label,
      options: const [
        'White',
        'Off-White to White',
        'Off-White',
        'Cream to Off-White',
        'Cream',
        'Slightly Brittle',
      ],
    );
  }

  @override
  Widget buildComicKeyCategoryPickField({String label = 'Key category'}) {
    return SingleValuePickField(
      controller: comicKeyCategoryController,
      label: label,
      options: const [
        '1st Appearance',
        'Origin',
        'Death',
        'Iconic Cover',
        'First Issue',
        'Cameo',
        'Major Event',
      ],
    );
  }

  @override
  Widget buildComicSeriesField() {
    return SingleValuePickField(
      controller: _comicDraft?.comicEdit.seriesTitleController ??
          TextEditingController(),
      label: 'Series',
      options: comicSeriesOptions,
      showPickerListAction: true,
      onChanged: (value) {
        if (value != null && value.isNotEmpty) {
          draft.metadata.titleController.text = value;
        }
        markDirty();
      },
      onManage: () async {
        final db = ProviderScope.containerOf(context, listen: false)
            .read(localDatabaseProvider);
        final entry = await showSeriesPickerDialog(
          context: context,
          db: db,
          mediaKind: draft.type.workspace.kind.apiValue,
          selectedTitle:
              _comicDraft?.comicEdit.seriesTitleController.text ?? '',
        );
        if (entry != null) {
          if (_comicDraft != null) {
            _comicDraft!.comicEdit.seriesTitleController.text = entry.title;
            _comicDraft!.comicEdit.seriesId = entry.id;
          }
          draft.metadata.titleController.text = entry.title;
          markDirty();
        }
      },
      manageTooltip: 'Select or manage series',
    );
  }

  @override
  Widget buildComicPublisherField({String label = 'Publisher'}) {
    return SingleValuePickField(
      controller:
          _comicDraft?.comicEdit.publisherController ?? TextEditingController(),
      label: label,
      options: draft.vocabulary?.publisherOptions ?? const [],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicImprintField() {
    return SingleValuePickField(
      controller:
          _comicDraft?.comicEdit.imprintController ?? TextEditingController(),
      label: 'Imprint',
      options: draft.vocabulary?.imprintOptions ?? const [],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicSeriesGroupField({String label = 'Series Group'}) {
    return SingleValuePickField(
      controller: _comicDraft?.comicEdit.seriesGroupController ??
          TextEditingController(),
      label: label,
      options: draft.vocabulary?.seriesGroupOptions ?? const [],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicPhysicalFormatField({String label = 'Format'}) {
    return SingleValuePickField(
      controller: _comicDraft?.comicEdit.physicalFormatLabelController ??
          TextEditingController(),
      label: label,
      options: draft.vocabulary?.physicalFormatOptions ??
          const [
            'Floppy',
            'Trade Paperback',
            'Hardcover',
            'Omnibus',
            'Digital'
          ],
      showPickerListAction: true,
    );
  }

  @override
  Widget buildComicTagsDropdownField({String label = 'Tags'}) {
    return TagPickListField(
      controller: draft.personal.tagsController,
      options: draft.vocabulary?.tagOptions ?? const [],
      label: label,
    );
  }

  @override
  Widget buildComicOwnerPickField({String label = 'Owner'}) {
    return SingleValuePickField(
      controller: draft.personal.ownerLabelController,
      label: label,
      options: const [],
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
    return SingleValuePickField(
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
