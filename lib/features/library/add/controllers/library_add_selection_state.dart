import 'package:collectarr_app/features/library/add/models/library_add_reference_type.dart';

class LibraryAddSelectionState {
  String? selectedResultId;
  String? selectedProviderCandidateId;
  String? selectedBundleReleaseId;
  String? selectedReferenceEditionId;
  String? selectedReferenceVariantId;
  final checkedResultIds = <String>{};
  final checkedProviderIds = <String>{};
  LibraryAddReferenceType referenceType = LibraryAddReferenceType.media;
  bool showCoreResults = true;
  bool showProviderResults = true;
  bool showMediaResults = true;
  bool showSeasonResults = true;
  bool showReleaseResults = true;
  bool hideComicOwnedResults = false;
  bool hideComicVariantResults = false;
  bool compactComicIssues = true;
}
