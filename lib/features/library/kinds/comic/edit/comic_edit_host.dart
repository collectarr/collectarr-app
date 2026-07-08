import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/edit/item_images_edit_section.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/comic_edit_models.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ComicEditHost {
  BuildContext get comicContext;
  WidgetRef get comicRef;
  Color get comicAccent;
  LibraryTypeConfig get comicLibraryType;
  LibraryMetadataItem get comicLibraryItem;
  List<ItemImage> get comicItemImages;
  LibraryEditPresentationState get comicEditPresentation;

  List<EditableComicCreator> get comicCreators;
  List<EditableComicCharacter> get comicCharacters;
  List<Map<String, TextEditingController>> get comicLinks;
  TextEditingController get comicCharacterDraftController;

  TextEditingController get comicTitleController;
  TextEditingController get comicOriginalTitleController;
  TextEditingController get comicEditionTitleController;
  TextEditingController get comicVariantController;
  TextEditingController get comicNumberController;
  TextEditingController get comicBarcodeController;
  TextEditingController get comicPhysicalFormatLabelController;
  TextEditingController get comicCoverDateController;
  TextEditingController get comicCoverDateYearPartController;
  TextEditingController get comicCoverDateMonthPartController;
  TextEditingController get comicCoverDateDayPartController;
  TextEditingController get comicReleaseDateController;
  TextEditingController get comicReleaseDateYearPartController;
  TextEditingController get comicReleaseDateMonthPartController;
  TextEditingController get comicReleaseDateDayPartController;
  TextEditingController get comicLocalizedTitleController;
  TextEditingController get comicSearchAliasesController;
  TextEditingController get comicSortKeyController;
  TextEditingController get comicAgeRatingController;
  TextEditingController get comicPageCountController;
  TextEditingController get comicGenresEditController;
  TextEditingController get comicLanguageController;
  TextEditingController get comicOwnerLabelController;
  TextEditingController get comicTagsController;
  TextEditingController get comicStorageDeviceController;
  TextEditingController get comicStorageSlotController;
  TextEditingController get comicTrackingNotesController;
  TextEditingController get comicNotesController;
  TextEditingController get comicTrackingController;
  TextEditingController get comicRatingController;
  TextEditingController get comicGradeController;
  TextEditingController get comicConditionController;
  TextEditingController get comicRawOrSlabbedController;
  TextEditingController get comicGradingCompanyController;
  TextEditingController get comicGraderNotesController;
  TextEditingController get comicSignedByController;
  TextEditingController get comicLabelTypeController;
  TextEditingController get comicCertificationNumberController;
  TextEditingController get comicCoverPriceController;
  TextEditingController get comicKeyReasonController;
  TextEditingController get comicKeyCategoryController;
  TextEditingController get comicPriceController;
  TextEditingController get comicCurrencyController;
  TextEditingController get comicMarketValueController;
  TextEditingController get comicPurchaseDateController;
  TextEditingController get comicPurchaseStoreController;
  TextEditingController get comicSellPriceController;
  TextEditingController get comicSoldToController;
  TextEditingController get comicCoverController;
  TextEditingController get comicThumbnailController;

  bool get comicKeyComic;
  set comicKeyComic(bool value);
  DateTime? get comicLastBagBoardDate;
  set comicLastBagBoardDate(DateTime? value);
  DateTime? get comicStartedAt;
  set comicStartedAt(DateTime? value);
  DateTime? get comicFinishedAt;
  set comicFinishedAt(DateTime? value);
  DateTime? get comicSoldAt;
  set comicSoldAt(DateTime? value);
  String? get comicSelectedBundleReleaseId;
  set comicSelectedBundleReleaseId(String? value);
  bool get comicShowPhysicalOwnedFields;
  String get comicSelectedOwnedAnchorType;
  List<ItemImageEdit> get comicItemImageEdits;
  set comicItemImageEdits(List<ItemImageEdit> value);

  List<String> get comicGenreOptions;
  List<String> get comicTagOptions;
  List<String> get comicOwnerOptions;

  void comicMutateState(VoidCallback fn);
  void comicOpenEditTab(String id);
  Map<String, TextEditingController> comicCreateLinkControllers({
    String title = '',
    String url = '',
  });

  Widget buildComicCrossoverPickField({String label = 'Crossover'});
  Widget buildComicStoryArcPickField({String label = 'Story Arc'});
  Widget buildComicCountryPickField({String label = 'Country'});
  Widget buildComicPageQualityPickField({String label = 'Page quality'});
  Widget buildComicKeyCategoryPickField({String label = 'Key category'});
  Widget buildComicSeriesField();
  Widget buildComicPublisherField({String label = 'Publisher'});
  Widget buildComicImprintField();
  Widget buildComicSeriesGroupField({String label = 'Series Group'});
  Widget buildComicPhysicalFormatField({String label = 'Format'});
  Widget buildComicTagsDropdownField({String label = 'Tags'});
  Widget buildComicOwnerPickField({String label = 'Owner'});

  Widget buildComicOwnershipAnchorSelectionField();
  Widget buildComicEditionSelectionField();
  Widget buildComicVariantSelectionField();
  Widget buildComicBundleReleaseSelectionField({
    Key? fieldKey,
    required String label,
    required String? selectedBundleReleaseId,
    required ValueChanged<String?> onChanged,
  });

  Widget buildComicFlexRow(
    List<Widget> children, {
    required List<int> flexes,
    double breakpoint = 880,
  });
}