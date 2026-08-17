import 'package:collectarr_app/features/library/config/collection_defaults.dart';
import 'package:collectarr_app/features/library/config/edit_field_config.dart';
import 'package:collectarr_app/features/library/config/library_chrome_config.dart';
import 'package:collectarr_app/features/library/config/library_edit_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_item_actions.dart';
import 'package:collectarr_app/features/library/config/presentation/default_library_edit_presentation_builder.dart';

/// Encapsulates edit dialogs, edit chrome, field config, and condition/grade options.
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

  bool get hasConditionPickList => conditions.isNotEmpty;
  bool get hasGradePickList => grades.isNotEmpty;
  bool get usesTitleAsSeriesFallback =>
      manualAddUsesTitleAsSeries || editUsesTitleAsSeries;
}
