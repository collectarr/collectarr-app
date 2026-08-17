import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';
import 'package:collectarr_app/features/library/edit/draft/kind_edit_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/text_controller_group.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';

typedef KindEditDraftFactory = KindEditDraft Function({
  required LibraryMetadataItem item,
  OwnedItem? ownedItem,
  TrackingEntry? trackingEntry,
  required TextControllerGroup textControllers,
});

/// Encapsulates edit dialogs, edit chrome, field config, condition/grade options,
/// and kind-owned draft creation.
class LibraryEditCapability {
  const LibraryEditCapability({
    this.editDialogBuilder,
    this.mediaEditDialogBuilder,
    this.releaseEditDialogBuilder,
    this.presentation = const LibraryEditPresentation(
      builder: DefaultLibraryEditPresentationBuilder(),
    ),
    this.editChrome = const LibraryEditChromeConfig(),
    this.mediaFields = const MediaEditFields(),
    this.releaseFields = const ReleaseEditFields(),
    this.conditions = kGeneralConditions,
    this.grades = const [],
    this.defaultCondition,
    this.defaultGrade,
    this.manualAddUsesTitleAsSeries = false,
    this.editUsesTitleAsSeries = false,
    this.createDraft = createGenericEditDraft,
  });

  final LibraryEditDialogBuilder? editDialogBuilder;
  final LibraryEditDialogBuilder? mediaEditDialogBuilder;
  final LibraryEditDialogBuilder? releaseEditDialogBuilder;
  final LibraryEditPresentation presentation;
  final LibraryEditChromeConfig editChrome;
  final MediaEditFields mediaFields;
  final ReleaseEditFields releaseFields;
  final List<String> conditions;
  final List<String> grades;
  final String? defaultCondition;
  final String? defaultGrade;
  final bool manualAddUsesTitleAsSeries;
  final bool editUsesTitleAsSeries;
  final KindEditDraftFactory createDraft;

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasGradePickList => grades.isNotEmpty;
  bool get usesTitleAsSeriesFallback =>
      manualAddUsesTitleAsSeries || editUsesTitleAsSeries;
}
